// screens/faq_screen.dart
import 'package:flutter/material.dart';
import '../utils/theme.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  final List<Map<String, String>> _faqs = const [
    {
      'question': 'Apa itu Posyandu Harapan Bunda?',
      'answer':
          'Posyandu Harapan Bunda adalah pusat pelayanan kesehatan masyarakat yang berfokus pada kesehatan ibu dan anak, memberikan layanan imunisasi, penimbangan, dan konsultasi gizi.',
    },
    {
      'question': 'Bagaimana cara mendaftar antrian online?',
      'answer':
          'Anda dapat mendaftar antrian online melalui menu "Reservasi Online" di halaman utama aplikasi. Pilih layanan dan tanggal yang tersedia.',
    },
    {
      'question': 'Apa saja layanan yang tersedia?',
      'answer':
          'Layanan kami meliputi Imunisasi Balita, Pemeriksaan Ibu Hamil, Penimbangan Berat Badan, Pengukuran Tinggi Badan, dan Konsultasi Gizi.',
    },
    {
      'question': 'Apakah layanan ini gratis?',
      'answer':
          'Ya, sebagian besar layanan dasar di Posyandu Harapan Bunda tidak dipungut biaya (gratis) bagi warga yang terdaftar.',
    },
    {
      'question': 'Kapan jadwal operasional Posyandu?',
      'answer':
          'Jadwal operasional dapat dilihat pada menu "Jadwal Pemeriksaan". Kami biasanya buka setiap hari kerja mulai pukul 08.00 hingga 12.00.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('FAQ', style: TextStyle(color: AppTheme.textColor)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textColor),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _faqs.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: ExpansionTile(
              title: Text(
                _faqs[index]['question']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    _faqs[index]['answer']!,
                    style: TextStyle(color: AppTheme.subTextColor),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
