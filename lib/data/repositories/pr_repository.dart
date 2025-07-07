import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/pr_model.dart';

class PRRepository {
  static const _databaseName = 'gymbro.db';
  static const _databaseVersion = 1;

  static const table = 'prs';
  static const columnId = 'id';
  static const columnExercise = 'exercise';
  static const columnWeight = 'weight';
  static const columnDate = 'date';
  static const columnUserEmail = 'userEmail';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnExercise TEXT NOT NULL,
        $columnWeight REAL NOT NULL,
        $columnDate TEXT NOT NULL,
        $columnUserEmail TEXT NOT NULL
      )
    ''');
  }

  Future<int> addPR(PR pr) async {
    final db = await database;
    return await db.insert(table, {
      columnExercise: pr.exercise,
      columnWeight: pr.weight,
      columnDate: pr.date,
      columnUserEmail: pr.userEmail,
    });
  }

  Future<List<PR>> getAllPRs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(table);
    return List.generate(maps.length, (i) => PR.fromMap(maps[i]));
  }

  Future<List<PR>> getPRsByUser(String userEmail) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      table,
      where: '$columnUserEmail = ?',
      whereArgs: [userEmail],
    );
    return List.generate(maps.length, (i) => PR.fromMap(maps[i]));
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
