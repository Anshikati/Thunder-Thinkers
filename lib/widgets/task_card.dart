import 'package:flutter/material.dart';
import '../models/task.dart';
import 'urgency_badge.dart';
import 'category_icon.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final String tab;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onUpdateStatus;

  const TaskCard({
    super.key,
    required this.task,
    required this.tab,
    this.onTap,
    this.onAccept,
    this.onDecline,
    this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CategoryIconWidget(category: task.category, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      task.title,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  UrgencyBadge(level: task.urgencyLevel, small: true),
                ],
              ),
              const SizedBox(height: 10),
              _InfoRow(icon: Icons.location_on_outlined, text: task.location),
              const SizedBox(height: 4),
              _InfoRow(icon: Icons.near_me_outlined, text: '${task.distanceKm} km away'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: task.skillsNeeded.split(', ').map((s) => InputChip(
                  label: Text(s, style: const TextStyle(fontSize: 11)),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onPressed: null,
                )).toList(),
              ),
              if (tab == 'new') ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onDecline,
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Decline'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: onAccept,
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              ] else if (tab == 'active') ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonal(
                    onPressed: onUpdateStatus,
                    child: const Text('Update Status'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(text, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
