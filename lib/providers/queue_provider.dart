// providers/queue_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/queue_model.dart';

class QueueProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<QueueModel> _queues = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<QueueModel> get queues => _queues;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get next queue number untuk tanggal tertentu
  Future<String> getNextQueueNumber(DateTime date) async {
    try {
      final dateString = date.toIso8601String().split('T')[0]; // YYYY-MM-DD

      // Hitung jumlah reservasi pada tanggal tersebut
      final response = await _supabase
          .from('reservations')
          .select('id')
          .eq('reservation_date', dateString)
          .count(CountOption.exact);

      final count = response.count;
      final nextNumber = count + 1;

      // Format A001, A002, dst
      return 'A${nextNumber.toString().padLeft(3, '0')}';
    } catch (e) {
      debugPrint('Get next queue error: $e');
      return 'A001';
    }
  }

  // Check duplicate reservation
  Future<bool> hasReservation(String userId, DateTime date) async {
    try {
      final dateString = date.toIso8601String().split('T')[0];
      final response = await _supabase
          .from('reservations')
          .select('id')
          .eq('user_id', userId)
          .eq('reservation_date', dateString)
          .maybeSingle();

      return response != null;
    } catch (e) {
      debugPrint('Check duplicate error: $e');
      return false;
    }
  }

  // Create new queue reservation
  Future<bool> createQueue({
    required String patientName,
    required String serviceType,
    required DateTime reservationDate,
    required String queueTime,
    required String userId,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // 1. Check duplicate
      final isDuplicate = await hasReservation(userId, reservationDate);
      if (isDuplicate) {
        throw Exception(
          'Anda sudah memiliki reservasi untuk tanggal ini. Silakan pilih tanggal lain.',
        );
      }

      // 2. Get next queue number
      final queueNumber = await getNextQueueNumber(reservationDate);
      final dateString = reservationDate.toIso8601String().split('T')[0];

      final reservationData = {
        'queue_number': queueNumber,
        'child_name': patientName, // Map patientName to child_name
        'service_type': serviceType,
        'status': 'waiting', // Pastikan kolom status ada di tabel reservations
        'user_id': userId,
        'reservation_date': dateString,
        'queue_time': queueTime,
      };

      await _supabase.from('reservations').insert(reservationData);

      await fetchQueues(reservationDate);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Create queue error: $e');
      rethrow; // Rethrow agar UI bisa menangkap pesan error
    }
  }

  // Fetch queues untuk tanggal tertentu
  Future<void> fetchQueues(DateTime date) async {
    try {
      _isLoading = true;
      notifyListeners();

      final dateString = date.toIso8601String().split('T')[0];

      final response = await _supabase
          .from('reservations')
          .select()
          .eq('reservation_date', dateString)
          .order('queue_number', ascending: true);

      _queues = (response as List).map((json) {
        // Mapping dari tabel reservations ke QueueModel
        return QueueModel(
          id: json['id'].toString(),
          queueNumber: json['queue_number'] ?? '-',
          patientName: json['child_name'] ?? '-',
          serviceType: json['service_type'] ?? '-',
          status: json['status'] ?? 'waiting',
          createdAt: DateTime.parse(json['created_at']),
          userId: json['user_id'] ?? '',
        );
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Fetch queues error: $e');
    }
  }

  // Update queue status
  Future<bool> updateQueueStatus(String queueId, String status) async {
    try {
      await _supabase
          .from('reservations')
          .update({'status': status})
          .eq('id', queueId);

      // Refresh local state
      final updatedList = _queues.map((q) {
        if (q.id == queueId) {
          return QueueModel(
            id: q.id,
            queueNumber: q.queueNumber,
            patientName: q.patientName,
            serviceType: q.serviceType,
            status: status,
            createdAt: q.createdAt,
            userId: q.userId,
          );
        }
        return q;
      }).toList();

      _queues = updatedList;
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Update status error: $e');
      return false;
    }
  }

  // Setup real-time subscription
  void setupRealtimeSubscription(DateTime date) {
    _supabase
        .channel('reservations_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'reservations',
          callback: (payload) {
            fetchQueues(date);
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _supabase.channel('reservations_channel').unsubscribe();
    super.dispose();
  }
}
