// screens/reservation_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/queue_provider.dart';
import '../providers/schedule_provider.dart';
import '../utils/theme.dart';
import '../models/reservation_model.dart';
import '../services/reservation_service.dart';
import 'history_screen.dart';
import 'queue_dashboard_screen.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final ReservationService _reservationService = ReservationService();

  // Controller & State
  final _nameController = TextEditingController(text: 'France');
  final _dateController = TextEditingController(); // Kosongkan dulu

  DateTime _selectedDate = DateTime.now();
  String? _selectedService = 'Imunisasi Balita';
  String? _selectedTime = '08.00 - 09.00';

  // State untuk Nomor Antrian Dinamis
  String _currentQueueNumber = '...';
  bool _isLoading = false;

  final Color _purpleColor = const Color(0xFFA595A9);
  final Color _purpleTextColor = const Color(0xFF6A5B6E);

  @override
  void initState() {
    super.initState();
    // Set nama dari user yang login
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null && user.name.isNotEmpty) {
        _nameController.text = user.name;
      }

      // Fetch schedules dan set tanggal awal ke jadwal terdekat
      final scheduleProvider = Provider.of<ScheduleProvider>(
        context,
        listen: false,
      );
      await scheduleProvider.fetchSchedules();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Cari jadwal yang >= hari ini
      final upcomingSchedules = scheduleProvider.schedules.where((s) {
        final sDate = DateTime(
          s.scheduleDate.year,
          s.scheduleDate.month,
          s.scheduleDate.day,
        );
        return !sDate.isBefore(today);
      }).toList();

      // Sort berdasarkan tanggal terdekat
      upcomingSchedules.sort(
        (a, b) => a.scheduleDate.compareTo(b.scheduleDate),
      );

      if (upcomingSchedules.isNotEmpty) {
        _updateDate(upcomingSchedules.first.scheduleDate);
      } else {
        _updateDate(DateTime.now());
      }
    });
  }

  // Fungsi update tanggal & fetch nomor antrian
  void _updateDate(DateTime date) async {
    setState(() {
      _selectedDate = date;
      // Format tampilan ke Indonesia
      _dateController.text = DateFormat(
        'EEEE, d MMMM yyyy',
        'id_ID',
      ).format(date);
      _currentQueueNumber = '...'; // Loading state text
    });

    // Ambil nomor antrian dari QueueProvider
    final queueProvider = Provider.of<QueueProvider>(context, listen: false);
    final queueNo = await queueProvider.getNextQueueNumber(date);

    // Setup real-time subscription untuk tanggal ini
    queueProvider.setupRealtimeSubscription(date);

    if (mounted) {
      setState(() {
        _currentQueueNumber = queueNo;
      });
    }
  }

  // Fungsi Submit
  Future<void> _submitReservation() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nama Balita harus diisi')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null) {
        throw Exception('User tidak ditemukan');
      }

      final queueProvider = Provider.of<QueueProvider>(context, listen: false);

      // Create queue dengan provider (auto-generate nomor antrian yang unique)
      // Provider sekarang sudah menangani cek duplikat dan insert ke tabel reservations
      final success = await queueProvider.createQueue(
        patientName: _nameController.text,
        serviceType: _selectedService!,
        reservationDate: _selectedDate,
        queueTime: _selectedTime!,
        userId: user.id,
      );

      if (success) {
        if (mounted) {
          // Ambil nomor antrian terakhir untuk ditampilkan di pesan sukses
          // Kita bisa ambil dari list queues yang baru di-fetch oleh provider
          final queues = queueProvider.queues;
          final myQueue = queues.isNotEmpty ? queues.last.queueNumber : '-';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reservasi Berhasil! Antrian: $myQueue'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HistoryScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Tampilkan pesan error yang spesifik (misal: duplikat)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Fungsi Pilih Tanggal (DatePicker)
  Future<void> _pickDate() async {
    final scheduleProvider = Provider.of<ScheduleProvider>(
      context,
      listen: false,
    );

    // Ambil daftar tanggal yang tersedia dari jadwal
    final availableDates = scheduleProvider.schedules.map((s) {
      return DateTime(
        s.scheduleDate.year,
        s.scheduleDate.month,
        s.scheduleDate.day,
      );
    }).toSet();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(), // Tidak boleh tanggal lampau
      lastDate: DateTime.now().add(const Duration(days: 90)),
      selectableDayPredicate: (DateTime day) {
        // Hanya boleh pilih tanggal yang ada di jadwal
        final normalizedDay = DateTime(day.year, day.month, day.day);
        return availableDates.contains(normalizedDay);
      },
    );
    if (picked != null && picked != _selectedDate) {
      _updateDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final displayName = user?.name ?? 'Celine';
    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 0,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            title: const Text(
              'Reservasi Online',
              style: TextStyle(
                color: AppTheme.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            leading: canPop
                ? IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppTheme.textColor,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                : null,
          ),

          // Form Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade50,
                          Colors.blue.shade100.withOpacity(0.5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.shade200, width: 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade700,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Pastikan data yang Anda masukkan sudah benar',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Queue Number Display Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8BBD0),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF8BBD0).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Decorative circles
                        Positioned(
                          top: -10,
                          right: -10,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -20,
                          left: -20,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.confirmation_number_outlined,
                                  color: const Color(0xFF880E4F),
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Nomor Antrian Anda',
                                  style: TextStyle(
                                    color: Color(0xFF880E4F),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(
                                    0xFF880E4F,
                                  ).withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                _currentQueueNumber,
                                style: const TextStyle(
                                  fontSize: 64,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF880E4F),
                                  letterSpacing: 4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.access_time_rounded,
                                        color: Color(0xFF880E4F),
                                        size: 16,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Datang 15 menit lebih awal',
                                        style: TextStyle(
                                          color: Color(0xFF880E4F),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Section Header
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF48FB1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Detail Reservasi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Form Cards
                  _buildModernFormField(
                    label: 'Layanan',
                    icon: Icons.medical_services_rounded,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedService,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items:
                            [
                                  'Imunisasi Balita',
                                  'Pemeriksaan Ibu Hamil',
                                  'Konsultasi Gizi',
                                ]
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedService = val),
                      ),
                    ),
                  ),

                  _buildModernFormField(
                    label: 'Tanggal Kunjungan',
                    icon: Icons.calendar_month_rounded,
                    child: GestureDetector(
                      onTap: _pickDate,
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _dateController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Pilih tanggal',
                          ),
                        ),
                      ),
                    ),
                  ),

                  _buildModernFormField(
                    label: 'Jam Kunjungan',
                    icon: Icons.access_time_rounded,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedTime,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items:
                            ['08.00 - 09.00', '09.00 - 10.00', '10.00 - 11.00']
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) => setState(() => _selectedTime = val),
                      ),
                    ),
                  ),

                  _buildModernFormField(
                    label: 'Nama Balita',
                    icon: Icons.child_care_rounded,
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Masukkan nama balita',
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Action Buttons
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitReservation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF48FB1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      minimumSize: const Size(double.infinity, 56),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline, size: 24),
                              SizedBox(width: 12),
                              Text(
                                'Konfirmasi Reservasi',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 16),

                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QueueDashboardScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFF48FB1),
                      side: const BorderSide(
                        color: Color(0xFFF48FB1),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.dashboard_outlined, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Lihat Dashboard Antrian',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Bottom Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.help_outline,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Butuh bantuan? Hubungi admin posyandu',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernFormField({
    required String label,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Row(
              children: [
                Icon(icon, size: 18, color: const Color(0xFFF48FB1)),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
