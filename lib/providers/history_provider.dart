// providers/history_provider.dart
import 'package:flutter/material.dart';
import '../models/history_model.dart';
import '../services/history_service.dart';

class HistoryProvider with ChangeNotifier {
  final HistoryService _service = HistoryService();
  
  List<HistoryModel> _historyList = [];
  bool _isLoading = false;

  List<HistoryModel> get historyList => _historyList;
  bool get isLoading => _isLoading;

  // Fungsi untuk mengambil data saat aplikasi dibuka
  Future<void> fetchHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      _historyList = await _service.getHistory();
    } catch (e) {
      debugPrint('Error fetching history: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fungsi untuk menambah data baru
  Future<bool> addHistory(HistoryModel data) async {
    try {
      await _service.addHistory(data);
      
      // Setelah berhasil simpan, ambil ulang data terbaru
      await fetchHistory(); 
      return true;
    } catch (e) {
      debugPrint('Error adding history: $e');
      return false;
    }
  }
}