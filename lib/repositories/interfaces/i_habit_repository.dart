import '../../models/habit_model.dart';

abstract class IHabitRepository {
  Future<List<HabitModel>> getHabits();
  Future<HabitModel?> getHabitById(String id);
  Future<void> insertHabit(HabitModel habit);
  Future<void> updateHabit(HabitModel habit);
  Future<void> deleteHabit(String id);
}
