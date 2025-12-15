// providers/schedule_provider.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/schedule_model.dart';
import '../services/schedule_service.dart';

class ScheduleProvider with ChangeNotifier {
  final ScheduleService _service = ScheduleService();
  
  List<ScheduleModel> _schedules = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<ScheduleModel> get schedules => _schedules;

  // Getter untuk mengelompokkan data berdasarkan Tanggal
  // Hasilnya Map: { "Rabu, 17 April 2025": [Item1, Item2], ... }
  Map<String, List<ScheduleModel>> get groupedSchedules {
    Map<String, List<ScheduleModel>> data = {};
    
    for (var item in _schedules) {
      // Format tanggal header
      String dateKey = DateFormat('EEEE d MMMM yyyy', 'id_ID').format(item.scheduleDate);
      
      if (!data.containsKey(dateKey)) {
        data[dateKey] = [];
      }
      data[dateKey]!.add(item);
    }
    return data;
  }

  Future<void> fetchSchedules() async {
    _isLoading = true;
    notifyListeners();

    try {
      _schedules = await _service.getSchedules();
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}