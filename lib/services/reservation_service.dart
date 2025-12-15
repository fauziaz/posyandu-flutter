import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reservation_model.dart';
import 'package:intl/intl.dart';

class ReservationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. Mendapatkan Nomor Antrian Berikutnya (Dynamic A01, A02...)
  Future<String> getNextQueueNumber(DateTime date) async {
    try {
      // Format tanggal agar sesuai database (YYYY-MM-DD)
      final dateString = DateFormat('yyyy-MM-dd').format(date);

      // Hitung berapa reservasi yang sudah ada di tanggal tersebut
      final response = await _supabase
          .from('reservations')
          .select('id') // Kita hanya butuh hitung ID nya
          .eq('reservation_date', dateString)
          .count(CountOption.exact); // Request jumlah data
      
      final count = response.count; // Jumlah antrian saat ini
      
      // Nomor berikutnya = Jumlah saat ini + 1
      final nextNumber = count + 1;

      // Format menjadi "A01", "A02", ... "A10"
      // padLeft(2, '0') artinya jika angkanya 1 digit, tambahkan 0 di depan
      return 'A${nextNumber.toString().padLeft(2, '0')}';
    } catch (e) {
      // Jika error atau belum ada data, default ke A01
      return 'A01';
    }
  }

  // 2. Simpan Reservasi
  Future<void> createReservation(ReservationModel data) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      
      await _supabase.from('reservations').insert({
        'user_id': userId,
        ...data.toMap(), // Masukkan semua data model
      });
    } catch (e) {
      throw Exception('Gagal membuat reservasi: $e');
    }
  }
}