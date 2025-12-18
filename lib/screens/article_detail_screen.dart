// screens/article_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/theme.dart';
import '../providers/bookmark_provider.dart';

class ArticleDetailScreen extends StatelessWidget {
  final String? id;
  final String title;
  final String content;
  final String category;
  final String imagePath;

  const ArticleDetailScreen({
    super.key,
    this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.imagePath,
  });

  Future<void> _launchURL(BuildContext context) async {
    final Uri url = Uri.parse('https://www.kemkes.go.id/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            // Modern Hero Header
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              stretch: true,
              elevation: 0,
              backgroundColor: Colors.white,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppTheme.textColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image Background
                    imagePath.startsWith('http')
                        ? Image.network(
                            imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          )
                        : Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                    // Overlay Gradient for text readability
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    // Bottom Fade
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 100,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppTheme.backgroundColor,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Badge with Modern Style
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.category_outlined,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                category,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Share Button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.share_outlined),
                            color: AppTheme.textColor,
                            onPressed: () => _launchURL(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Bookmark Button
                        if (id != null)
                          Consumer<BookmarkProvider>(
                            builder: (context, bookmarkProvider, child) {
                              final isBookmarked = bookmarkProvider
                                  .isBookmarked(id!);
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    isBookmarked
                                        ? Icons.bookmark_rounded
                                        : Icons.bookmark_outline_rounded,
                                  ),
                                  color: isBookmarked
                                      ? AppTheme.primaryColor
                                      : AppTheme.textColor,
                                  onPressed: () {
                                    bookmarkProvider.toggleBookmark(id!);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isBookmarked
                                              ? 'Dihapus dari bookmark'
                                              : 'Disimpan ke bookmark',
                                        ),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Title with Modern Typography
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                        height: 1.3,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Reading Time & Date
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: AppTheme.subTextColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '5 menit baca',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.subTextColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: AppTheme.subTextColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '15 Des 2025',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.subTextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Main Content Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            content,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.8,
                              color: AppTheme.textColor,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Modern Content Sections
                    _buildModernSection(
                      '🎯 Manfaat Utama',
                      'Artikel ini memberikan informasi penting untuk kesehatan dan tumbuh kembang anak. Dengan mengikuti panduan yang tepat, anak dapat tumbuh optimal sesuai tahapan usianya.',
                      const Color(0xFF4CAF50),
                    ),

                    _buildModernSection(
                      '💡 Tips Praktis',
                      '• Konsultasi rutin dengan dokter atau bidan\n• Ikuti jadwal imunisasi yang telah ditentukan\n• Berikan asupan gizi seimbang setiap hari\n• Pantau pertumbuhan dan perkembangan anak\n• Jaga kebersihan dan kesehatan lingkungan',
                      const Color(0xFF2196F3),
                    ),

                    _buildModernSection(
                      '✨ Kesimpulan',
                      'Peran orang tua sangat penting dalam memastikan kesehatan dan tumbuh kembang anak optimal. Jangan ragu untuk berkonsultasi dengan tenaga kesehatan di posyandu terdekat.',
                      const Color(0xFFFF9800),
                    ),

                    // Call to Action
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withOpacity(0.1),
                            AppTheme.primaryColor.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.medical_services_outlined,
                            size: 48,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Butuh Konsultasi?',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Kunjungi posyandu terdekat atau buat reservasi online',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.subTextColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Buat Reservasi',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernSection(String title, String content, Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: accentColor,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.7,
              color: AppTheme.textColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Dot Pattern
class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    const spacing = 20.0;
    const dotRadius = 2.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
