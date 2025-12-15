// services/history_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/history_model.dart';

class HistoryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Nama tabel di database
  final String _tableName = 'history_pemeriksaan';

  // 1. Ambil Data (GET)
  Future<List<HistoryModel>> getHistory() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      
      final List<dynamic> response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false); // Urutkan dari yang terbaru

      return response.map((data) => HistoryModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data: $e');
    }
  }

  // 2. Tambah Data (POST)
  Future<void> addHistory(HistoryModel history) async {
    try {
      final userId = _supabase.auth.currentUser!.id;

      await _supabase.from(_tableName).insert({
        'user_id': userId,
        'date': history.date.toIso8601String(),
        'weight': history.weight,
        'height': history.height,
        'immunization': history.immunization,
      });
    } catch (e) {
      throw Exception('Gagal menyimpan data: $e');
    }
  }
}