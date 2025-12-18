// providers/article_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/article_model.dart';

class ArticleProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<ArticleModel> _articles = [];
  bool _isLoading = false;

  List<ArticleModel> get articles => _articles;
  bool get isLoading => _isLoading;

  Future<void> fetchArticles() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _supabase
          .from('articles')
          .select()
          .order('created_at', ascending: false);

      _articles = (response as List)
          .map((e) => ArticleModel.fromJson(e))
          .toList();
    } catch (e) {
      debugPrint('Error fetching articles: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
