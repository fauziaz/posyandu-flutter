class HistoryModel {
  final DateTime date;
  final double weight;
  final double height;
  final String? immunization;

  HistoryModel({
    required this.date,
    required this.weight,
    required this.height,
    this.immunization,
  });

  factory HistoryModel.fromMap(Map<String, dynamic> map) {
    return HistoryModel(
      date: DateTime.parse(map['date']),
      weight: (map['weight'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
      immunization: map['immunization'],
    );
  }
}