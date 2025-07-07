import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro/application/auth_provider.dart';
import 'package:gymbro/data/models/pr_model.dart';
import 'package:gymbro/data/repositories/pr_repository.dart';

final prRepositoryProvider = Provider<PRRepository>((ref) {
  return PRRepository();
});

final prsProvider = FutureProvider<List<PR>>((ref) async {
  final repository = ref.read(prRepositoryProvider);
  return await repository.getAllPRs();
});

class PRsScreen extends ConsumerWidget {
  const PRsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final prsAsync = ref.watch(prsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('PRs')),
      floatingActionButton: user != null
          ? FloatingActionButton(
              onPressed: () => _showAddPRDialog(context, ref, user),
              child: const Icon(Icons.add),
            )
          : null,
      body: prsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (prs) {
          if (prs.isEmpty) {
            return const Center(child: Text('No hay PRs registrados'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: prs.length,
            itemBuilder: (context, index) {
              final pr = prs[index];
              return _PRCard(pr: pr);
            },
          );
        },
      ),
    );
  }

  void _showAddPRDialog(BuildContext context, WidgetRef ref, User user) {
    final exerciseController = TextEditingController();
    final weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar nuevo PR'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: exerciseController,
                decoration: const InputDecoration(labelText: 'Ejercicio'),
              ),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(labelText: 'Peso (kg)'),
                keyboardType: TextInputType.number,
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
                final newPR = PR(
                  exercise: exerciseController.text,
                  weight: double.tryParse(weightController.text) ?? 0,
                  date: DateTime.now().toString(),
                  userEmail: user.email ?? '',
                );

                await ref.read(prRepositoryProvider).addPR(newPR);
                ref.invalidate(prsProvider);
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}

class _PRCard extends StatelessWidget {
  final PR pr;

  const _PRCard({required this.pr});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pr.exercise,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${pr.weight} kg',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fecha: ${pr.date.split(' ')[0]}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Usuario: ${pr.userEmail.split('@').first}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
