// providers/auth_provider.dart
import 'package:flutter/material.dart';
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
  void _loadUser() {
    final session = _supabase.auth.currentSession;
    final currentUser = _supabase.auth.currentUser;

    if (session != null && currentUser != null) {
      _user = _mapSupabaseUserToModel(currentUser);
      notifyListeners();
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
        _user = _mapSupabaseUserToModel(response.user!);
        notifyListeners();
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
  Future<bool> register(
    String name,
    String email,
    String password,
    DateTime dob,
  ) async {
    try {
      // Kita simpan Nama dan Tgl Lahir di "User Metadata"
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name,
          'dob': dob.toIso8601String(),
        },
      );

      if (response.user != null) {
        _user = _mapSupabaseUserToModel(response.user!);
        notifyListeners();
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

  // Fungsi Logout
  Future<void> logout() async {
    await _supabase.auth.signOut();
    _user = null;
    notifyListeners();
  }

  // Helper: Mengubah User dari Supabase menjadi UserModel aplikasi kita
  UserModel _mapSupabaseUserToModel(User supabaseUser) {
    final metadata = supabaseUser.userMetadata;
    
    return UserModel(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      // Ambil nama dari metadata, jika kosong pakai 'Pengguna'
      name: metadata?['full_name'] ?? 'Pengguna',
      // Ambil tgl lahir dari metadata
      dateOfBirth: metadata?['dob'] != null 
          ? DateTime.tryParse(metadata!['dob']) 
          : null,
      password: '', // Password tidak kita simpan di lokal demi keamanan
    );
  }
}