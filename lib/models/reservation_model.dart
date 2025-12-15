// models/reservation_model.dart

class ReservationModel {
  final String serviceType;
  final DateTime reservationDate;
  final String queueTime;
  final String childName;
  final String queueNumber;

  ReservationModel({
    required this.serviceType,
    required this.reservationDate,
    required this.queueTime,
    required this.childName,
    required this.queueNumber,
  });

  // Fungsi ini penting! Service menggunakannya untuk mengubah data 
  // menjadi format JSON yang dimengerti Supabase.
  Map<String, dynamic> toMap() {
    return {
      'service_type': serviceType,
      'reservation_date': reservationDate.toIso8601String(),
      'queue_time': queueTime,
      'child_name': childName,
      'queue_number': queueNumber,
    };
  }
}