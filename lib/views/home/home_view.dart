import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../controllers/habit_controller.dart';
import '../../models/habit_model.dart';

class HomeView extends StatelessWidget {
  final HabitController habitController;

  const HomeView({super.key, required this.habitController});

  // Saludo dinámico según la hora del día
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 20) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    final todayStr = DateFormat('yyyy-MM-DD').format(DateTime.now());

    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: habitController,
          builder: (context, _) {
            final habits = habitController.habits;
            final totalHabits = habits.length;

            final completedCount = habits
                .where((h) => h.completedDates.contains(todayStr))
                .length;

            final double progressPercentage = totalHabits > 0
                ? (completedCount / totalHabits)
                : 0.0;

            return CustomScrollView(
              slivers: [
                // Título con saludo dinámico
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Text(
                      _getGreeting(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),

                // Tarjeta Resumen de Progreso
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$completedCount de $totalHabits',
                                    style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'hábitos completados hoy',
                                    style: TextStyle(
                                      color: Color(0xFF8E8E93),
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Barra de progreso horizontal
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: progressPercentage,
                                      minHeight: 6,
                                      backgroundColor: const Color(0xFFE5E5EA),
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            Colors.redAccent,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            // Anillo / Porcentaje Circular
                            SizedBox(
                              width: 70,
                              height: 70,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CircularProgressIndicator(
                                    value: progressPercentage,
                                    strokeWidth: 8,
                                    backgroundColor: const Color(0xFFE5E5EA),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          Colors.redAccent,
                                        ),
                                  ),
                                  Center(
                                    child: Text(
                                      '${(progressPercentage * 100).round()}%',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Subtítulo "Hoy"
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Text(
                      'Hoy',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ),
                ),

                // Lista de Hábitos
                if (totalHabits == 0)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          'No tienes hábitos creados.\nVe a la pestaña Hábitos para añadir uno.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF8E8E93)),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final habit = habits[index];
                        final isCompleted = habit.completedDates.contains(
                          todayStr,
                        );

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildHabitCard(context, habit, isCompleted),
                        );
                      }, childCount: habits.length),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Tarjeta individual de Hábito
  Widget _buildHabitCard(
    BuildContext context,
    HabitModel habit,
    bool isCompleted,
  ) {
    final Color habitColor = Color(int.parse(habit.colorHex));

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Indicador de color / Check
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? habitColor
                    : habitColor.withValues(alpha: 0.15),
                border: Border.all(color: habitColor, width: 2),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
            const SizedBox(width: 16),

            // Nombre del hábito
            Expanded(
              child: Text(
                habit.title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: isCompleted ? const Color(0xFF8E8E93) : Colors.black,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),

            // Botón Marcar / Deshacer
            GestureDetector(
              onTap: () => habitController.toggleHabitToday(habit.id),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFFE5E5EA)
                      : habitColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isCompleted ? 'Deshacer' : 'Marcar',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? const Color(0xFF8E8E93) : habitColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
