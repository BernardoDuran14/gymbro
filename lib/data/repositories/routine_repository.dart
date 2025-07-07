import 'package:sqflite/sqflite.dart';
import '../models/routine_model.dart';
import '../models/exercise_model.dart';

class RoutineRepository {
  static const routinesTable = 'routines';
  static const exercisesTable = 'exercises';

  static const columnId = 'id';
  static const columnName = 'name';
  static const columnLevel = 'level';
  static const columnDescription = 'description';
  static const columnRoutineId = 'routineId';
  static const columnSetsReps = 'setsReps';
  static const columnRestTime = 'restTime';
  static const columnWeight = 'weight'; // Nuevo campo
  static const columnNotes = 'notes'; // Nuevo campo

  final Database database;

  RoutineRepository({required this.database});

  // Métodos para rutinas
  Future<List<Routine>> getAllRoutines() async {
    final List<Map<String, dynamic>> maps = await database.query(routinesTable);
    return List.generate(maps.length, (i) => Routine.fromMap(maps[i]));
  }

  Future<Routine> getRoutineById(int id) async {
    final maps = await database.query(
      routinesTable,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    return Routine.fromMap(maps.first);
  }

  Future<int> addRoutine(Routine routine) async {
    return await database.insert(routinesTable, routine.toMap());
  }

  Future<int> updateRoutine(Routine routine) async {
    return await database.update(
      routinesTable,
      routine.toMap(),
      where: '$columnId = ?',
      whereArgs: [routine.id],
    );
  }

  Future<int> deleteRoutine(int id) async {
    // Primero eliminamos los ejercicios asociados
    await database.delete(
      exercisesTable,
      where: '$columnRoutineId = ?',
      whereArgs: [id],
    );

    // Luego eliminamos la rutina
    return await database.delete(
      routinesTable,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // Métodos para ejercicios
  Future<List<Exercise>> getExercisesByRoutine(int routineId) async {
    final List<Map<String, dynamic>> maps = await database.query(
      exercisesTable,
      where: '$columnRoutineId = ?',
      whereArgs: [routineId],
    );
    return List.generate(maps.length, (i) => Exercise.fromMap(maps[i]));
  }

  Future<Exercise> getExerciseById(int id) async {
    final maps = await database.query(
      exercisesTable,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    return Exercise.fromMap(maps.first);
  }

  Future<int> addExercise(Exercise exercise) async {
    return await database.insert(exercisesTable, exercise.toMap());
  }

  Future<int> updateExercise(Exercise exercise) async {
    return await database.update(
      exercisesTable,
      exercise.toMap(),
      where: '$columnId = ?',
      whereArgs: [exercise.id],
    );
  }

  Future<int> updateExerciseWeight(int exerciseId, double weight) async {
    return await database.update(
      exercisesTable,
      {columnWeight: weight},
      where: '$columnId = ?',
      whereArgs: [exerciseId],
    );
  }

  Future<int> updateExerciseNotes(int exerciseId, String notes) async {
    return await database.update(
      exercisesTable,
      {columnNotes: notes},
      where: '$columnId = ?',
      whereArgs: [exerciseId],
    );
  }

  Future<int> updateExerciseWithData({
    required int exerciseId,
    double? weight,
    String? notes,
    String? setsReps,
    String? restTime,
  }) async {
    final data = <String, dynamic>{};
    if (weight != null) data[columnWeight] = weight;
    if (notes != null) data[columnNotes] = notes;
    if (setsReps != null) data[columnSetsReps] = setsReps;
    if (restTime != null) data[columnRestTime] = restTime;

    if (data.isEmpty) return 0;

    return await database.update(
      exercisesTable,
      data,
      where: '$columnId = ?',
      whereArgs: [exerciseId],
    );
  }

  Future<int> deleteExercise(int id) async {
    return await database.delete(
      exercisesTable,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    await database.close();
  }

  // Método para migración si es necesario
  Future<void> migrateDatabase(Database db, int newVersion) async {
    if (newVersion > 1) {
      // Ejemplo de migración para futuras versiones
      await db.execute('''
        ALTER TABLE $exercisesTable ADD COLUMN $columnWeight REAL
      ''');
      await db.execute('''
        ALTER TABLE $exercisesTable ADD COLUMN $columnNotes TEXT
      ''');
    }
  }
}
