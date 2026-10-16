import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/habit_model.dart';
import '../interfaces/i_habit_repository.dart';

class SqliteHabitRepository implements IHabitRepository {
  static Database? _database;

  // Obtiene la instancia activa de la base de datos o la inicializa si no existe
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'trackeame.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE habits (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT,
            colorHex TEXT,
            daysOfWeek TEXT,
            completedDates TEXT,
            currentStreak INTEGER,
            bestStreak INTEGER,
            createdAt TEXT
          )
        ''');
      },
    );
  }

  @override
  Future<List<HabitModel>> getHabits() async {
    final db = await database;
    final maps = await db.query('habits');
    return List.generate(maps.length, (i) => HabitModel.fromMap(maps[i]));
  }

  @override
  Future<HabitModel?> getHabitById(String id) async {
    final db = await database;
    final maps = await db.query('habits', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return HabitModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> insertHabit(HabitModel habit) async {
    final db = await database;
    await db.insert(
      'habits',
      habit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateHabit(HabitModel habit) async {
    final db = await database;
    await db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  @override
  Future<void> deleteHabit(String id) async {
    final db = await database;
    await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }
}
