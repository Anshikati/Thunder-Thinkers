import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_providers.dart';
import '../../models/task.dart';
import '../../widgets/urgency_badge.dart';
import '../../widgets/status_timeline.dart';
import '../../widgets/category_icon.dart';
import '../../widgets/map_placeholder.dart';

class TaskDetailScreen extends StatelessWidget {
  final String taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final volunteerProv = context.watch<VolunteerProvider>();

    Task? task;
    try {
      task = volunteerProv.tasks.firstWhere((t) => t.id == taskId);
    } catch (_) {
      return Scaffold(
        appBar: AppBar(title: const Text('Task Detail')),
        body: const Center(child: Text('Task not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Task Detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CategoryIconWidget(category: task.category, size: 26),
                const SizedBox(width: 12),
                Expanded(child: Text(task.title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700))),
                UrgencyBadge(level: task.urgencyLevel),
              ],
            ),
            const SizedBox(height: 16),
            MapPlaceholder(height: 180),
            const SizedBox(height: 16),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _InfoRow(label: 'Location', value: task.location, icon: Icons.location_on_outlined),
                    const Divider(height: 16),
                    _InfoRow(label: 'Reported by', value: task.reportedBy, icon: Icons.person_outline),
                    const Divider(height: 16),
                    _InfoRow(label: 'People affected', value: '${task.peopleAffected} people', icon: Icons.people_outline),
                    const Divider(height: 16),
                    _InfoRow(label: 'Distance', value: '${task.distanceKm} km away', icon: Icons.near_me_outlined),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Skills Required', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: task.skillsNeeded.split(', ').map((s) => Chip(label: Text(s))).toList(),
            ),
            const SizedBox(height: 20),
            Text('Status', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            StatusTimeline(currentStatus: task.status),
            const SizedBox(height: 28),
            _ActionButton(task: task),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact: integrate calling/messaging in production')));
                },
                icon: const Icon(Icons.phone_outlined),
                label: const Text('Contact NGO'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _InfoRow({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final Task task;
  const _ActionButton({required this.task});

  @override
  Widget build(BuildContext context) {
    final (label, nextStatus) = switch (task.status) {
      'new' => ('Accept Task', 'assigned'),
      'assigned' => ('Mark In Progress', 'inProgress'),
      'inProgress' => ('Mark Completed', 'completed'),
      _ => ('Completed', ''),
    };

    if (task.status == 'completed') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF388E3C).withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle, color: Color(0xFF388E3C)),
            SizedBox(width: 8),
            Text('Task Completed', style: TextStyle(color: Color(0xFF388E3C), fontWeight: FontWeight.w700)),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () {
          context.read<VolunteerProvider>().updateTaskStatus(task.id, nextStatus);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Status updated: $nextStatus'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
        child: Text(label),
      ),
    );
  }
}
