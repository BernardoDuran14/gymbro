import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro/application/pr_provider.dart';
import 'package:gymbro/data/models/pr_model.dart';
import 'package:gymbro/data/repositories/pr_repository.dart';

final prsProvider = FutureProvider<List<PR>>((ref) async {
  final repository = ref.read(prRepositoryProvider);
  return await repository.getAllPRs();
});

class PRsScreen extends ConsumerWidget {
  const PRsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prsAsync = ref.watch(prsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis PRs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(prsProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPRDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: prsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (prs) => _buildPRsList(prs, ref),
      ),
    );
  }

  Widget _buildPRsList(List<PR> prs, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(prsProvider),
      child: ListView.builder(
        itemCount: prs.length,
        itemBuilder: (_, index) => _PRCard(pr: prs[index]),
      ),
    );
  }

  void _showAddPRDialog(BuildContext context, WidgetRef ref) {
    final exerciseController = TextEditingController();
    final weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo PR'),
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
              if (exerciseController.text.isEmpty ||
                  weightController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Completa todos los campos')),
                );
                return;
              }

              try {
                final newPR = PR(
                  exercise: exerciseController.text,
                  weight: double.parse(weightController.text),
                  date: DateTime.now().toString(),
                  userEmail: 'user@example.com', // Reemplaza con usuario real
                );

                await ref.read(prRepositoryProvider).addPR(newPR);
                ref.invalidate(prsProvider);
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

class _PRCard extends StatelessWidget {
  final PR pr;

  const _PRCard({required this.pr});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
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
            Text('${pr.weight} kg'),
            Text('Fecha: ${pr.date.split(' ')[0]}'),
            Text('Usuario: ${pr.userEmail.split('@').first}'),
          ],
        ),
      ),
    );
  }
}
