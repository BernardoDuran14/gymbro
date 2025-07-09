import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro/application/auth_provider.dart';
import 'package:gymbro/application/pr_provider.dart';
import 'package:gymbro/presentation/screens/routines_screen.dart';
import 'package:gymbro/presentation/screens/prs_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _syncPRs();
  }

  void _syncPRs() {
    final authState = ref.read(authProvider);
    if (authState.user != null) {
      ref.read(prRepositoryProvider).syncPRs(authState.user!.email!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GymBro'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.green.shade500),
            onPressed: () => ref.read(authProvider.notifier).logout(),
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Mensaje de bienvenida
              Text(
                '¡Bienvenido${user?.email != null ? ', ${user?.email?.split('@').first}' : ''}!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colors.onBackground,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '¿Qué deseas hacer hoy?',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.onBackground.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 40),

              // Botón de Rutinas
              _buildMenuButton(
                context,
                'Mis Rutinas',
                Icons.fitness_center,
                Colors.green.shade500,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RoutinesScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Botón de PRs
              _buildMenuButton(
                context,
                'Mis PRs',
                Icons.leaderboard,
                Colors.green.shade500,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PRsScreen()),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 100,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.2),
          foregroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: color, width: 2),
          ),
          elevation: 0,
          padding: const EdgeInsets.all(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 16),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
