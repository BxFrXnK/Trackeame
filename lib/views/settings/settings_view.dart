import 'package:flutter/material.dart';

import '../../controllers/habit_controller.dart';
import '../../core/theme/app_theme.dart';
import '../habits/add_habit_view.dart';

class SettingsView extends StatefulWidget {
  final HabitController habitController;

  const SettingsView({super.key, required this.habitController});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _dailyReminder = false;
  String _selectedTheme = 'Sistema';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.habitController,
          builder: (context, _) {
            final habits = widget.habitController.habits;

            return CustomScrollView(
              slivers: [
                // Título
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Text(
                      'Opciones',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),

                // Sección: Apariencia
                _buildSectionHeader('Apariencia'),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tema',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedTheme,
                                icon: const Icon(
                                  Icons.unfold_more_rounded,
                                  color: Color(0xFF8E8E93),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Sistema',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.brightness_auto,
                                          size: 20,
                                          color: Color(0xFF8E8E93),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Sistema',
                                          style: TextStyle(
                                            color: Color(0xFF8E8E93),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Claro',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.wb_sunny_outlined,
                                          size: 20,
                                          color: Color(0xFF8E8E93),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Claro',
                                          style: TextStyle(
                                            color: Color(0xFF8E8E93),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Oscuro',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.dark_mode_outlined,
                                          size: 20,
                                          color: Color(0xFF8E8E93),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Oscuro',
                                          style: TextStyle(
                                            color: Color(0xFF8E8E93),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _selectedTheme = value);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Sección: Notificaciones
                _buildSectionHeader('Notificaciones'),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF007AFF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.notifications_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                const Expanded(
                                  child: Text(
                                    'Recordatorio diario',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Switch.adaptive(
                                  value: _dailyReminder,
                                  activeColor: AppTheme.habitGreen,
                                  onChanged: (value) {
                                    setState(() => _dailyReminder = value);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            'Recibirás un recordatorio diario para revisar tus hábitos.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF8E8E93),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Sección: Gestionar hábitos
                _buildSectionHeader('Gestionar hábitos'),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const CircleAvatar(
                              radius: 14,
                              backgroundColor: AppTheme.habitGreen,
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            title: const Text(
                              'Añadir hábito',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.habitGreen,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddHabitView(
                                    habitController: widget.habitController,
                                  ),
                                ),
                              );
                            },
                          ),
                          if (habits.isNotEmpty)
                            const Divider(
                              height: 1,
                              indent: 20,
                              endIndent: 20,
                              color: Color(0xFFE5E5EA),
                            ),
                          ListView.separated(
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
                              final habitColor = Color(
                                int.parse(habit.colorHex),
                              );

                              return ListTile(
                                leading: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: habitColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                title: Text(
                                  habit.title,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: Color(0xFF8E8E93),
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    // Modal de edición / eliminación
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Sección: Acerca de
                _buildSectionHeader('Acerca de'),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    child: Card(
                      child: Column(
                        children: [
                          const ListTile(
                            title: Text(
                              'Versión',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Text(
                              '1.0',
                              style: TextStyle(
                                fontSize: 17,
                                color: Color(0xFF8E8E93),
                              ),
                            ),
                          ),
                          const Divider(
                            height: 1,
                            indent: 20,
                            endIndent: 20,
                            color: Color(0xFFE5E5EA),
                          ),
                          ListTile(
                            title: const Text(
                              'Hábitos activos',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Text(
                              '${habits.length}',
                              style: const TextStyle(
                                fontSize: 17,
                                color: Color(0xFF8E8E93),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Sección: Copia de seguridad
                _buildSectionHeader('Copia de seguridad'),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.upload_file_rounded,
                              color: Color(0xFF007AFF),
                            ),
                            title: const Text('Exportar copia de seguridad'),
                            subtitle: const Text(
                              'Guarda o comparte tus datos en JSON',
                            ),
                            onTap: () async {
                              await widget.habitController.exportData();
                            },
                          ),
                          const Divider(
                            height: 1,
                            indent: 20,
                            endIndent: 20,
                            color: Color(0xFFE5E5EA),
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.download_rounded,
                              color: Color(0xFF34C759),
                            ),
                            title: const Text('Restaurar copia de seguridad'),
                            subtitle: const Text(
                              'Carga hábitos desde un archivo JSON',
                            ),
                            onTap: () async {
                              final success = await widget.habitController
                                  .importData();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? 'Copia de seguridad restaurada con éxito'
                                          : 'Proceso cancelado o archivo inválido',
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
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

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8E8E93),
          ),
        ),
      ),
    );
  }
}
