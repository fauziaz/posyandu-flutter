// models/user_model.dart
class UserModel {
  final String id;
  final String name;
  final String email;
  final DateTime? dateOfBirth;
  final String? phoneNumber;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.dateOfBirth,
    this.phoneNumber,
    this.createdAt,
  });

  // Konversi dari JSON (dari Supabase)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      phoneNumber: json['phone_number'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  // Konversi ke JSON (untuk Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'phone_number': phoneNumber,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
