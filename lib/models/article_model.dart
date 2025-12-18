// models/article_model.dart
class ArticleModel {
  final String id;
  final String title;
  final String excerpt;
  final String content;
  final String category;
  final String imageUrl;
  final DateTime publishedAt;

  ArticleModel({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.content,
    required this.category,
    required this.imageUrl,
    required this.publishedAt,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'] as String,
      title: json['title'] as String,
      excerpt: json['excerpt'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      imageUrl: json['image_url'] as String? ?? '',
      publishedAt: DateTime.parse(json['published_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'excerpt': excerpt,
      'content': content,
      'category': category,
      'image_url': imageUrl,
      'published_at': publishedAt.toIso8601String(),
    };
  }
}
