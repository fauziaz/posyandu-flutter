// screens/queue_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../utils/theme.dart';
import '../models/queue_model.dart';
import '../providers/queue_provider.dart';

class QueueDashboardScreen extends StatefulWidget {
  const QueueDashboardScreen({super.key});

  @override
  State<QueueDashboardScreen> createState() => _QueueDashboardScreenState();
}

class _QueueDashboardScreenState extends State<QueueDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final queueProvider = Provider.of<QueueProvider>(context, listen: false);
      queueProvider.fetchQueues(DateTime.now());
      queueProvider.setupRealtimeSubscription(DateTime.now());
    });
  }

  // Dummy data for fallback
  final List<QueueModel> _dummyQueues = [
    QueueModel(
      id: '1',
      queueNumber: 'A001',
      patientName: 'Ahmad Rizki',
      serviceType: 'Imunisasi',
      status: 'ongoing',
      createdAt: DateTime.now(),
      userId: '1',
    ),
    QueueModel(
      id: '2',
      queueNumber: 'A002',
      patientName: 'Siti Nurhaliza',
      serviceType: 'Penimbangan',
      status: 'waiting',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      userId: '2',
    ),
    QueueModel(
      id: '3',
      queueNumber: 'A003',
      patientName: 'Budi Santoso',
      serviceType: 'Konsultasi',
      status: 'waiting',
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      userId: '3',
    ),
    QueueModel(
      id: '4',
      queueNumber: 'B001',
      patientName: 'Ani Wijaya',
      serviceType: 'Imunisasi',
      status: 'waiting',
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      userId: '4',
    ),
    QueueModel(
      id: '5',
      queueNumber: 'B002',
      patientName: 'Dewi Lestari',
      serviceType: 'Tinggi Badan',
      status: 'waiting',
      createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
      userId: '5',
    ),
  ];

  String _selectedFilter = 'Semua';

  List<QueueModel> _getFilteredQueues(List<QueueModel> queues) {
    if (_selectedFilter == 'Semua') return queues;
    if (_selectedFilter == 'Sedang Dilayani') {
      return queues.where((q) => q.status == 'ongoing').toList();
    }
    if (_selectedFilter == 'Menunggu') {
      return queues.where((q) => q.status == 'waiting').toList();
    }
    return queues;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QueueProvider>(
      builder: (context, queueProvider, child) {
        // Gunakan data dari provider atau dummy jika kosong
        var sourceQueues = queueProvider.queues.isEmpty
            ? _dummyQueues
            : List<QueueModel>.from(queueProvider.queues);

        // Sorting: Sedang Dilayani paling atas, sisanya urut nomor antrian
        sourceQueues.sort((a, b) {
          if (a.status == 'ongoing' && b.status != 'ongoing') return -1;
          if (a.status != 'ongoing' && b.status == 'ongoing') return 1;
          return a.queueNumber.compareTo(b.queueNumber);
        });

        final filteredQueues = _getFilteredQueues(sourceQueues);
        final ongoingCount = sourceQueues
            .where((q) => q.status == 'ongoing')
            .length;
        final waitingCount = sourceQueues
            .where((q) => q.status == 'waiting')
            .length;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text('Dashboard Antrian'),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () {
                  queueProvider.fetchQueues(DateTime.now());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data diperbarui'),
                      duration: Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Summary Cards
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Sedang Dilayani',
                        ongoingCount.toString(),
                        Icons.medical_services_rounded,
                        const Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        'Menunggu',
                        waitingCount.toString(),
                        Icons.hourglass_empty_rounded,
                        const Color(0xFFFF9800),
                      ),
                    ),
                  ],
                ),
              ),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildFilterChip('Semua', sourceQueues.length),
                    _buildFilterChip('Sedang Dilayani', ongoingCount),
                    _buildFilterChip('Menunggu', waitingCount),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Queue List
              Expanded(
                child: filteredQueues.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 80,
                              color: AppTheme.subTextColor.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada antrian',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.subTextColor,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filteredQueues.length,
                        itemBuilder: (context, index) {
                          final queue = filteredQueues[index];
                          return _buildQueueCard(queue);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            count,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 13, color: AppTheme.subTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: FilterChip(
        label: Text('$label ($count)'),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = label;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryColor : AppTheme.textColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
    );
  }

  Widget _buildQueueCard(QueueModel queue) {
    final isOngoing = queue.status == 'ongoing';
    final isCompleted = queue.status == 'completed';

    Color statusColor;
    String statusText;

    if (isOngoing) {
      statusColor = const Color(0xFF4CAF50);
      statusText = 'Sedang Dilayani';
    } else if (isCompleted) {
      statusColor = Colors.grey;
      statusText = 'Selesai';
    } else {
      statusColor = const Color(0xFFFF9800);
      statusText = 'Menunggu';
    }

    final timeFormat = DateFormat('HH:mm', 'id_ID');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOngoing
              ? statusColor.withValues(alpha: 0.3)
              : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Queue Number Badge
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  queue.queueNumber,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Patient Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    queue.patientName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.medical_services_outlined,
                        size: 16,
                        color: AppTheme.subTextColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          queue.serviceType,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.subTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: AppTheme.subTextColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          timeFormat.format(queue.createdAt),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.subTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
