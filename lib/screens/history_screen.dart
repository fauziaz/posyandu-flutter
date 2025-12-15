// screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal
import '../providers/history_provider.dart';
import '../models/history_model.dart';
import '../utils/theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Ambil data dari Supabase saat halaman dibuka
    Future.microtask(() =>
        Provider.of<HistoryProvider>(context, listen: false).fetchHistory());
  }

  // Fungsi untuk memunculkan Form Tambah Data (Bottom Sheet)
  void _showAddDataSheet(BuildContext context) {
    final weightController = TextEditingController();
    final heightController = TextEditingController();
    final immunizationController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Catat Hasil Pemeriksaan',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
              ),
              const SizedBox(height: 24),
              
              // Input Berat Badan
              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Berat Badan (kg)',
                  suffixText: 'kg',
                  prefixIcon: Icon(Icons.monitor_weight_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // Input Tinggi Badan
              TextField(
                controller: heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Tinggi Badan (cm)',
                  suffixText: 'cm',
                  prefixIcon: Icon(Icons.height),
                ),
              ),
              const SizedBox(height: 16),

              // Input Imunisasi (Opsional)
              TextField(
                controller: immunizationController,
                decoration: const InputDecoration(
                  labelText: 'Imunisasi (Opsional)',
                  hintText: 'Contoh: Polio, Campak',
                  prefixIcon: Icon(Icons.vaccines_outlined),
                ),
              ),
              const SizedBox(height: 24),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          // Validasi sederhana
                          if (weightController.text.isEmpty ||
                              heightController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Berat dan Tinggi wajib diisi')),
                            );
                            return;
                          }

                          setSheetState(() => isSubmitting = true);

                          final newData = HistoryModel(
                            date: DateTime.now(),
                            weight: double.parse(weightController.text.replaceAll(',', '.')),
                            height: double.parse(heightController.text.replaceAll(',', '.')),
                            immunization: immunizationController.text.isEmpty
                                ? null
                                : immunizationController.text,
                          );

                          final success = await Provider.of<HistoryProvider>(
                                  context,
                                  listen: false)
                              .addHistory(newData);

                          setSheetState(() => isSubmitting = false);

                          if (success && mounted) {
                            Navigator.pop(context); // Tutup sheet
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Data berhasil disimpan!')),
                            );
                          }
                        },
                  child: isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Simpan Data'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pemeriksaan'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDataSheet(context),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Catat Data', style: TextStyle(color: Colors.white)),
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.historyList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_edu_rounded,
                      size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat pemeriksaan',
                    style: TextStyle(color: AppTheme.subTextColor),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchHistory(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.historyList.length,
              itemBuilder: (context, index) {
                final data = provider.historyList[index];
                return HistoryCard(
                  date: DateFormat('dd MMM yyyy').format(data.date),
                  weight: '${data.weight} kg',
                  height: '${data.height} cm',
                  immunization: data.immunization,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// Widget Card (Sama seperti desain sebelumnya, tapi reusable)
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

            if (immunization != null && immunization!.isNotEmpty) ...[
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
          Expanded(
            child: Column(
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
          ),
        ],
      ),
    );
  }
}