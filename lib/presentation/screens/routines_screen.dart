import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro/application/routines_provider.dart';
import 'package:gymbro/data/models/routine_model.dart';
import 'package:gymbro/presentation/screens/routine_detail_screen.dart';

class RoutinesScreen extends ConsumerWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesAsync = ref.watch(routinesProvider);
    final routines = ref.watch(routinesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Rutinas')),
      body: routinesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (routines) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: routines.length,
          itemBuilder: (context, index) {
            final routine = routines[index];
            return _RoutineCard(routine: routine);
          },
        ),
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  final Routine routine;

  const _RoutineCard({required this.routine});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
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
            Text(routine.description),
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
                child: const Text('Ver ejercicios'),
              ),
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
