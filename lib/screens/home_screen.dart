// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/queue_provider.dart';
import '../providers/article_provider.dart';
import '../screens/history_screen.dart';
import '../screens/schedule_screen.dart';
import '../screens/article_list_screen.dart';
import '../screens/queue_dashboard_screen.dart';
import '../screens/reservation_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/article_detail_screen.dart';
import '../screens/faq_screen.dart';
import '../screens/about_screen.dart';
import '../screens/contact_screen.dart';
import '../utils/theme.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<QueueProvider>(
        context,
        listen: false,
      ).fetchQueues(DateTime.now());
      Provider.of<ArticleProvider>(context, listen: false).fetchArticles();
    });
  }

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
                  Row(
                    children: [
                      // Profile Picture
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.primaryColor,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white,
                            backgroundImage: user?.avatarUrl != null
                                ? NetworkImage(user!.avatarUrl!)
                                : null,
                            child: user?.avatarUrl == null
                                ? const Icon(
                                    Icons.person,
                                    color: AppTheme.primaryColor,
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Menu Button
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: AppTheme.textColor,
                          size: 28,
                        ),
                        onSelected: (value) {
                          if (value == 'FAQ') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FAQScreen(),
                              ),
                            );
                          } else if (value == 'Tentang Kami') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AboutScreen(),
                              ),
                            );
                          } else if (value == 'Hubungi Kami') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ContactScreen(),
                              ),
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'FAQ', child: Text('FAQ')),
                          const PopupMenuItem(
                            value: 'Tentang Kami',
                            child: Text('Tentang Kami'),
                          ),
                          const PopupMenuItem(
                            value: 'Hubungi Kami',
                            child: Text('Hubungi Kami'),
                          ),
                        ],
                      ),
                    ],
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReservationScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuCard(
                    context,
                    'Profil\nAkun',
                    Icons.person_outline_rounded,
                    const Color(0xFFFFF3E0),
                    const Color(0xFFFF9800),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuCard(
                    context,
                    'Dashboard\nAntrian',
                    Icons.dashboard_outlined,
                    const Color(0xFFFCE4EC),
                    const Color(0xFFE91E63),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const QueueDashboardScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuCard(
                    context,
                    'Riwayat\nPemeriksaan',
                    Icons.history_edu_rounded,
                    const Color(0xFFE0F2F1),
                    const Color(0xFF009688),
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

              // Antrian Hari Ini Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Antrian Hari Ini',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QueueDashboardScreen(),
                        ),
                      );
                    },
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildQueueSection(context),
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ArticleListScreen(),
                        ),
                      );
                    },
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Consumer<ArticleProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (provider.articles.isEmpty) {
                    return const Center(child: Text('Belum ada artikel'));
                  }
                  // Show max 3 articles
                  final articles = provider.articles.take(3).toList();
                  return Column(
                    children: articles.map((article) {
                      return _buildArticleCard(
                        context,
                        article.title,
                        article.excerpt,
                        article.imageUrl,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ArticleDetailScreen(
                                id: article.id,
                                title: article.title,
                                content: article.content,
                                category: article.category,
                                imagePath: article.imageUrl,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  );
                },
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

  Widget _buildQueueSection(BuildContext context) {
    return Consumer<QueueProvider>(
      builder: (context, queueProvider, child) {
        // Fetch queues for today on first build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (queueProvider.queues.isEmpty) {
            queueProvider.fetchQueues(DateTime.now());
            queueProvider.setupRealtimeSubscription(DateTime.now());
          }
        });

        final todayQueues = queueProvider.queues.take(5).toList();

        if (todayQueues.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
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
                Icon(
                  Icons.inbox_outlined,
                  size: 48,
                  color: AppTheme.subTextColor.withOpacity(0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'Belum ada antrian hari ini',
                  style: TextStyle(fontSize: 14, color: AppTheme.subTextColor),
                ),
              ],
            ),
          );
        }

        return Container(
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
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE91E63),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Antrian',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Hari Ini',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${queueProvider.queues.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Queue List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: todayQueues.length,
                separatorBuilder: (context, index) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  final queue = todayQueues[index];
                  final statusColor = queue.status == 'ongoing'
                      ? const Color(0xFFE91E63)
                      : queue.status == 'waiting'
                      ? const Color(0xFFFCE4EC)
                      : Colors.grey;
                  final statusText = queue.status == 'ongoing'
                      ? 'Dilayani'
                      : queue.status == 'waiting'
                      ? 'Menunggu'
                      : 'Selesai';

                  return Row(
                    children: [
                      // Queue Number
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [statusColor, statusColor.withOpacity(0.7)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            queue.queueNumber,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Info
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
                            ),
                            const SizedBox(height: 4),
                            Text(
                              queue.serviceType,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.subTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildArticleCard(
    BuildContext context,
    String title,
    String subtitle,
    String imagePath, {
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    imagePath,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  ),
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
                        style: TextStyle(
                          color: AppTheme.subTextColor,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
