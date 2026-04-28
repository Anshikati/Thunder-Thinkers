import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/app_providers.dart';
import '../../models/need.dart';
import '../../widgets/need_card.dart';
import '../../widgets/urgency_badge.dart';
import '../../widgets/category_icon.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<NeedsProvider>().loadNeeds();
      context.read<VolunteerProvider>().loadVolunteers();
    });
  }

  void _onNavTap(int index) {
    setState(() => _navIndex = index);
    switch (index) {
      case 1: context.push('/admin/map');
      case 2: context.push('/admin/volunteers');
      case 3: context.push('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final needs = context.watch<NeedsProvider>();
    final volunteers = context.watch<VolunteerProvider>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello, ${user?.name.split(' ').first ?? 'Admin'} 👋', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            Text(user?.orgName ?? 'Organization', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Badge(label: Text('2'), child: Icon(Icons.notifications_outlined)),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NGOHeroBanner(
              onAddNeed: () => context.push('/admin/add-need'),
            ),
            const SizedBox(height: 28),
            _StatsRow(
              total: needs.totalCount,
              pending: needs.pendingCount,
              inProgress: needs.inProgressCount,
              completed: needs.completedCount,
            ),
            const SizedBox(height: 24),
            const _QuickActions(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Needs', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                TextButton(onPressed: () => context.push('/admin/map'), child: const Text('See All')),
              ],
            ),
            const SizedBox(height: 8),
            ...needs.needs.take(3).map((n) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: NeedCard(need: n, onTap: () => context.push('/admin/need/${n.id}')),
            )),
            const SizedBox(height: 24),
            Text('Active Volunteers', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: volunteers.volunteers.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final v = volunteers.volunteers[i];
                  return _VolunteerChip(name: v.name, isAvailable: v.isAvailable);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/add-need'),
        icon: const Icon(Icons.add),
        label: const Text('Add Need'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: _onNavTap,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Map'),
          NavigationDestination(icon: Icon(Icons.group_outlined), selectedIcon: Icon(Icons.group), label: 'Volunteers'),
          NavigationDestination(icon: Icon(Icons.person_outlined), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int total, pending, inProgress, completed;
  const _StatsRow({required this.total, required this.pending, required this.inProgress, required this.completed});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          _StatCard(label: 'Total Reports', value: '$total', color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          _StatCard(label: 'Pending', value: '$pending', color: const Color(0xFFF57C00)),
          const SizedBox(width: 12),
          _StatCard(label: 'In Progress', value: '$inProgress', color: const Color(0xFF1565C0)),
          const SizedBox(width: 12),
          _StatCard(label: 'Resolved', value: '$completed', color: const Color(0xFF388E3C)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _VolunteerChip extends StatelessWidget {
  final String name;
  final bool isAvailable;
  const _VolunteerChip({required this.name, required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 90,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(name.substring(0, 1), style: TextStyle(fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
          ),
          const SizedBox(height: 6),
          Text(name.split(' ').first, style: theme.textTheme.labelSmall, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isAvailable ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              isAvailable ? 'Free' : 'Busy',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: isAvailable ? const Color(0xFF388E3C) : const Color(0xFFF57C00)),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final _actions = const [
    (Icons.mic_outlined, 'Voice Report', '/fieldworker/voice', Color(0xFF7B1FA2)),
    (Icons.document_scanner_outlined, 'Scan Form', '/fieldworker/scan', Color(0xFF1565C0)),
  ];

  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('AI Assistant', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Row(
          children: _actions.map((action) {
            final (icon, label, route, color) = action;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _ActionButton(icon: icon, label: label, color: color, route: route),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String route;
  const _ActionButton({required this.icon, required this.label, required this.color, required this.route});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
class _NGOHeroBanner extends StatelessWidget {
  final VoidCallback onAddNeed;
  const _NGOHeroBanner({required this.onAddNeed});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.analytics_outlined, color: Colors.white, size: 32),
            const SizedBox(height: 16),
            Text(
              'Coordinate. Respond. Save Lives.',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Monitor real-time needs and manage your volunteer force efficiently.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onAddNeed,
              icon: const Icon(Icons.add),
              label: const Text('Add Manual Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1565C0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
