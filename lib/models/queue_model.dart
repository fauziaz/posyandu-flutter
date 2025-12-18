// models/queue_model.dart
class QueueModel {
  final String id;
  final String queueNumber;
  final String patientName;
  final String serviceType;
  final String status; // waiting, ongoing, completed
  final DateTime createdAt;
  final String userId;

  QueueModel({
    required this.id,
    required this.queueNumber,
    required this.patientName,
    required this.serviceType,
    required this.status,
    required this.createdAt,
    required this.userId,
  });

  factory QueueModel.fromJson(Map<String, dynamic> json) {
    return QueueModel(
      id: json['id'] as String,
      queueNumber: json['queue_number'] as String,
      patientName: json['patient_name'] as String,
      serviceType: json['service_type'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      userId: json['user_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'queue_number': queueNumber,
      'patient_name': patientName,
      'service_type': serviceType,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
    };
  }
}
