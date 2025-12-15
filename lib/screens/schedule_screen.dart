// screens/schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';
import '../providers/auth_provider.dart';
import '../models/schedule_model.dart';
import '../utils/theme.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  @override
  void initState() {
    super.initState();
    // Ambil data jadwal saat layar dibuka
    Future.microtask(() =>
        Provider.of<ScheduleProvider>(context, listen: false).fetchSchedules());
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final displayName = user?.name ?? 'Celine';
    final scheduleProvider = Provider.of<ScheduleProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFCEDF2), // Latar Pink Muda
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header (Hallo Celine)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hallo',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.subTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 28,
                          color: AppTheme.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // Logo Placeholder
                   Row(
                    children: [
                      Icon(Icons.local_hospital, size: 32, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('POSYANDU', style: TextStyle(fontSize: 10, color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                          Text('HARAPAN\nBUNDA', style: TextStyle(fontSize: 10, color: AppTheme.primaryColor, fontWeight: FontWeight.bold, height: 1)),
                        ],
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.more_vert, color: AppTheme.textColor),
                    ],
                  )
                ],
              ),
            ),

            // 2. Konten Utama (White Container Rounded)
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    // Header Internal (Jadwal & Minggu Ini)
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Icon(Icons.arrow_back, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Jadwal',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textColor,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Minggu Ini',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // List Jadwal
                    Expanded(
                      child: scheduleProvider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : scheduleProvider.schedules.isEmpty
                              ? const Center(child: Text("Tidak ada jadwal minggu ini"))
                              : _buildGroupedList(scheduleProvider.groupedSchedules),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk membuat List yang dikelompokkan per tanggal
  Widget _buildGroupedList(Map<String, List<ScheduleModel>> groupedData) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: groupedData.keys.length,
      itemBuilder: (context, index) {
        String dateKey = groupedData.keys.elementAt(index);
        List<ScheduleModel> dailySchedules = groupedData[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Tanggal (Misal: Rabu 17 April 2025)
            Padding(
              padding: const EdgeInsets.only(bottom: 16, top: 8),
              child: Text(
                dateKey,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            
            // Container Abu-abu pembungkus Card
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5), // Abu-abu muda
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: dailySchedules.map((schedule) {
                  return _buildScheduleCard(schedule);
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  // Widget untuk Kartu Item (Imunisasi, dll)
  Widget _buildScheduleCard(ScheduleModel schedule) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Garis vertikal hitam + Nama Layanan
          IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 3,
                  color: Colors.black87,
                ),
                const SizedBox(width: 8),
                Text(
                  schedule.serviceName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor, // Dark Grey
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Jam dan Lokasi (Label Pink)
          Row(
            children: [
              // Label Jam (Border Pink, Text Pink)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCEDF2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                ),
                child: Text(
                  '${schedule.startTime}-${schedule.endTime}',
                  style: TextStyle(
                    color: AppTheme.accentColor, // Merah tua/Pink tua
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Label Lokasi (Background Pink Solid)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2D5DD), // Pink agak gelap sesuai gambar
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  schedule.location,
                  style: TextStyle(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}