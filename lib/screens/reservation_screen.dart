// screens/reservation_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Wajib import ini
import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import '../models/reservation_model.dart';
import '../services/reservation_service.dart';
import 'history_screen.dart'; // Import halaman tujuan

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
    // Set tanggal hari ini sebagai default dan update antrian
    _updateDate(DateTime.now());
  }

  // Fungsi update tanggal & fetch nomor antrian
  void _updateDate(DateTime date) async {
    setState(() {
      _selectedDate = date;
      // Format tampilan ke Indonesia
      _dateController.text = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
      _currentQueueNumber = '...'; // Loading state text
    });

    // Ambil nomor antrian dari database sesuai tanggal
    final queueNo = await _reservationService.getNextQueueNumber(date);
    
    if (mounted) {
      setState(() {
        _currentQueueNumber = queueNo;
      });
    }
  }

  // Fungsi Submit
  Future<void> _submitReservation() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama Balita harus diisi')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Pastikan nomor antrian terbaru (takutnya ada yg booking barengan)
      final finalQueueNumber = await _reservationService.getNextQueueNumber(_selectedDate);

      // 2. Buat Model Data
      final newReservation = ReservationModel(
        serviceType: _selectedService!,
        reservationDate: _selectedDate,
        queueTime: _selectedTime!,
        childName: _nameController.text,
        queueNumber: finalQueueNumber,
      );

      // 3. Kirim ke Supabase
      await _reservationService.createReservation(newReservation);

      if (mounted) {
        // 4. Navigasi ke Halaman History
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Reservasi Berhasil! Antrian: $finalQueueNumber')),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HistoryScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal reservasi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Fungsi Pilih Tanggal (DatePicker)
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(), // Tidak boleh tanggal lampau
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      _updateDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final displayName = user?.name ?? 'Celine';

    return Scaffold(
      backgroundColor: AppTheme.primaryColor.withOpacity(0.3), 
      body: Stack(
        children: [
          Container(
            height: 220,
            color: const Color(0xFFF2D5DD),
          ),
          Positioned(
            top: 50, left: 24, right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hallo', style: TextStyle(fontSize: 16, color: _purpleTextColor, fontWeight: FontWeight.w500)),
                    Text(displayName, style: TextStyle(fontSize: 28, color: _purpleTextColor, fontWeight: FontWeight.bold)),
                  ],
                ),
                // Logo placeholder...
                Row(
                  children: [
                    Icon(Icons.local_hospital, size: 32, color: _purpleTextColor),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('POSYANDU', style: TextStyle(fontSize: 10, color: _purpleTextColor, fontWeight: FontWeight.bold)),
                        Text('HARAPAN\nBUNDA', style: TextStyle(fontSize: 10, color: _purpleTextColor, fontWeight: FontWeight.bold, height: 1)),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.more_vert, color: _purpleTextColor),
                  ],
                )
              ],
            ),
          ),

          // Container Putih Form
          Container(
            margin: const EdgeInsets.only(top: 140),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
            ),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              children: [
                _buildLabel('Pilih Layanan'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: _inputDecoration(),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedService,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                      items: ['Imunisasi Balita', 'Pemeriksaan Ibu Hamil', 'Konsultasi Gizi']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedService = val),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _buildLabel('Pilih Tanggal'),
                GestureDetector( // Bungkus dengan GestureDetector agar bisa di-tap
                  onTap: _pickDate,
                  child: Container(
                    decoration: _inputDecoration(),
                    child: TextField(
                      controller: _dateController,
                      enabled: false, // Disable typing manual
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        suffixIcon: Icon(Icons.calendar_today_outlined, size: 20, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _buildLabel('Pilih Jam Antrian'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: _inputDecoration(),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedTime,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                      items: ['08.00 - 09.00', '09.00 - 10.00', '10.00 - 11.00']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedTime = val),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _buildLabel('Nama Balita'),
                Container(
                  decoration: _inputDecoration(),
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Tampilan Nomor Antrian Dinamis
                Center(
                  child: Column(
                    children: [
                      Text(
                        _currentQueueNumber, // <--- Ini sekarang dinamis (A01, A02)
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: _purpleTextColor,
                        ),
                      ),
                      const Text(
                        'Estimasi nomor antrian Anda',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Harap datang 15 menit sebelum jam antrian.',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitReservation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _purpleColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Konfirmasi Reservasi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        text,
        style: TextStyle(color: _purpleTextColor, fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  BoxDecoration _inputDecoration() {
    return BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(12),
    );
  }
}