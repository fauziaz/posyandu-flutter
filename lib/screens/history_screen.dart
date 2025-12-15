import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pemeriksaan'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          HistoryCard(
            date: '12 Jan 2025',
            weight: '8.5 kg',
            height: '72 cm',
            immunization: 'Polio',
          ),
          HistoryCard(
            date: '12 Des 2024',
            weight: '8.2 kg',
            height: '70 cm',
          ),
        ],
      ),
    );
  }
}

class HistoryCard extends StatelessWidget {
  final String date;
  final String weight;
  final String height;
  final String? immunization;

  const HistoryCard({
    super.key,
    required this.date,
    required this.weight,
    required this.height,
    this.immunization,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pemeriksaan $date',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _SubCard(
                    icon: Icons.monitor_weight_rounded,
                    title: 'Berat Badan',
                    value: weight,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SubCard(
                    icon: Icons.height_outlined,
                    title: 'Tinggi Badan',
                    value: height,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            if (immunization != null) ...[
              const SizedBox(height: 12),
              _SubCard(
                icon: Icons.vaccines_rounded,
                title: 'Imunisasi',
                value: immunization!,
                color: Colors.orange,
                fullWidth: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SubCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final bool fullWidth;

  const _SubCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
