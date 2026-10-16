import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/habit_model.dart';
import '../repositories/interfaces/i_habit_repository.dart';

class BackupService {
  final IHabitRepository _repository;

  BackupService(this._repository);

  // 1. Exportar la base de datos a un archivo JSON y abrir el menú de compartir
  Future<void> exportBackup() async {
    final habits = await _repository.getHabits();
    final List<Map<String, dynamic>> habitsMapList = habits
        .map((h) => h.toMap())
        .toList();

    final backupData = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'habits': habitsMapList,
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);

    // Guardar en un archivo temporal
    final tempDir = await getTemporaryDirectory();
    final dateFormatted = DateTime.now().toString().split(' ')[0];
    final filePath = '${tempDir.path}/trackeame_backup_$dateFormatted.json';
    final file = File(filePath);

    await file.writeAsString(jsonString);

    // Abrir menú nativo de compartir pasando el objeto ShareParams
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(filePath)],
        subject: 'Copia de seguridad de Trackeame',
      ),
    );
  }

  // 2. Importar copia de seguridad seleccionando un archivo JSON
  Future<List<HabitModel>?> importBackup() async {
    final result = await FilePickerPlatform.instance.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.isEmpty) {
      return null; // El usuario canceló la selección
    }

    final filePath = result.first.path;
    if (filePath == null) {
      return null;
    }

    final file = File(filePath);
    final content = await file.readAsString();
    final Map<String, dynamic> decodedData = jsonDecode(content);

    if (!decodedData.containsKey('habits')) {
      throw const FormatException(
        'El archivo de copia de seguridad no es válido',
      );
    }

    final List<dynamic> habitsJson = decodedData['habits'];
    final List<HabitModel> importedHabits = habitsJson
        .map((map) => HabitModel.fromMap(map))
        .toList();

    // Insertar o actualizar hábitos en SQLite
    for (var habit in importedHabits) {
      await _repository.insertHabit(habit);
    }

    return importedHabits;
  }
}
