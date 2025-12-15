// models/schedule_model.dart

class ScheduleModel {
  final String id;
  final String serviceName;
  final String location;
  final DateTime scheduleDate;
  final String startTime;
  final String endTime;

  ScheduleModel({
    required this.id,
    required this.serviceName,
    required this.location,
    required this.scheduleDate,
    required this.startTime,
    required this.endTime,
  });

  factory ScheduleModel.fromMap(Map<String, dynamic> map) {
    return ScheduleModel(
      id: map['id'],
      serviceName: map['service_name'],
      location: map['location'],
      scheduleDate: DateTime.parse(map['schedule_date']),
      // Supabase time format is HH:MM:SS, kita ambil 5 karakter awal (HH:MM)
      startTime: map['start_time'].toString().substring(0, 5), 
      endTime: map['end_time'].toString().substring(0, 5),
    );
  }
}