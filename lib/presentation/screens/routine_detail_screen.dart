import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro/data/models/exercise_model.dart';
import 'package:gymbro/data/models/routine_model.dart';
import 'package:gymbro/data/repositories/routine_repository.dart';
import 'package:gymbro/application/database_provider.dart';

class RoutineDetailScreen extends ConsumerStatefulWidget {
  final int routineId;

  const RoutineDetailScreen({super.key, required this.routineId});

  @override
  ConsumerState<RoutineDetailScreen> createState() =>
      _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends ConsumerState<RoutineDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final routineAsync = ref.watch(routineProvider(widget.routineId));
    final exercisesAsync = ref.watch(exercisesProvider(widget.routineId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Rutina')),
      body: routineAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (routine) {
          return Column(
            children: [
              _RoutineHeader(routine: routine),
              const SizedBox(height: 16),
              Expanded(
                child: exercisesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                  data: (exercises) {
                    if (exercises.isEmpty) {
                      return const Center(
                        child: Text('No hay ejercicios en esta rutina'),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        return _ExerciseCard(exercise: exercises[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RoutineHeader extends StatelessWidget {
  final Routine routine;

  const _RoutineHeader({required this.routine});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              routine.name,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(routine.level),
              backgroundColor: _getLevelColor(routine.level),
            ),
            const SizedBox(height: 12),
            Text(
              routine.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'principiante':
        return Colors.green.withOpacity(0.2);
      case 'intermedio':
        return Colors.orange.withOpacity(0.2);
      case 'avanzado':
        return Colors.red.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }
}

class _ExerciseCard extends ConsumerWidget {
  final Exercise exercise;

  const _ExerciseCard({required this.exercise});

  void _showEditWeightDialog(
    BuildContext context,
    WidgetRef ref,
    Exercise exercise,
  ) {
    final weightController = TextEditingController(
      text: exercise.weight?.toString() ?? '',
    );
    final notesController = TextEditingController(text: exercise.notes ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Registrar peso'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: weightController,
                decoration: const InputDecoration(
                  labelText: 'Peso (kg)',
                  hintText: 'Ej: 50.5',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas',
                  hintText: 'Ej: Fácil, difícil, observaciones...',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newWeight = double.tryParse(weightController.text);
                final newNotes = notesController.text;

                await ref
                    .read(routineRepositoryProvider)
                    .updateExerciseWeight(exercise.id!, newWeight ?? 0.0);

                await ref
                    .read(routineRepositoryProvider)
                    .updateExerciseNotes(exercise.id!, newNotes);

                // Invalidamos los providers para refrescar los datos
                ref.invalidate(exercisesProvider(exercise.routineId));
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise.name,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoChip(Icons.repeat, exercise.setsReps),
                _buildInfoChip(Icons.timer, exercise.restTime),
              ],
            ),
            const SizedBox(height: 12),
            if (exercise.weight != null) ...[
              Row(
                children: [
                  const Icon(Icons.fitness_center, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${exercise.weight} kg',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (exercise.notes != null && exercise.notes!.isNotEmpty) ...[
              Text(
                exercise.notes!,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 8),
            ],
            ElevatedButton(
              onPressed: () => _showEditWeightDialog(context, ref, exercise),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
              ),
              child: const Text('Registrar Peso'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(text),
      backgroundColor: Colors.grey[100],
      visualDensity: VisualDensity.compact,
    );
  }
}

// Providers
final routineRepositoryProvider = Provider<RoutineRepository>((ref) {
  final databaseAsync = ref.watch(databaseProvider);
  // Esperamos a que la base de datos esté lista
  return databaseAsync.when(
    loading: () => throw Exception('Database not initialized'),
    error: (err, stack) => throw Exception('Database error: $err'),
    data: (database) => RoutineRepository(database: database),
  );
});

final routineProvider = FutureProvider.family<Routine, int>((
  ref,
  routineId,
) async {
  final repository = ref.read(routineRepositoryProvider);
  return await repository.getRoutineById(routineId);
});

final exercisesProvider = FutureProvider.family<List<Exercise>, int>((
  ref,
  routineId,
) async {
  final repository = ref.read(routineRepositoryProvider);
  return await repository.getExercisesByRoutine(routineId);
});
