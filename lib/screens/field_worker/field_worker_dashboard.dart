import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/app_providers.dart';
import '../../models/need.dart';
import '../../widgets/urgency_badge.dart';
import '../../widgets/category_icon.dart';

class FieldWorkerDashboard extends StatefulWidget {
  const FieldWorkerDashboard({super.key});

  @override
  State<FieldWorkerDashboard> createState() => _FieldWorkerDashboardState();
}

class _FieldWorkerDashboardState extends State<FieldWorkerDashboard> {
  int _navIndex = 0;

  void _onNavTap(int index) {
    setState(() => _navIndex = index);
    switch (index) {
      case 1: context.push('/fieldworker/report');
      case 2: context.push('/fieldworker/myreports');
      case 3: context.push('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final needs = context.watch<NeedsProvider>();
    final user = auth.currentUser;
    final myReports = user != null ? needs.needsByFieldWorker(user.id) : <Need>[];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello, ${user?.name.split(' ').first ?? 'Worker'} 👋', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            Text(user?.location ?? 'Field Area', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
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
            _QuickActions(),
            const SizedBox(height: 24),
            Text('Recent Submissions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if (myReports.isEmpty)
              _EmptyState()
            else
              ...myReports.take(5).map((n) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _RecentSubmissionTile(need: n),
              )),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: _onNavTap,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), selectedIcon: Icon(Icons.add_circle), label: 'Report'),
          NavigationDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list_alt), label: 'My Reports'),
          NavigationDestination(icon: Icon(Icons.person_outlined), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final _actions = const [
    (Icons.report_problem_outlined, 'Report Need', '/fieldworker/report', Color(0xFF00695C)),
    (Icons.mic_outlined, 'Voice Report', '/fieldworker/voice', Color(0xFF7B1FA2)),
    (Icons.document_scanner_outlined, 'Scan Form', '/fieldworker/scan', Color(0xFF1565C0)),
    (Icons.list_alt_outlined, 'My Reports', '/fieldworker/myreports', Color(0xFFF57C00)),
  ];

  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
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
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _RecentSubmissionTile extends StatelessWidget {
  final Need need;
  const _RecentSubmissionTile({required this.need});

  String get _timeAgo {
    final diff = DateTime.now().difference(need.timestamp);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          CategoryIconWidget(category: need.categoryLabel, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(need.description, style: theme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(need.location, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              UrgencyBadge(level: need.urgencyLabel, small: true),
              const SizedBox(height: 4),
              Text(_timeAgo, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text('No submissions yet', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
