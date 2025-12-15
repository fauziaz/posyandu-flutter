// services/schedule_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/schedule_model.dart';

class ScheduleService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ScheduleModel>> getSchedules() async {
    try {
      final response = await _supabase
          .from('schedules')
          .select()
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