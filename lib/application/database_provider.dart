import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

final databaseProvider = FutureProvider<Database>((ref) async {
  // Mover toda la lógica de inicialización aquí
  final database = await openDatabase(
    'gymbro.db',
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE routines (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          level TEXT NOT NULL,
          description TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE exercises (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          routineId INTEGER NOT NULL,
          name TEXT NOT NULL,
          setsReps TEXT NOT NULL,
          restTime TEXT NOT NULL,
          FOREIGN KEY (routineId) REFERENCES routines (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE prs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          exercise TEXT NOT NULL,
          weight REAL NOT NULL,
          date TEXT NOT NULL,
          userEmail TEXT NOT NULL,
          verified INTEGER DEFAULT 0,
          notes TEXT,
          videoUrl TEXT
        )
      ''');

      // Insertar datos iniciales
      await _insertInitialData(db);
    },
  );
  return database;
});

Future<void> _insertInitialData(Database db) async {
  // ... (misma lógica de inserción inicial)
}
