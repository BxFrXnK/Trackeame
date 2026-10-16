import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'controllers/habit_controller.dart';
import 'repositories/implementations/sqlite_habit_repository.dart';
import 'views/main_navigation_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicializamos la implementación física del repositorio
  final habitRepository = SqliteHabitRepository();

  // 2. Inyectamos el repositorio en el controlador
  final habitController = HabitController(habitRepository);

  // 3. Cargamos la lista inicial de hábitos desde SQLite
  await habitController.loadHabits();

  runApp(TrackeameApp(habitController: habitController));
}

class TrackeameApp extends StatelessWidget {
  final HabitController habitController;

  const TrackeameApp({super.key, required this.habitController});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trackeame',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: MainNavigationView(habitController: habitController),
    );
  }
}
