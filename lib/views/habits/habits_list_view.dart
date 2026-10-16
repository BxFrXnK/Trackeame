import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'habit_detail_view.dart';

import '../../controllers/habit_controller.dart';
import '../../models/habit_model.dart';
import 'add_habit_view.dart';

class HabitsListView extends StatelessWidget {
  final HabitController habitController;

  const HabitsListView({super.key, required this.habitController});

  @override
  Widget build(BuildContext context) {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: habitController,
          builder: (context, _) {
            final habits = habitController.habits;

            return CustomScrollView(
              slivers: [
                // Cabecera con título y botón '+'
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Mis hábitos',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddHabitView(
                                  habitController: habitController,
                                ),
                              ),
                            );
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.black,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Lista de hábitos agrupados en una tarjeta blanca
                if (habits.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          'No hay hábitos registrados.\nPulsa + para añadir el primero.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF8E8E93)),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                      child: Card(
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: habits.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 1,
                            indent: 20,
                            endIndent: 20,
                            color: Color(0xFFE5E5EA),
                          ),
                          itemBuilder: (context, index) {
                            final habit = habits[index];
                            final isCompleted = habit.completedDates.contains(
                              todayStr,
                            );

                            return _buildHabitTile(context, habit, isCompleted);
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHabitTile(
    BuildContext context,
    HabitModel habit,
    bool isCompleted,
  ) {
    final Color habitColor = Color(int.parse(habit.colorHex));

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 4,
        height: 36,
        decoration: BoxDecoration(
          color: habitColor,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      title: Text(
        habit.title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        isCompleted ? 'Completado hoy' : 'Pendiente',
        style: TextStyle(
          fontSize: 13,
          color: isCompleted
              ? const Color(0xFF007AFF)
              : const Color(0xFF8E8E93),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? const Color(0xFF007AFF) : Colors.transparent,
              border: Border.all(
                color: isCompleted
                    ? const Color(0xFF007AFF)
                    : const Color(0xFFC7C7CC),
                width: 2,
              ),
            ),
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Color(0xFFC7C7CC)),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                HabitDetailView(habit: habit, habitController: habitController),
          ),
        );
      },
    );
  }
}
