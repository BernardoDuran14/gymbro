import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro/application/auth_provider.dart';
import 'package:gymbro/presentation/screens/routines_screen.dart';
import 'package:gymbro/presentation/screens/prs_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GymBro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Botón de Rutinas
            _buildMenuButton(
              context,
              'Rutinas',
              Icons.fitness_center,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RoutinesScreen()),
              ),
            ),
            const SizedBox(height: 20),
            // Botón de PRs
            _buildMenuButton(
              context,
              'PRs',
              Icons.leaderboard,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PRsScreen()),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 100,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 40),
        label: Text(title, style: Theme.of(context).textTheme.headlineSmall),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(20),
        ),
      ),
    );
  }
}
