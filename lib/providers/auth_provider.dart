// providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isAuthenticated = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;

  final _supabase = Supabase.instance.client;

  // Check if user is already logged in
  Future<void> checkAuthStatus() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session != null) {
        await _loadUserProfile(session.user.id);
      }
    } catch (e) {
      _errorMessage = e.toString();
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
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _errorMessage = null;
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadUserProfile(response.user!.id);
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> register(
    String name,
    String email,
    String password,
    DateTime dob,
  ) async {
    try {
      _errorMessage = null;

      // Register user with Supabase Auth
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Create user profile in database
        final userProfile = {
          'id': response.user!.id,
          'name': name,
          'email': email,
          'date_of_birth': dob.toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
        };

        await _supabase.from('users').insert(userProfile);

        // Load the user profile
        await _loadUserProfile(response.user!.id);
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      print('Registration error: $e'); // Debug print
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      _user = null;
      _isAuthenticated = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }
}
