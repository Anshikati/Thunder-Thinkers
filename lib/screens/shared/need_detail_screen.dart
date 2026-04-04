import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_providers.dart';
import '../../models/need.dart';
import '../../widgets/urgency_badge.dart';
import '../../widgets/status_timeline.dart';
import '../../widgets/category_icon.dart';
import '../../widgets/volunteer_detail_sheet.dart';

class NeedDetailScreen extends StatelessWidget {
  final String needId;
  const NeedDetailScreen({super.key, required this.needId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final needsProv = context.watch<NeedsProvider>();
    final volunteerProv = context.watch<VolunteerProvider>();

    Need? need;
    try {
      need = needsProv.needs.firstWhere((n) => n.id == needId);
    } catch (_) {
      return Scaffold(
        appBar: AppBar(title: const Text('Need Detail')),
        body: const Center(child: Text('Need not found')),
      );
    }

    final assignedVol = need.assignedVolunteerId != null
        ? volunteerProv.volunteers.where((v) => v.id == need!.assignedVolunteerId).firstOrNull
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Need Detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CategoryIconWidget(category: need.categoryLabel, size: 26),
                const SizedBox(width: 12),
                Expanded(child: Text(need.categoryLabel, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700))),
                UrgencyBadge(level: need.urgencyLabel),
              ],
            ),
            const SizedBox(height: 16),
            Text(need.description, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.5)),
            const SizedBox(height: 16),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _InfoRow(icon: Icons.location_on_outlined, label: 'Location', value: need.location),
                    const Divider(height: 16),
                    _InfoRow(icon: Icons.people_outline, label: 'People Affected', value: '${need.peopleAffected} people'),
                    const Divider(height: 16),
                    _InfoRow(icon: Icons.person_outline, label: 'Submitted By', value: need.submittedBy),
                    const Divider(height: 16),
                    _InfoRow(
                      icon: Icons.schedule_outlined,
                      label: 'Reported At',
                      value: DateFormat('MMM d, yyyy • h:mm a').format(need.timestamp),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Assigned Volunteer', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            assignedVol != null
                ? Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Text(assignedVol.name.substring(0, 1), style: TextStyle(fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(assignedVol.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600))),
                        Chip(label: Text(assignedVol.isAvailable ? 'Available' : 'Busy'), labelStyle: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person_off_outlined, color: theme.colorScheme.error),
                        const SizedBox(width: 8),
                        Text('Unassigned', style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
            const SizedBox(height: 20),
            Text('Status', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            StatusTimeline(currentStatus: need.statusLabel),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _showVolunteerPicker(context, need!, needsProv, volunteerProv),
                icon: const Icon(Icons.assignment_ind_outlined),
                label: Text(assignedVol != null ? 'Reassign Volunteer' : 'Assign Volunteer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVolunteerPicker(BuildContext context, Need need, NeedsProvider needsProv, VolunteerProvider volunteerProv) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Assign a Volunteer', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              ...volunteerProv.availableVolunteers.map((v) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(v.name.substring(0, 1), style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w700)),
                ),
                title: Text(v.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(v.skills.take(2).join(', ')),
                trailing: FilledButton(
                  onPressed: () {
                    needsProv.assignVolunteer(need.id, v.id);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${v.name} assigned successfully'),
                        backgroundColor: const Color(0xFF388E3C),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    );
                  },
                  child: const Text('Assign'),
                ),
              )),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

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
