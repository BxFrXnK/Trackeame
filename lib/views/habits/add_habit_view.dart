import 'package:flutter/material.dart';

import '../../controllers/habit_controller.dart';
import '../../core/theme/app_theme.dart';

class AddHabitView extends StatefulWidget {
  final HabitController habitController;

  const AddHabitView({super.key, required this.habitController});

  @override
  State<AddHabitView> createState() => _AddHabitViewState();
}

class _AddHabitViewState extends State<AddHabitView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<int> _selectedDays = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
  ]; // Por defecto todos los días (1=Lunes, 7=Domingo)
  String _selectedColorHex = '0xFFFFD600'; // Amarillo por defecto

  final List<Map<String, dynamic>> _availableColors = [
    {'hex': '0xFFFFD600', 'color': AppTheme.habitYellow, 'name': 'Amarillo'},
    {'hex': '0xFF007AFF', 'color': AppTheme.habitBlue, 'name': 'Azul'},
    {'hex': '0xFFAF52DE', 'color': AppTheme.habitPurple, 'name': 'Púrpura'},
    {'hex': '0xFF34C759', 'color': AppTheme.habitGreen, 'name': 'Verde'},
    {'hex': '0xFFFF3B30', 'color': AppTheme.habitRed, 'name': 'Rojo'},
  ];

  final List<String> _dayNames = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveHabit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecciona al menos un día de la semana'),
          ),
        );
        return;
      }

      await widget.habitController.addHabit(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        colorHex: _selectedColorHex,
        daysOfWeek: _selectedDays,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Hábito', style: TextStyle(fontSize: 20)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveHabit,
            child: const Text(
              'Guardar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.habitBlue,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campo Nombre
              const Text(
                'NOMBRE DEL HÁBITO',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Ej. Gimnasio, Meditación, Lectura...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Introduce un nombre para el hábito';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Selección de Color
              const Text(
                'COLOR IDENTIFICADOR',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _availableColors.map((colorItem) {
                  final isSelected = _selectedColorHex == colorItem['hex'];
                  final Color color = colorItem['color'];

                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedColorHex = colorItem['hex']),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.black, width: 3)
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 24,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Selección de Días de la Semana
              const Text(
                'REPETIR LOS DÍAS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  final dayNumber = index + 1;
                  final isSelected = _selectedDays.contains(dayNumber);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedDays.remove(dayNumber);
                        } else {
                          _selectedDays.add(dayNumber);
                        }
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.habitBlue : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          _dayNames[index],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
