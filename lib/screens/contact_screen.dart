// screens/contact_screen.dart
import 'package:flutter/material.dart';
import '../utils/theme.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Hubungi Kami',
          style: TextStyle(color: AppTheme.textColor),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ada pertanyaan atau butuh bantuan? Hubungi kami melalui kontak di bawah ini.',
              style: TextStyle(fontSize: 16, color: AppTheme.subTextColor),
            ),
            const SizedBox(height: 24),

            _buildContactCard(
              icon: Icons.phone,
              title: 'Telepon / WhatsApp',
              content: '+62 812-3456-7890',
              color: Colors.green,
              onTap: () {
                // Implement launchUrl for phone/wa
              },
            ),
            const SizedBox(height: 16),

            _buildContactCard(
              icon: Icons.email,
              title: 'Email',
              content: 'info@posyanduharapanbunda.id',
              color: Colors.blue,
              onTap: () {
                // Implement launchUrl for email
              },
            ),
            const SizedBox(height: 16),

            _buildContactCard(
              icon: Icons.location_on,
              title: 'Alamat',
              content: 'Desa Cilombang',
              color: Colors.red,
              onTap: () {
                // Implement launchUrl for maps
              },
            ),

            const SizedBox(height: 32),
            const Text(
              'Jam Operasional',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildScheduleRow('Senin - Jumat', '08.00 - 12.00 WIB'),
                  const Divider(height: 24),
                  _buildScheduleRow('Sabtu', '08.00 - 11.00 WIB'),
                  const Divider(height: 24),
                  _buildScheduleRow('Minggu / Libur', 'Tutup'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.subTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleRow(String day, String time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          day,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppTheme.textColor,
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: time == 'Tutup' ? Colors.red : AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }
}
