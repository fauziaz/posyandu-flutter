// providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  // Instance client Supabase
  final SupabaseClient _supabase = Supabase.instance.client;

  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _loadUser();
  }

  // Cek apakah user sudah login sebelumnya (Session persistence)
  void _loadUser() async {
    final session = _supabase.auth.currentSession;
    final currentUser = _supabase.auth.currentUser;

    if (session != null && currentUser != null) {
      await _loadUserProfile(currentUser.id);
    }
  }

  // Load user profile from database
  Future<void> _loadUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      _user = UserModel.fromJson(response);
      notifyListeners();
    } catch (e) {
      debugPrint('Load Profile Error: $e');
    }
  }

  // Fungsi Login ke Supabase
  Future<bool> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadUserProfile(response.user!.id);
        return true;
      }
      return false;
    } on AuthException catch (e) {
      debugPrint('Auth Error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Unexpected Error: $e');
      return false;
    }
  }

  // Fungsi Register ke Supabase
  // Fungsi Register ke Supabase
  Future<bool> register(
    String name,
    String email,
    String password,
    DateTime dob,
  ) async {
    try {
      // Register user dengan Supabase Auth
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Simpan user profile ke tabel users
        final userProfile = {
          'id': response.user!.id,
          'name': name,
          'email': email,
          'date_of_birth': dob.toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
        };

        await _supabase.from('users').insert(userProfile);

        // Load user profile
        await _loadUserProfile(response.user!.id);
        return true;
      }
      return false;
    } on AuthException catch (e) {
      debugPrint('Register Error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Unexpected Error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Logout Error: $e');
    }
  }

  Future<String?> updateProfile({
    required String name,
    required String phoneNumber,
    required DateTime? dateOfBirth,
    String? avatarUrl,
  }) async {
    try {
      if (_user == null) return 'User tidak ditemukan';

      final updates = {
        'name': name,
        'phone_number': phoneNumber,
        'date_of_birth': dateOfBirth?.toIso8601String(),
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        // 'updated_at': DateTime.now().toIso8601String(), // Optional if you have this column
      };

      await _supabase.from('users').update(updates).eq('id', _user!.id);
      await _loadUserProfile(_user!.id);
      return null; // Berhasil
    } catch (e) {
      debugPrint('Update Profile Error: $e');
      return e.toString(); // Gagal, kembalikan pesan error
    }
  }

  Future<String?> uploadAvatar(Uint8List bytes, String fileExtension) async {
    try {
      if (_user == null) return null;

      final fileName =
          '${_user!.id}/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      await _supabase.storage
          .from('avatars')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final imageUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      debugPrint('Upload Avatar Error: $e');
      return null;
    }
  }

  Future<String?> updateEmail(String newEmail) async {
    try {
      final response = await _supabase.auth.updateUser(
        UserAttributes(email: newEmail),
      );
      if (response.user != null) {
        // Update juga di tabel users public
        await _supabase
            .from('users')
            .update({'email': newEmail})
            .eq('id', _user!.id);
        await _loadUserProfile(_user!.id);
        return null;
      }
      return 'Gagal update email';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
