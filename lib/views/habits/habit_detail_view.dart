import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../controllers/habit_controller.dart';
import '../../models/habit_model.dart';

class HabitDetailView extends StatefulWidget {
  final HabitModel habit;
  final HabitController habitController;

  const HabitDetailView({
    super.key,
    required this.habit,
    required this.habitController,
  });

  @override
  State<HabitDetailView> createState() => _HabitDetailViewState();
}

class _HabitDetailViewState extends State<HabitDetailView> {
  late DateTime _selectedMonth;

  final List<String> _monthsSpanish = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.habitController,
      builder: (context, _) {
        // Mantiene la versión actualizada del hábito desde el controlador
        final habit = widget.habitController.habits.firstWhere(
          (h) => h.id == widget.habit.id,
          orElse: () => widget.habit,
        );

        final Color habitColor = Color(int.parse(habit.colorHex));

        // Cálculos del mes seleccionado
        final monthDates = _getDatesInMonth(_selectedMonth);
        final completedThisMonth = monthDates.where((d) {
          final dateStr = DateFormat('yyyy-MM-dd').format(d);
          return habit.completedDates.contains(dateStr);
        }).length;

        final totalCompleted = habit.completedDates.length;
        final monthlyPercentage = monthDates.isNotEmpty
            ? ((completedThisMonth / monthDates.length) * 100).round()
            : 0;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_month_outlined,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre del Hábito
                Text(
                  habit.title,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 20),

                // Tarjetas de Métricas
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$monthlyPercentage%',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: habitColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Este mes',
                                style: TextStyle(
                                  color: Color(0xFF8E8E93),
                                  fontSize: 14,
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
                                '$totalCompleted',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: habitColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Total completados',
                                style: TextStyle(
                                  color: Color(0xFF8E8E93),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Título Historial
                const Text(
                  'Historial',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8E8E93),
                  ),
                ),
                const SizedBox(height: 12),

                // Tarjeta Calendario
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Cabecera Navegación Mes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: () {
                                setState(() {
                                  _selectedMonth = DateTime(
                                    _selectedMonth.year,
                                    _selectedMonth.month - 1,
                                    1,
                                  );
                                });
                              },
                            ),
                            Text(
                              '${_monthsSpanish[_selectedMonth.month - 1]} ${_selectedMonth.year}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: () {
                                setState(() {
                                  _selectedMonth = DateTime(
                                    _selectedMonth.year,
                                    _selectedMonth.month + 1,
                                    1,
                                  );
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Días de la semana
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: const ['L', 'M', 'X', 'J', 'V', 'S', 'D']
                              .map(
                                (day) => SizedBox(
                                  width: 32,
                                  child: Text(
                                    day,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF8E8E93),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 12),

                        // Rejilla de Días
                        _buildCalendarGrid(habit, habitColor),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<DateTime> _getDatesInMonth(DateTime month) {
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    return List.generate(
      lastDay,
      (i) => DateTime(month.year, month.month, i + 1),
    );
  }

  Widget _buildCalendarGrid(HabitModel habit, Color habitColor) {
    final firstDayOfMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month,
      1,
    );
    final daysInMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      0,
    ).day;

    final startingWeekday = firstDayOfMonth.weekday; // 1 = Lunes
    final totalCells = startingWeekday - 1 + daysInMonth;

    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalCells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        if (index < startingWeekday - 1) {
          return const SizedBox.shrink();
        }

        final dayNumber = index - (startingWeekday - 1) + 1;
        final currentDate = DateTime(
          _selectedMonth.year,
          _selectedMonth.month,
          dayNumber,
        );
        final dateStr = DateFormat('yyyy-MM-dd').format(currentDate);

        final isCompleted = habit.completedDates.contains(dateStr);
        final isToday = dateStr == todayStr;

        return GestureDetector(
          onTap: () {
            widget.habitController.toggleHabitToday(
              habit.id,
              targetDate: currentDate,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: isCompleted
                  ? habitColor
                  : (isToday ? Colors.transparent : const Color(0xFFF2F2F7)),
              borderRadius: BorderRadius.circular(10),
              border: isToday && !isCompleted
                  ? Border.all(color: habitColor, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                '$dayNumber',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isCompleted
                      ? Colors.white
                      : (isToday ? habitColor : const Color(0xFF8E8E93)),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
