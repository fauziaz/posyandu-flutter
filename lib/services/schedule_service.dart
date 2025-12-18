// services/schedule_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/schedule_model.dart';

class ScheduleService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ScheduleModel>> getSchedules() async {
    try {
      // Ambil tanggal hari ini (YYYY-MM-DD)
      final now = DateTime.now();
      // Kita ambil H-1 untuk menghindari masalah zona waktu
      final yesterday = now.subtract(const Duration(days: 1));
      final dateString = yesterday.toIso8601String().split('T')[0];

      final response = await _supabase
          .from('schedules')
          .select()
          .gte(
            'schedule_date',
            dateString,
          ) // Ambil jadwal mulai kemarin ke depan
          .order('schedule_date', ascending: true)
          .order('start_time', ascending: true);

      return (response as List)
          .map((data) => ScheduleModel.fromMap(data))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil jadwal: $e');
    }
  }
}
