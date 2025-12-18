// screens/about_screen.dart
import 'package:flutter/material.dart';
import '../utils/theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  final List<String> _galleryImages = const [
    'screenshots/WhatsApp Image 2025-06-02 at 19.31.32_e6a65921.jpg',
    'screenshots/WhatsApp Image 2025-06-02 at 19.31.33_6bdfc6c1.jpg',
    'screenshots/WhatsApp Image 2025-06-02 at 19.31.34_7bf91430.jpg',
    'screenshots/WhatsApp Image 2025-06-02 at 19.31.35_d063c01d.jpg',
    'screenshots/WhatsApp Image 2025-06-02 at 19.31.37_26f271e6.jpg',
    'screenshots/WhatsApp Image 2025-06-02 at 19.31.37_3a7cf332.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Tentang Kami',
          style: TextStyle(color: AppTheme.textColor),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textColor),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image or Logo
            Container(
              width: double.infinity,
              height: 200,
              color: AppTheme.primaryColor.withOpacity(0.1),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'screenshots/logoposyandu.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.local_hospital,
                          size: 64,
                          color: AppTheme.primaryColor,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'POSYANDU HARAPAN BUNDA',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  const Text(
                    'Tentang Posyandu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Posyandu Harapan Bunda adalah posyandu yang terletak di Dusun Cilombang, Desa Lumbir, Kecamatan Lumbir, Kabupaten Banyumas. Posyandu ini berkomitmen untuk memberikan pelayanan kesehatan terbaik bagi ibu dan balita di lingkungan kami.\n\nGuna meningkatkan kualitas layanan, Posyandu Harapan Bunda kini menghadirkan inovasi digital melalui Sistem Informasi Manajemen Posyandu Harapan Bunda (SIMPHB). Sistem ini dirancang untuk mempermudah pendataan, mempercepat akses informasi, dan memastikan setiap warga mendapatkan pemantauan kesehatan yang lebih akurat dan efisien.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppTheme.subTextColor,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 24),

                  // Gallery
                  const Text(
                    'Galeri Kegiatan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1,
                        ),
                    itemCount: _galleryImages.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          _galleryImages[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Location / Map
                  const Text(
                    'Lokasi Kami',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Stack(
                      children: [
                        // Map Image (Placeholder)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            'https://img.freepik.com/free-vector/city-map-navigation-gps-tracking-concept_23-2148754273.jpg',
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.map_outlined,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Posyandu Harapan Bunda, Dusun Cilombang, Desa Lumbir, Kecamatan Lumbir, Kabupaten Banyumas',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
