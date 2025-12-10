// models/user_model.dart
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? password; // In a real app, never store plain passwords
  final DateTime? dateOfBirth;
  final String? phoneNumber;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.password,
    this.dateOfBirth,
    this.phoneNumber,
  });
}
