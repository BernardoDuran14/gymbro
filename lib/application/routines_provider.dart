import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro/data/models/exercise_model.dart';
import 'package:gymbro/data/models/routine_model.dart';
import 'package:gymbro/data/repositories/routine_repository.dart';
import 'package:gymbro/application/database_provider.dart';

// 1. Proveedor del Repositorio
final routineRepositoryProvider = Provider<RoutineRepository>((ref) {
  final databaseAsync = ref.watch(databaseProvider);
  return databaseAsync.when(
    loading: () => throw Exception('Database not initialized'),
    error: (err, stack) => throw Exception('Database error: $err'),
    data: (database) => RoutineRepository(database: database),
  );
});

// 2. Proveedor para todas las rutinas
final routinesProvider = FutureProvider<List<Routine>>((ref) async {
  final repository = ref.read(routineRepositoryProvider);
  return await repository.getAllRoutines();
});

// 3. Proveedor para una rutina específica (Family Provider)
final routineDetailProvider = FutureProvider.family<Routine, int>((
  ref,
  routineId,
) async {
  final repository = ref.read(routineRepositoryProvider);
  return await repository.getRoutineById(routineId);
});

// 4. Proveedor para ejercicios de una rutina (Family Provider)
final routineExercisesProvider = FutureProvider.family<List<Exercise>, int>((
  ref,
  routineId,
) async {
  final repository = ref.read(routineRepositoryProvider);
  return await repository.getExercisesByRoutine(routineId);
});

// 5. Proveedor para estado de selección actual (Opcional)
final currentRoutineProvider = StateProvider<Routine?>((ref) => null);

/* CÓMO USAR ESTOS PROVIDERS:

1. Para obtener todas las rutinas:
ref.watch(routinesProvider).when(
  loading: () => LoadingWidget(),
  error: (err, stack) => ErrorWidget(err),
  data: (routines) => ListView.builder(...)
);

2. Para obtener una rutina específica:
ref.watch(routineDetailProvider(routineId))

3. Para obtener ejercicios de una rutina:
ref.watch(routineExercisesProvider(routineId))

4. Para manejar selección actual:
ref.read(currentRoutineProvider.notifier).state = selectedRoutine;
*/
