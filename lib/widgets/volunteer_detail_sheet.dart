import 'package:flutter/material.dart';
import '../models/volunteer.dart';

class VolunteerDetailSheet extends StatelessWidget {
  final Volunteer volunteer;
  final String? needId;
  final VoidCallback? onAssign;

  const VolunteerDetailSheet({
    super.key,
    required this.volunteer,
    this.needId,
    this.onAssign,
  });

  static Future<void> show(
    BuildContext context,
    Volunteer volunteer, {
    String? needId,
    VoidCallback? onAssign,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => VolunteerDetailSheet(
        volunteer: volunteer,
        needId: needId,
        onAssign: onAssign,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      expand: false,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  volunteer.name.substring(0, 1),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(volunteer.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: volunteer.isAvailable
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        volunteer.isAvailable ? 'Available' : 'Currently Busy',
                        style: TextStyle(
                          color: volunteer.isAvailable ? const Color(0xFF388E3C) : const Color(0xFFF57C00),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionLabel(label: 'Skills', theme: theme),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: volunteer.skills.map((s) => Chip(label: Text(s))).toList(),
          ),
          const SizedBox(height: 16),
          _SectionLabel(label: 'Stats', theme: theme),
          const SizedBox(height: 8),
          Row(
            children: [
              _StatTile(label: 'Tasks Done', value: '${volunteer.tasksCompleted}'),
              const SizedBox(width: 12),
              _StatTile(label: 'Hours', value: '${volunteer.hoursVolunteered}'),
              const SizedBox(width: 12),
              _StatTile(label: 'Impact', value: '${volunteer.impactScore}'),
            ],
          ),
          const SizedBox(height: 16),
          _SectionLabel(label: 'Location', theme: theme),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(volunteer.location, style: theme.textTheme.bodyMedium),
            ],
          ),
          if (volunteer.currentTaskId != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.work_outline, color: theme.colorScheme.onSecondaryContainer),
                  const SizedBox(width: 8),
                  Text(
                    'Currently on task: ${volunteer.currentTaskId}',
                    style: TextStyle(color: theme.colorScheme.onSecondaryContainer, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: volunteer.isAvailable ? () {
              Navigator.pop(context);
              onAssign?.call();
            } : null,
            icon: const Icon(Icons.assignment_ind),
            label: const Text('Assign Task'),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final ThemeData theme;
  const _SectionLabel({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: theme.textTheme.labelLarge?.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    ),
  );
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
            Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
