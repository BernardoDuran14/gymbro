import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro/application/routines_provider.dart';
import 'package:gymbro/data/models/routine_model.dart';
import 'package:gymbro/presentation/screens/routine_detail_screen.dart'
    hide routineRepositoryProvider;

class RoutinesScreen extends ConsumerWidget {
  const RoutinesScreen({super.key});

  void _showAddRoutineDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final levelController = TextEditingController(text: 'Principiante');
    final descController = TextEditingController();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Nueva Rutina',
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
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green.shade500),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: 'Principiante',
                items: ['Principiante', 'Intermedio', 'Avanzado']
                    .map(
                      (level) =>
                          DropdownMenuItem(value: level, child: Text(level)),
                    )
                    .toList(),
                onChanged: (value) => levelController.text = value!,
                decoration: InputDecoration(
                  labelText: 'Nivel',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                dropdownColor: colors.surface,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
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
                final newRoutine = Routine(
                  name: nameController.text,
                  level: levelController.text,
                  description: descController.text,
                );

                await ref
                    .read(routineRepositoryProvider)
                    .addRoutine(newRoutine);
                ref.invalidate(routinesProvider);
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

  Future<void> _deleteRoutine(
    BuildContext context,
    WidgetRef ref,
    int routineId,
  ) async {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Rutina', style: TextStyle(color: colors.error)),
        content: const Text('¿Estás seguro de eliminar esta rutina?'),
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
      await ref.read(routineRepositoryProvider).deleteRoutine(routineId);
      ref.invalidate(routinesProvider);
    }
  }

  Future<void> _editRoutine(
    BuildContext context,
    WidgetRef ref,
    Routine updatedRoutine,
  ) async {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final nameController = TextEditingController(text: updatedRoutine.name);
    final levelController = TextEditingController(text: updatedRoutine.level);
    final descController = TextEditingController(
      text: updatedRoutine.description,
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Editar Rutina',
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
              DropdownButtonFormField<String>(
                value: updatedRoutine.level,
                items: ['Principiante', 'Intermedio', 'Avanzado']
                    .map(
                      (level) =>
                          DropdownMenuItem(value: level, child: Text(level)),
                    )
                    .toList(),
                onChanged: (value) => levelController.text = value!,
                decoration: InputDecoration(
                  labelText: 'Nivel',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                dropdownColor: colors.surface,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
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
              onPressed: () {
                final updated = updatedRoutine.copyWith(
                  name: nameController.text,
                  level: levelController.text,
                  description: descController.text,
                );
                ref.read(routineRepositoryProvider).updateRoutine(updated);
                ref.invalidate(routinesProvider);
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final routinesAsync = ref.watch(routinesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Rutinas'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.green),
            onPressed: () => _showAddRoutineDialog(context, ref),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade500.withOpacity(0.1), colors.background],
          ),
        ),
        child: routinesAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(color: Colors.green.shade500),
          ),
          error: (error, stack) => Center(
            child: Text('Error: $error', style: TextStyle(color: colors.error)),
          ),
          data: (routines) {
            if (routines.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 60,
                      color: colors.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay rutinas creadas',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Presiona el botón + para crear una',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: routines.length,
              itemBuilder: (context, index) {
                final routine = routines[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _RoutineCard(
                    routine: routine,
                    onDelete: () => _deleteRoutine(context, ref, routine.id!),
                    onEdit: (updated) => _editRoutine(context, ref, updated),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  final Routine routine;
  final VoidCallback onDelete;
  final Function(Routine) onEdit;

  const _RoutineCard({
    required this.routine,
    required this.onDelete,
    required this.onEdit,
  });

  void _showEditDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final nameController = TextEditingController(text: routine.name);
    final levelController = TextEditingController(text: routine.level);
    final descController = TextEditingController(text: routine.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Editar Rutina',
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
              DropdownButtonFormField<String>(
                value: routine.level,
                items: ['Principiante', 'Intermedio', 'Avanzado']
                    .map(
                      (level) =>
                          DropdownMenuItem(value: level, child: Text(level)),
                    )
                    .toList(),
                onChanged: (value) => levelController.text = value!,
                decoration: InputDecoration(
                  labelText: 'Nivel',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                dropdownColor: colors.surface,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
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
              onPressed: () {
                final updatedRoutine = routine.copyWith(
                  name: nameController.text,
                  level: levelController.text,
                  description: descController.text,
                );
                onEdit(updatedRoutine);
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

  Color _getLevelColor(String level, ColorScheme colors) {
    switch (level.toLowerCase()) {
      case 'principiante':
        return Colors.green.shade500.withOpacity(0.2);
      case 'intermedio':
        return colors.secondary.withOpacity(0.2);
      case 'avanzado':
        return colors.tertiary.withOpacity(0.2);
      default:
        return colors.surfaceVariant.withOpacity(0.2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RoutineDetailScreen(routineId: routine.id!),
            ),
          );
        },
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
                      routine.name,
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
                        onPressed: () => _showEditDialog(context),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: colors.error),
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ],
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
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RoutineDetailScreen(routineId: routine.id!),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade500.withOpacity(0.1),
                    foregroundColor: Colors.green.shade500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Ver ejercicios'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
