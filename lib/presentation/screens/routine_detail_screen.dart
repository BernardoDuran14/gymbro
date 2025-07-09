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
  void _showAddExerciseDialog() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final nameController = TextEditingController();
    final setsRepsController = TextEditingController(text: '3x8-12');
    final restTimeController = TextEditingController(text: '60 seg');
    final weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Nuevo Ejercicio',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.green.shade500,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: setsRepsController,
                decoration: InputDecoration(
                  labelText: 'Series x Reps',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: restTimeController,
                decoration: InputDecoration(
                  labelText: 'Tiempo de descanso',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: weightController,
                decoration: InputDecoration(
                  labelText: 'Peso (kg)',
                  hintText: 'Opcional',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: TextStyle(color: colors.onSurface),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final newExercise = Exercise(
                  routineId: widget.routineId,
                  name: nameController.text,
                  setsReps: setsRepsController.text,
                  restTime: restTimeController.text,
                  weight: double.tryParse(weightController.text),
                );

                await ref
                    .read(routineRepositoryProvider)
                    .addExercise(newExercise);
                ref.invalidate(exercisesProvider(widget.routineId));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Guardar', style: TextStyle(color: colors.onPrimary)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final routineAsync = ref.watch(routineProvider(widget.routineId));
    final exercisesAsync = ref.watch(exercisesProvider(widget.routineId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Rutina'), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExerciseDialog,
        backgroundColor: Colors.green.shade500,
        foregroundColor: colors.onPrimary,
        child: const Icon(Icons.add),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade500.withOpacity(0.1), colors.background],
          ),
        ),
        child: routineAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(color: Colors.green.shade500),
          ),
          error: (error, stack) => Center(
            child: Text('Error: $error', style: TextStyle(color: colors.error)),
          ),
          data: (routine) {
            return Column(
              children: [
                _RoutineHeader(routine: routine),
                const SizedBox(height: 16),
                Expanded(
                  child: exercisesAsync.when(
                    loading: () => Center(
                      child: CircularProgressIndicator(
                        color: Colors.green.shade500,
                      ),
                    ),
                    error: (error, stack) => Center(
                      child: Text(
                        'Error: $error',
                        style: TextStyle(color: colors.error),
                      ),
                    ),
                    data: (exercises) {
                      if (exercises.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.sports_gymnastics,
                                size: 60,
                                color: colors.onSurface.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No hay ejercicios en esta rutina',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: colors.onSurface.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Presiona el botón + para agregar uno',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colors.onSurface.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: exercises.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ExerciseCard(
                              exercise: exercises[index],
                              routineId: widget.routineId,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RoutineHeader extends StatelessWidget {
  final Routine routine;

  const _RoutineHeader({required this.routine});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              routine.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade500,
              ),
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(routine.level),
              backgroundColor: _getLevelColor(routine.level, colors),
              side: BorderSide.none,
              shape: StadiumBorder(
                side: BorderSide(color: colors.outline.withOpacity(0.2)),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              routine.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getLevelColor(String level, ColorScheme colors) {
    switch (level.toLowerCase()) {
      case 'principiante':
        return Colors.green.shade500.withOpacity(0.2);
      case 'intermedio':
        return Colors.green.shade500.withOpacity(0.2);
      case 'avanzado':
        return colors.tertiary.withOpacity(0.2);
      default:
        return colors.surfaceVariant.withOpacity(0.2);
    }
  }
}

class _ExerciseCard extends ConsumerWidget {
  final Exercise exercise;
  final int routineId;

  const _ExerciseCard({required this.exercise, required this.routineId});

  void _showEditExerciseDialog(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final nameController = TextEditingController(text: exercise.name);
    final setsRepsController = TextEditingController(text: exercise.setsReps);
    final restTimeController = TextEditingController(text: exercise.restTime);
    final weightController = TextEditingController(
      text: exercise.weight?.toString() ?? '',
    );
    final notesController = TextEditingController(text: exercise.notes ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Editar Ejercicio',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.green.shade500,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: setsRepsController,
                  decoration: InputDecoration(
                    labelText: 'Series x Reps',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: restTimeController,
                  decoration: InputDecoration(
                    labelText: 'Tiempo de descanso',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: weightController,
                  decoration: InputDecoration(
                    labelText: 'Peso (kg)',
                    hintText: 'Dejar vacío para no registrar peso',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(
                    labelText: 'Notas',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: TextStyle(color: colors.onSurface),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref
                    .read(routineRepositoryProvider)
                    .updateExerciseWithData(
                      exerciseId: exercise.id!,
                      name: nameController.text,
                      setsReps: setsRepsController.text,
                      restTime: restTimeController.text,
                      weight: double.tryParse(weightController.text),
                      notes: notesController.text,
                    );
                ref.invalidate(exercisesProvider(routineId));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Guardar', style: TextStyle(color: colors.onPrimary)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteExercise(
    WidgetRef ref,
    int exerciseId,
    BuildContext context,
  ) async {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Eliminar Ejercicio',
          style: TextStyle(color: colors.error),
        ),
        content: const Text('¿Estás seguro de eliminar este ejercicio?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: TextStyle(color: colors.onSurface)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Eliminar', style: TextStyle(color: colors.onError)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(routineRepositoryProvider).deleteExercise(exerciseId);
      ref.invalidate(exercisesProvider(routineId));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      exercise.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade500,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.green.shade500),
                        onPressed: () => _showEditExerciseDialog(context, ref),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: colors.error),
                        onPressed: () =>
                            _deleteExercise(ref, exercise.id!, context),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoChip(Icons.repeat, exercise.setsReps, colors),
                  _buildInfoChip(Icons.timer, exercise.restTime, colors),
                  if (exercise.weight != null)
                    _buildWeightChip(exercise.weight!, colors),
                ],
              ),
              if (exercise.weight != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 20,
                      color: Colors.green.shade500,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${exercise.weight} kg',
                      style: TextStyle(fontSize: 16, color: colors.onSurface),
                    ),
                  ],
                ),
              ],
              if (exercise.notes != null && exercise.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  exercise.notes!,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: colors.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, ColorScheme colors) {
    return Chip(
      avatar: Icon(icon, size: 18, color: Colors.green.shade500),
      label: Text(text),
      backgroundColor: colors.surfaceVariant.withOpacity(0.3),
      side: BorderSide.none,
      shape: StadiumBorder(
        side: BorderSide(color: colors.outline.withOpacity(0.2)),
      ),
    );
  }

  Widget _buildWeightChip(double weight, ColorScheme colors) {
    return Chip(
      avatar: Icon(Icons.fitness_center, size: 18, color: colors.tertiary),
      label: Text('${weight.toStringAsFixed(1)} kg'),
      backgroundColor: colors.tertiaryContainer.withOpacity(0.3),
      side: BorderSide.none,
      shape: StadiumBorder(
        side: BorderSide(color: colors.outline.withOpacity(0.2)),
      ),
    );
  }
}

final routineRepositoryProvider = Provider<RoutineRepository>((ref) {
  final databaseAsync = ref.watch(databaseProvider);
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
