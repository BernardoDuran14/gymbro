import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro/application/auth_provider.dart';
import 'package:gymbro/application/database_provider.dart';
import 'package:gymbro/data/repositories/routine_repository.dart';
import 'package:gymbro/presentation/screens/auth_screen.dart';
import 'package:gymbro/presentation/screens/home_screen.dart';
import 'package:gymbro/presentation/screens/prs_screen.dart';
import 'package:gymbro/presentation/screens/routines_screen.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicializar Firebase
  await Firebase.initializeApp();

  // 2. Inicializar SQLite
  final database = await openDatabase(
    'gymbro.db',
    version: 1,
    onCreate: (db, version) async {
      // Tabla de rutinas
      await db.execute('''
        CREATE TABLE routines (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          level TEXT NOT NULL,
          description TEXT NOT NULL
        )
      ''');

      // Tabla de ejercicios (relacionada con rutinas)
      await db.execute('''
        CREATE TABLE exercises (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          routineId INTEGER NOT NULL,
          name TEXT NOT NULL,
          setsReps TEXT NOT NULL,
          restTime TEXT NOT NULL,
          weight REAL,
          notes TEXT,
          FOREIGN KEY (routineId) REFERENCES routines (id)
  )
''');

      // Tabla de PRs
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

  runApp(
    ProviderScope(
      overrides: [
        // Cambiamos a overrideWithValue para el Database directamente
        databaseProvider.overrideWith((ref) => database),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _insertInitialData(Database db) async {
  // Insertar rutinas predefinidas
  final routines = [
    {
      'name': 'Push Pull Legs',
      'level': 'Principiante',
      'description': 'Rutina dividida en días de empuje, jalón y piernas',
    },
    {
      'name': 'Arnold Split',
      'level': 'Intermedio',
      'description': 'Rutina clásica de Arnold Schwarzenegger',
    },
  ];

  for (final routine in routines) {
    final routineId = await db.insert('routines', routine);

    // Insertar ejercicios para cada rutina
    if (routine['name'] == 'Push Pull Legs') {
      await db.insert('exercises', {
        'routineId': routineId,
        'name': 'Press de banca',
        'setsReps': '4x8-12',
        'restTime': '90 seg',
      });
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymBro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: Consumer(
        builder: (context, ref, _) {
          final user = ref.watch(authProvider).user;
          return user == null ? const AuthScreen() : const HomeScreen();
        },
      ),
      routes: {
        '/routines': (context) => const RoutinesScreen(),
        '/prs': (context) => const PRsScreen(),
      },
    );
  }
}
