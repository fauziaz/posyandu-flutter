// providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isAuthenticated = false;

  UserModel? get user => _user;
  bool get isAuthenticated => _isAuthenticated;

  // Mock database
  final List<UserModel> _mockUsers = [];

  Future<bool> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Simple mock check
      final user = _mockUsers.firstWhere(
        (u) => u.email == email && u.password == password,
        orElse: () => throw Exception('User not found'),
      );

      _user = user;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(
    String name,
    String email,
    String password,
    DateTime dob,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    // Check if email already exists
    if (_mockUsers.any((u) => u.email == email)) {
      return false;
    }

    final newUser = UserModel(
      id: DateTime.now().toString(),
      name: name,
      email: email,
      password: password,
      dateOfBirth: dob,
    );

    _mockUsers.add(newUser);

    // Auto login after register
    _user = newUser;
    _isAuthenticated = true;
    notifyListeners();
    return true;
  }

  void logout() {
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
