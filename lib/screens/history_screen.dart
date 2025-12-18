// screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/history_provider.dart';
import '../models/history_model.dart';
import '../utils/theme.dart';
import 'history_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Semua';

  final List<String> _filterOptions = [
    'Semua',
    'Imunisasi',
    'Vitamin',
    'Pemeriksaan',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<HistoryProvider>(context, listen: false).fetchHistory(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<HistoryModel> _filterHistory(List<HistoryModel> list) {
    // 1. Filter by Search Query
    var filtered = list;
    if (_searchQuery.isNotEmpty) {
      filtered = list.where((history) {
        final dateString = DateFormat(
          'dd MMM yyyy',
        ).format(history.date).toLowerCase();
        final immunization = history.immunization?.toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        return dateString.contains(query) || immunization.contains(query);
      }).toList();
    }

    // 2. Filter by Category Chip
    if (_selectedFilter == 'Semua') {
      return filtered;
    } else if (_selectedFilter == 'Imunisasi') {
      return filtered
          .where(
            (h) =>
                h.immunization != null &&
                h.immunization!.isNotEmpty &&
                h.immunization != '-',
          )
          .toList();
    } else if (_selectedFilter == 'Vitamin') {
      return filtered
          .where(
            (h) =>
                h.vitamin != null && h.vitamin!.isNotEmpty && h.vitamin != '-',
          )
          .toList();
    } else if (_selectedFilter == 'Pemeriksaan') {
      // Tampilkan yang tidak ada imunisasi/vitamin (hanya cek fisik)
      // Atau tampilkan semua karena semua adalah pemeriksaan?
      // Asumsi: Pemeriksaan Rutin (tanpa imunisasi/vitamin spesifik)
      return filtered
          .where(
            (h) =>
                (h.immunization == null ||
                    h.immunization!.isEmpty ||
                    h.immunization == '-') &&
                (h.vitamin == null || h.vitamin!.isEmpty || h.vitamin == '-'),
          )
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pemeriksaan'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.historyList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredList = _filterHistory(provider.historyList);

          return Column(
            children: [
              // Search Bar
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                color: Colors.white,
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari tanggal atau imunisasi...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              // Filter Chips
              Container(
                height: 50,
                width: double.infinity,
                color: Colors.white,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _filterOptions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _filterOptions[index];
                    final isSelected = _selectedFilter == filter;
                    return ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        }
                      },
                      selectedColor: AppTheme.primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textColor,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      backgroundColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.transparent,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Shadow separator
              Container(
                height: 1,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),

              // List Data
              Expanded(
                child: filteredList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 80,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              provider.historyList.isEmpty
                                  ? 'Belum ada data riwayat'
                                  : 'Data tidak ditemukan',
                              style: TextStyle(color: AppTheme.subTextColor),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final data = filteredList[index];
                          return HistoryCard(
                            history: data,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      HistoryDetailScreen(history: data),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class HistoryCard extends StatelessWidget {
  final HistoryModel history;
  final VoidCallback onTap;

  const HistoryCard({super.key, required this.history, required this.onTap});

  String get _activityTitle {
    if (history.immunization != null &&
        history.immunization!.isNotEmpty &&
        history.immunization != '-') {
      return 'Imunisasi ${history.immunization}';
    } else if (history.vitamin != null &&
        history.vitamin!.isNotEmpty &&
        history.vitamin != '-') {
      return 'Pemberian Vitamin';
    } else {
      return 'Pemeriksaan Rutin';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _activityTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat(
                            'EEEE, dd MMMM yyyy',
                            'id_ID',
                          ).format(history.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.monitor_weight_outlined,
                      label: 'Berat',
                      value: '${history.weight} kg',
                      color: Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.height,
                      label: 'Tinggi',
                      value: '${history.height} cm',
                      color: Colors.green,
                    ),
                  ),
                  if (history.immunization != null &&
                      history.immunization!.isNotEmpty &&
                      history.immunization != '-')
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.vaccines,
                        label: 'Imunisasi',
                        value: history.immunization!,
                        color: Colors.orange,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
