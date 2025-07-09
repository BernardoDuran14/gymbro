import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:async/async.dart';
import '../models/pr_model.dart';

class PRRepository {
  static const _databaseName = 'gymbro.db';
  static const _databaseVersion = 2;
  static const table = 'prs';
  static const columnId = 'id';
  static const columnExercise = 'exercise';
  static const columnWeight = 'weight';
  static const columnDate = 'date';
  static const columnUserEmail = 'userEmail';
  static const columnSynced = 'synced';

  final Database? _database;
  final FirebaseFirestore _firestore;

  PRRepository({Database? database, FirebaseFirestore? firestore})
    : _database = database,
      _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    return await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
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
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE prs ADD COLUMN synced INTEGER DEFAULT 0');
      } catch (e) {
        print('Error adding synced column: $e');
      }
    }
  }

  Future<int> addPR(PR pr) async {
    final db = await database;
    return await db.insert('prs', {
      'exercise': pr.exercise,
      'weight': pr.weight,
      'date': pr.date,
      'userEmail': pr.userEmail,
      'verified': pr.verified ? 1 : 0,
      'notes': pr.notes,
      'videoUrl': pr.videoUrl,
      'synced': 0,
    });
  }

  Stream<List<PR>> getAllPRsStream({bool forceRefresh = false}) {
    final remoteStream = _firestore
        .collection('prs')
        .snapshots()
        .asyncMap((snapshot) => _convertRemotePRs(snapshot));

    final periodicStream = Stream.periodic(
      const Duration(seconds: 3),
    ).asyncMap((_) => _getMergedPRs());

    return StreamGroup.merge([
      remoteStream,
      periodicStream,
    ]).asyncMap((_) => _getMergedPRs());
  }

  Future<List<PR>> _getMergedPRs() async {
    final localPRs = await _getLocalPRs();
    final remoteSnapshot = await _firestore.collection('prs').get();
    final remotePRs = _convertRemotePRs(remoteSnapshot);
    return _mergePRs(localPRs, remotePRs);
  }

  Future<List<PR>> _getLocalPRs() async {
    final db = await database;
    try {
      final localMaps = await db.query('prs');
      return localMaps.map((map) => PR.fromMap(map)).toList();
    } catch (e) {
      print('Error obteniendo PRs locales: $e');
      return [];
    }
  }

  Future<List<PR>> _getRemotePRs() async {
    try {
      final snapshot = await _firestore.collection('prs').get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return PR(
          id: data['localId'] ?? 0,
          exercise: data['exercise'] ?? '',
          weight: (data['weight'] ?? 0).toDouble(),
          date: data['date'] ?? '',
          userEmail: data['userEmail'] ?? '',
          verified: data['verified'] ?? false,
          notes: data['notes'],
          videoUrl: data['videoUrl'],
          synced: true,
        );
      }).toList();
    } catch (e) {
      print('Error obteniendo PRs remotos: $e');
      rethrow;
    }
  }

  List<PR> _convertRemotePRs(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return PR(
        id: data['localId'] ?? 0,
        exercise: data['exercise'] ?? '',
        weight: (data['weight'] ?? 0).toDouble(),
        date: data['date'] ?? DateTime.now().toString(),
        userEmail: data['userEmail'] ?? '',
        verified: data['verified'] ?? false,
        notes: data['notes'],
        videoUrl: data['videoUrl'],
        synced: true,
      );
    }).toList();
  }

  Future<List<PR>> getAllPRs() async {
    final db = await database;

    try {
      final localPRs = await _getLocalPRs();

      final remotePRs = await _getRemotePRs().timeout(
        const Duration(seconds: 10),
      );

      return _mergePRs(localPRs, remotePRs);
    } catch (e) {
      print('Error en getAllPRs: $e');
      final localPRs = await _getLocalPRs();
      return localPRs;
    }
  }

  List<PR> _mergePRs(List<PR> localPRs, List<PR> remotePRs) {
    final allPRs = [...remotePRs, ...localPRs];
    return allPRs
        .fold<Map<int, PR>>({}, (map, pr) {
          final key = pr.id ?? 0;
          if (!map.containsKey(key) || !pr.synced) {
            map[key] = pr;
          }
          return map;
        })
        .values
        .toList();
  }

  Future<void> syncPRs(String userEmail) async {
    final db = await database;
    final unsyncedPRs = await db.query(
      table,
      where: '$columnUserEmail = ? AND $columnSynced = ?',
      whereArgs: [userEmail, 0],
    );

    for (final prMap in unsyncedPRs) {
      final pr = PR.fromMap(prMap);
      try {
        await _firestore.collection('prs').add({
          'exercise': pr.exercise,
          'weight': pr.weight,
          'date': pr.date,
          'userEmail': pr.userEmail,
          'verified': pr.verified,
          'notes': pr.notes,
          'videoUrl': pr.videoUrl,
          'localId': pr.id,
        });

        await db.update(
          table,
          {columnSynced: 1},
          where: '$columnId = ?',
          whereArgs: [pr.id],
        );
      } catch (e) {
        print('Error sincronizando PR ${pr.id}: $e');
      }
    }
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
