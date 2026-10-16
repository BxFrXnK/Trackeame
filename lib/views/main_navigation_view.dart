import 'package:flutter/material.dart';

import '../controllers/habit_controller.dart';
import 'home/home_view.dart';
import 'habits/habits_list_view.dart';
import 'stats/stats_view.dart';
import 'settings/settings_view.dart';

class MainNavigationView extends StatefulWidget {
  final HabitController habitController;

  const MainNavigationView({super.key, required this.habitController});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeView(habitController: widget.habitController),
      HabitsListView(habitController: widget.habitController),
      StatsView(habitController: widget.habitController),
      SettingsView(habitController: widget.habitController),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(35),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFF007AFF),
              unselectedItemColor: const Color(0xFF8E8E93),
              selectedFontSize: 12,
              unselectedFontSize: 12,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  label: 'Inicio',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.check_circle_rounded),
                  label: 'Hábitos',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart_rounded),
                  label: 'Estadísticas',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_rounded),
                  label: 'Opciones',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
