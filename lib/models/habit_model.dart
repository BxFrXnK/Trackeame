import 'package:uuid/uuid.dart';

class HabitModel {
  final String id;
  final String title;
  final String description;
  final String colorHex; // Ej: "0xFFFFC107" (Amarillo), "0xFF2196F3" (Azul)
  final List<int> daysOfWeek;
  final List<String> completedDates; // Lista de fechas en formato "YYYY-MM-DD"
  final int currentStreak;
  final int bestStreak;
  final DateTime createdAt;

  HabitModel({
    String? id,
    required this.title,
    this.description = '',
    this.colorHex = '0xFF2196F3',
    required this.daysOfWeek,
    List<String>? completedDates,
    this.currentStreak = 0,
    this.bestStreak = 0,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       completedDates = completedDates ?? [],
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'colorHex': colorHex,
      'daysOfWeek': daysOfWeek.join(','),
      'completedDates': completedDates.join(','),
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory HabitModel.fromMap(Map<String, dynamic> map) {
    return HabitModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      colorHex: map['colorHex'] as String? ?? '0xFF2196F3',
      daysOfWeek:
          map['daysOfWeek'] != null && (map['daysOfWeek'] as String).isNotEmpty
          ? (map['daysOfWeek'] as String)
                .split(',')
                .map((e) => int.parse(e))
                .toList()
          : [],
      completedDates:
          map['completedDates'] != null &&
              (map['completedDates'] as String).isNotEmpty
          ? (map['completedDates'] as String).split(',')
          : [],
      currentStreak: map['currentStreak'] as int? ?? 0,
      bestStreak: map['bestStreak'] as int? ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  HabitModel copyWith({
    String? id,
    String? title,
    String? description,
    String? colorHex,
    List<int>? daysOfWeek,
    List<String>? completedDates,
    int? currentStreak,
    int? bestStreak,
    DateTime? createdAt,
  }) {
    return HabitModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      colorHex: colorHex ?? this.colorHex,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      completedDates: completedDates ?? this.completedDates,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
