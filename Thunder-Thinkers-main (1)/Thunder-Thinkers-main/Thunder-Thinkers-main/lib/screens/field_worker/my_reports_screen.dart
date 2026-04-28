import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_providers.dart';
import '../../models/need.dart';
import '../../widgets/urgency_badge.dart';
import '../../widgets/category_icon.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final needs = context.watch<NeedsProvider>();
    final myNeeds = auth.currentUser != null
        ? needs.needsByFieldWorker(auth.currentUser!.id)
        : needs.needs;

    return Scaffold(
      appBar: AppBar(title: const Text('My Reports')),
      body: myNeeds.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.assignment_outlined, size: 56, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(height: 12),
                  Text('No reports submitted yet', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () => context.push('/fieldworker/report'),
                    icon: const Icon(Icons.add),
                    label: const Text('Report a Need'),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: myNeeds.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _ReportTile(need: myNeeds[i]),
            ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  final Need need;
  const _ReportTile({required this.need});

  String get _statusLabel => need.statusLabel;
  Color get _statusColor => switch (need.status) {
    NeedStatus.completed => const Color(0xFF388E3C),
    NeedStatus.inProgress => const Color(0xFF1565C0),
    NeedStatus.assigned => const Color(0xFFF57C00),
    _ => const Color(0xFF757575),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CategoryIconWidget(category: need.categoryLabel, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(need.categoryLabel, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                ),
                UrgencyBadge(level: need.urgencyLabel, small: true),
              ],
            ),
            const SizedBox(height: 8),
            Text(need.description, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 13, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 2),
                Expanded(child: Text(need.location, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant), overflow: TextOverflow.ellipsis)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _statusColor.withOpacity(0.4)),
                  ),
                  child: Text(_statusLabel, style: TextStyle(color: _statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(DateFormat('MMM d, yyyy • h:mm a').format(need.timestamp), style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
