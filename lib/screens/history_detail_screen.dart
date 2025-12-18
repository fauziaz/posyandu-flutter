// screens/history_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/history_model.dart';
import '../utils/theme.dart';

class HistoryDetailScreen extends StatelessWidget {
  final HistoryModel history;

  const HistoryDetailScreen({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Detail Pemeriksaan'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textColor),
        titleTextStyle: const TextStyle(
          color: AppTheme.textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header Card with Date
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    DateFormat(
                      'EEEE, d MMMM yyyy',
                      'id_ID',
                    ).format(history.date),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pukul ${DateFormat('HH:mm').format(history.date)} WIB',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Berat Badan',
                    '${history.weight} kg',
                    Icons.monitor_weight_outlined,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Tinggi Badan',
                    '${history.height} cm',
                    Icons.height,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Additional Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    'Lingkar Kepala',
                    '${history.headCircumference ?? "-"} cm',
                    Icons.face_outlined,
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    'Imunisasi',
                    history.immunization != null &&
                            history.immunization!.isNotEmpty
                        ? history.immunization!
                        : '-',
                    Icons.vaccines_outlined,
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    'Vitamin',
                    history.vitamin ?? '-',
                    Icons.medication_outlined,
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    'Catatan',
                    history.notes ?? 'Tidak ada catatan',
                    Icons.note_alt_outlined,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppTheme.subTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.subTextColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: AppTheme.subTextColor),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
