import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_providers.dart';
import '../../widgets/map_placeholder.dart';
import '../../widgets/task_card.dart';

class VolunteerMapScreen extends StatelessWidget {
  const VolunteerMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final volunteerProv = context.watch<VolunteerProvider>();
    final nearbyTasks = [...volunteerProv.newTasks, ...volunteerProv.activeTasks];

    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Tasks')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Stack(
              children: [
                MapPlaceholder(height: 300),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Column(
                    children: nearbyTasks.map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: theme.colorScheme.primary.withOpacity(0.4), blurRadius: 8, spreadRadius: 2)],
                        ),
                        child: const Icon(Icons.location_pin, color: Colors.white, size: 20),
                      ),
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('${nearbyTasks.length} tasks nearby', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                const Icon(Icons.filter_list, size: 20),
                const SizedBox(width: 4),
                const Text('Filter'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: nearbyTasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final task = nearbyTasks[i];
                return Column(
                  children: [
                    TaskCard(task: task, tab: task.status == 'new' ? 'new' : 'active'),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Navigate: integrate Google Maps deep link in production')),
                          );
                        },
                        icon: const Icon(Icons.navigation_outlined),
                        label: const Text('Navigate'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
