import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro/data/models/pr_model.dart';
import '../../data/repositories/pr_repository.dart';
import 'database_provider.dart';
import 'firestore_provider.dart';

final prRepositoryProvider = Provider<PRRepository>((ref) {
  final database = ref.watch(databaseProvider).value;
  final firestore = ref.watch(firestoreProvider);
  return PRRepository(database: database, firestore: firestore);
});
final prsRefreshProvider = StateProvider<int>((ref) => 0);
final prsProvider = StreamProvider<List<PR>>((ref) {
  ref.watch(prsRefreshProvider);

  final repository = ref.read(prRepositoryProvider);
  return repository.getAllPRsStream();
});
