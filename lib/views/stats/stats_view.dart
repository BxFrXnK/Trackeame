import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../controllers/habit_controller.dart';
import '../../models/habit_model.dart';

enum TimePeriod { week, month, year }

class StatsView extends StatefulWidget {
  final HabitController habitController;

  const StatsView({super.key, required this.habitController});

  @override
  State<StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends State<StatsView> {
  TimePeriod _selectedPeriod = TimePeriod.month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.habitController,
          builder: (context, _) {
            final habits = widget.habitController.habits;

            // Calcular rango de fechas según el periodo seleccionado
            final now = DateTime.now();
            DateTime startDate;

            switch (_selectedPeriod) {
              case TimePeriod.week:
                startDate = now.subtract(Duration(days: now.weekday - 1));
                break;
              case TimePeriod.month:
                startDate = DateTime(now.year, now.month, 1);
                break;
              case TimePeriod.year:
                startDate = DateTime(now.year, 1, 1);
                break;
            }

            final daysInPeriod = now.difference(startDate).inDays + 1;

            // Métricas globales
            int totalCompletionsInPeriod = 0;
            for (var habit in habits) {
              totalCompletionsInPeriod += habit.completedDates.where((d) {
                final date = DateTime.tryParse(d);
                return date != null &&
                    date.isAfter(startDate.subtract(const Duration(days: 1))) &&
                    date.isBefore(now.add(const Duration(days: 1)));
              }).length;
            }

            final totalPossible = habits.length * daysInPeriod;
            final globalRate = totalPossible > 0
                ? ((totalCompletionsInPeriod / totalPossible) * 100).round()
                : 0;

            return CustomScrollView(
              slivers: [
                // Título
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Text(
                      'Estadísticas',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),

                // Selector de Periodo ("Esta semana", "Este mes", "Este año")
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E5EA),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          _buildSegmentItem('Esta semana', TimePeriod.week),
                          _buildSegmentItem('Este mes', TimePeriod.month),
                          _buildSegmentItem('Este año', TimePeriod.year),
                        ],
                      ),
                    ),
                  ),
                ),

                // Subtítulo Resumen
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Text(
                      'Resumen',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ),
                ),

                // Tarjetas de Resumen
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$globalRate%',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFF3B30),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Cumplimiento global',
                                    style: TextStyle(
                                      color: Color(0xFF8E8E93),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$totalCompletionsInPeriod',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF007AFF),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Total completados',
                                    style: TextStyle(
                                      color: Color(0xFF8E8E93),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Subtítulo Por Hábito
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Text(
                      'Por hábito',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ),
                ),

                // Lista de Desglose por Hábito
                if (habits.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          'Añade hábitos para ver sus estadísticas.',
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
                            return _buildHabitStatTile(
                              habit,
                              startDate,
                              daysInPeriod,
                            );
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

  // Botón del Segmented Control
  Widget _buildSegmentItem(String text, TimePeriod period) {
    final isSelected = _selectedPeriod == period;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = period),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Celda de estadísticas individuales de un hábito
  Widget _buildHabitStatTile(
    HabitModel habit,
    DateTime startDate,
    int daysInPeriod,
  ) {
    final Color habitColor = Color(int.parse(habit.colorHex));
    final now = DateTime.now();

    final completedCount = habit.completedDates.where((d) {
      final date = DateTime.tryParse(d);
      return date != null &&
          date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          date.isBefore(now.add(const Duration(days: 1)));
    }).length;

    final double rateRatio = daysInPeriod > 0
        ? (completedCount / daysInPeriod)
        : 0.0;
    final int ratePercentage = (rateRatio * 100).round();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y Porcentaje
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: habitColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  habit.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '$ratePercentage%',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: habitColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Barra de progreso del hábito
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: rateRatio.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: const Color(0xFFE5E5EA),
              valueColor: AlwaysStoppedAnimation<Color>(habitColor),
            ),
          ),
          const SizedBox(height: 12),

          // Rachas (🔥 Días seguidos | 🏆 Mejor)
          Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                color: Colors.grey,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                '${habit.currentStreak} días seguidos',
                style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
              ),
              const SizedBox(width: 20),
              const Icon(
                Icons.emoji_events_rounded,
                color: Color(0xFFFFD600),
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                'Mejor: ${habit.bestStreak}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
