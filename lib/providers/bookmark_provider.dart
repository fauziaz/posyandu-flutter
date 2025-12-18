// providers/bookmark_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/article_model.dart';

class BookmarkProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<String> _bookmarkedArticleIds = [];
  List<ArticleModel> _bookmarkedArticles = [];
  bool _isLoading = false;

  List<String> get bookmarkedArticleIds => _bookmarkedArticleIds;
  List<ArticleModel> get bookmarkedArticles => _bookmarkedArticles;
  bool get isLoading => _isLoading;

  // Fetch bookmarks from Supabase
  Future<void> fetchBookmarks() async {
    try {
      _isLoading = true;
      notifyListeners();

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Get bookmarked article IDs
      final response = await _supabase
          .from('bookmarks')
          .select('article_id')
          .eq('user_id', userId);

      _bookmarkedArticleIds = (response as List)
          .map((e) => e['article_id'] as String)
          .toList();

      // If we have bookmarks, fetch the actual articles
      if (_bookmarkedArticleIds.isNotEmpty) {
        final articlesResponse = await _supabase
            .from('articles')
            .select()
            .filter('id', 'in', _bookmarkedArticleIds);

        _bookmarkedArticles = (articlesResponse as List)
            .map((e) => ArticleModel.fromJson(e))
            .toList();
      } else {
        _bookmarkedArticles = [];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching bookmarks: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle bookmark
  Future<void> toggleBookmark(String articleId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      if (_bookmarkedArticleIds.contains(articleId)) {
        // Remove bookmark
        await _supabase
            .from('bookmarks')
            .delete()
            .eq('user_id', userId)
            .eq('article_id', articleId);

        _bookmarkedArticleIds.remove(articleId);
        _bookmarkedArticles.removeWhere((a) => a.id == articleId);
      } else {
        // Add bookmark
        await _supabase.from('bookmarks').insert({
          'user_id': userId,
          'article_id': articleId,
        });

        _bookmarkedArticleIds.add(articleId);
        // Note: We should ideally fetch the article details here or pass the article object
        // For now, we'll refresh the list next time or let the UI handle it
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling bookmark: $e');
      // Revert state on error if needed
    }
  }

  bool isBookmarked(String articleId) {
    return _bookmarkedArticleIds.contains(articleId);
  }
}
