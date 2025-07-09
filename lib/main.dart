import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro/application/auth_provider.dart';
import 'package:gymbro/application/database_provider.dart';
import 'package:gymbro/application/firestore_provider.dart';
import 'package:gymbro/data/repositories/routine_repository.dart';
import 'package:gymbro/presentation/screens/auth_screen.dart';
import 'package:gymbro/presentation/screens/home_screen.dart';
import 'package:gymbro/presentation/screens/prs_screen.dart';
import 'package:gymbro/presentation/screens/routines_screen.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp();

  // Configuración de Firestore
  _configureFirestore();

  // Inicializar base de datos local
  final database = await openDatabase(
    'gymbro.db',
    version: 2,
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
          videoUrl TEXT,
          synced INTEGER DEFAULT 0
        )
      ''');
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        await db.execute('ALTER TABLE prs ADD COLUMN synced INTEGER DEFAULT 0');
      }
    },
  );

  runApp(
    ProviderScope(
      overrides: [databaseProvider.overrideWith((ref) => database)],
      child: const MyApp(),
    ),
  );
}

void _configureFirestore() {
  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    print('Error configurando Firestore: $e');
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
