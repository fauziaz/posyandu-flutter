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