// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:posyandu_flutter/screens/history_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/history_screen.dart';
import '../screens/schedule_screen.dart';
import '../utils/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo,',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppTheme.subTextColor),
                      ),
                      Text(
                        user?.name ?? 'Pengguna',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textColor,
                            ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryColor,
                        width: 2,
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: AppTheme.primaryColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Main Menu Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio:
                    1.3, // Adjusted aspect ratio to prevent overflow
                children: [
                  _buildMenuCard(
                    context,
                    'Jadwal\nPemeriksaan',
                    Icons.calendar_month_rounded,
                    const Color(0xFFE3F2FD),
                    const Color(0xFF2196F3),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScheduleScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuCard(
                    context,
                    'Reservasi\nOnline',
                    Icons.app_registration_rounded,
                    const Color(0xFFE8F5E9),
                    const Color(0xFF4CAF50),
                  ),
                  _buildMenuCard(
                    context,
                    'Profil\nAkun',
                    Icons.person_outline_rounded,
                    const Color(0xFFFFF3E0),
                    const Color(0xFFFF9800),
                  ),
                  _buildMenuCard(
                    context,
                    'Riwayat Pemeriksaan',
                    Icons.child_care_rounded,
                    const Color(0xFFF3E5F5),
                    const Color(0xFF9C27B0),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HistoryScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Pelayanan Kami Section
              Text(
                'Pelayanan Kami',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 110, // Increased height
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  children: [
                    _buildServiceCard('Imunisasi', Icons.vaccines_outlined),
                    _buildServiceCard(
                      'Penimbangan',
                      Icons.monitor_weight_outlined,
                    ),
                    _buildServiceCard('Tinggi Badan', Icons.height_outlined),
                    _buildServiceCard(
                      'Konsultasi',
                      Icons.chat_bubble_outline_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Artikel & Edukasi Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Artikel & Edukasi',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildArticleCard(
                'Pentingnya Imunisasi Dasar Lengkap',
                'Imunisasi melindungi anak dari penyakit berbahaya...',
                Colors.blue.shade50,
                Colors.blue,
              ),
              _buildArticleCard(
                'Makanan Bergizi untuk Balita',
                'Asupan gizi seimbang sangat penting untuk tumbuh kembang...',
                Colors.green.shade50,
                Colors.green,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

    Widget _buildMenuCard(
      BuildContext context,
      String title,
      IconData icon,
      Color bgColor,
      Color iconColor, {
      VoidCallback? onTap,
    }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(String title, IconData icon) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.accentColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(
    String title,
    String subtitle,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.article_outlined, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(color: AppTheme.subTextColor, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
