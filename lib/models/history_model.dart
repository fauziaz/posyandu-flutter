// models/history_model.dart
class HistoryModel {
  final DateTime date;
  final double weight;
  final double height;
  final double? headCircumference;
  final String? immunization;
  final String? vitamin;
  final String? notes;

  HistoryModel({
    required this.date,
    required this.weight,
    required this.height,
    this.headCircumference,
    this.immunization,
    this.vitamin,
    this.notes,
  });

  factory HistoryModel.fromMap(Map<String, dynamic> map) {
    return HistoryModel(
      date: DateTime.parse(map['date']),
      weight: (map['weight'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
      headCircumference: map['head_circumference'] != null
          ? (map['head_circumference'] as num).toDouble()
          : null,
      immunization: map['immunization'],
      vitamin: map['vitamin'],
      notes: map['notes'],
    );
  }
}
