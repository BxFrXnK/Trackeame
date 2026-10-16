import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../models/habit_model.dart';
import '../repositories/interfaces/i_habit_repository.dart';

class HabitController extends ChangeNotifier {
  final IHabitRepository _repository;

  List<HabitModel> _habits = [];
  bool _isLoading = false;

  HabitController(this._repository);

  // Getters para que la vista lea el estado sin modificarlo directamente
  List<HabitModel> get habits => _habits;
  bool get isLoading => _isLoading;

  // Formateador estándar de fecha: "YYYY-MM-DD"
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // 1. Cargar hábitos desde la base de datos
  Future<void> loadHabits() async {
    _isLoading = true;
    notifyListeners();

    try {
      _habits = await _repository.getHabits();
    } catch (e) {
      debugPrint('Error al cargar hábitos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Marcar o Desmarcar un hábito para el día de hoy (o una fecha específica)
  Future<void> toggleHabitToday(String habitId, {DateTime? targetDate}) async {
    final date = targetDate ?? DateTime.now();
    final dateStr = _formatDate(date);

    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) return;

    final habit = _habits[index];
    final updatedDates = List<String>.from(habit.completedDates);

    if (updatedDates.contains(dateStr)) {
      updatedDates.remove(dateStr);
    } else {
      updatedDates.add(dateStr);
    }

    // Recalcular racha actual y mejor racha
    final newStreak = _calculateCurrentStreak(updatedDates, habit.daysOfWeek);
    final newBestStreak = newStreak > habit.bestStreak
        ? newStreak
        : habit.bestStreak;

    final updatedHabit = habit.copyWith(
      completedDates: updatedDates,
      currentStreak: newStreak,
      bestStreak: newBestStreak,
    );

    // Actualizamos localmente y en SQLite a través de la interfaz
    _habits[index] = updatedHabit;
    notifyListeners();

    await _repository.updateHabit(updatedHabit);
  }

  // 3. Crear un nuevo hábito
  Future<void> addHabit({
    required String title,
    String description = '',
    required String colorHex,
    required List<int> daysOfWeek,
  }) async {
    final newHabit = HabitModel(
      title: title,
      description: description,
      colorHex: colorHex,
      daysOfWeek: daysOfWeek,
    );

    _habits.add(newHabit);
    notifyListeners();

    await _repository.insertHabit(newHabit);
  }

  // 4. Actualizar un hábito existente
  Future<void> updateHabit(HabitModel updatedHabit) async {
    final index = _habits.indexWhere((h) => h.id == updatedHabit.id);
    if (index == -1) return;

    _habits[index] = updatedHabit;
    notifyListeners();

    await _repository.updateHabit(updatedHabit);
  }

  // 5. Eliminar un hábito
  Future<void> deleteHabit(String habitId) async {
    _habits.removeWhere((h) => h.id == habitId);
    notifyListeners();

    await _repository.deleteHabit(habitId);
  }

  // 6. Lógica para calcular la racha de días consecutivos
  int _calculateCurrentStreak(
    List<String> completedDates,
    List<int> daysOfWeek,
  ) {
    if (completedDates.isEmpty) return 0;

    final sortedDates = completedDates.map((d) => DateTime.parse(d)).toList()
      ..sort((a, b) => b.compareTo(a)); // Orden descendente

    int streak = 0;
    DateTime checkDate = DateTime.now();
    final todayStr = _formatDate(checkDate);
    final yesterdayStr = _formatDate(
      checkDate.subtract(const Duration(days: 1)),
    );

    // Si hoy no está completado pero ayer sí, comenzamos la verificación desde ayer
    if (!completedDates.contains(todayStr) &&
        completedDates.contains(yesterdayStr)) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    } else if (!completedDates.contains(todayStr)) {
      return 0;
    }

    while (true) {
      final currentStr = _formatDate(checkDate);
      if (completedDates.contains(currentStr)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }
}
