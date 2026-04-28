import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/app_providers.dart';
import '../../models/task.dart';
import '../../widgets/urgency_badge.dart';
import '../../widgets/category_icon.dart';

class VolunteerDashboard extends StatefulWidget {
  const VolunteerDashboard({super.key});

  @override
  State<VolunteerDashboard> createState() => _VolunteerDashboardState();
}

class _VolunteerDashboardState extends State<VolunteerDashboard> {
  int _navIndex = 0;

  void _onNavTap(int index) {
    setState(() => _navIndex = index);
    switch (index) {
      case 1: context.push('/volunteer/tasks');
      case 2: context.push('/volunteer/map');
      case 3: context.push('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final volunteerProv = context.watch<VolunteerProvider>();
    final user = auth.currentUser;

    final activeTask = volunteerProv.activeTaskFor('v3');
    final newCount = volunteerProv.newTasks.length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello, ${user?.name.split(' ').first ?? 'Volunteer'} 👋', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            Text('You have $newCount task(s) waiting', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary, fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          IconButton(
            icon: Badge(label: const Text('2'), child: const Icon(Icons.notifications_outlined)),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (activeTask != null) ...[
              _ActiveTaskCard(task: activeTask),
              const SizedBox(height: 20),
            ],
            _StatsRow(
              completed: volunteerProv.completedTasks.length,
              hours: 68,
              impact: 420,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Available Tasks Nearby', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                TextButton(onPressed: () => context.push('/volunteer/tasks'), child: const Text('See All')),
              ],
            ),
            const SizedBox(height: 8),
            ...volunteerProv.newTasks.take(3).map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _NearbyTaskTile(
                task: t,
                onTap: () => context.push('/volunteer/tasks/${t.id}'),
              ),
            )),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: _onNavTap,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.task_outlined), selectedIcon: Icon(Icons.task), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Map'),
          NavigationDestination(icon: Icon(Icons.person_outlined), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _ActiveTaskCard extends StatelessWidget {
  final Task task;
  const _ActiveTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.work_outline, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text('Active Task', style: theme.textTheme.labelMedium?.copyWith(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 8),
          Text(task.title, style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Colors.white70),
              const SizedBox(width: 4),
              Expanded(child: Text(task.location, style: const TextStyle(color: Colors.white70, fontSize: 12))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Text(task.urgencyLevel, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.push('/volunteer/tasks/${task.id}'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white)),
            child: const Text('View Task'),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int completed;
  final int hours;
  final int impact;
  const _StatsRow({required this.completed, required this.hours, required this.impact});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        _StatItem(label: 'Tasks Done', value: '$completed', icon: Icons.task_alt, color: const Color(0xFF388E3C)),
        const SizedBox(width: 10),
        _StatItem(label: 'Hours Given', value: '$hours', icon: Icons.schedule, color: const Color(0xFF1565C0)),
        const SizedBox(width: 10),
        _StatItem(label: 'Impact Score', value: '$impact', icon: Icons.stars, color: const Color(0xFFFFA000)),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatItem({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: color)),
            Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: 10), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _NearbyTaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  const _NearbyTaskTile({required this.task, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            CategoryIconWidget(category: task.category, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('${task.distanceKm} km • ${task.location}', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            UrgencyBadge(level: task.urgencyLevel, small: true),
          ],
        ),
      ),
    );
  }
}
