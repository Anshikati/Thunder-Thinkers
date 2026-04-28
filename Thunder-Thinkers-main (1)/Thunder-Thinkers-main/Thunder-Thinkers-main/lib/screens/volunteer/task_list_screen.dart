import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/app_providers.dart';
import '../../widgets/task_card.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final volunteerProv = context.watch<VolunteerProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            Tab(text: 'New (${volunteerProv.newTasks.length})'),
            Tab(text: 'Active (${volunteerProv.activeTasks.length})'),
            Tab(text: 'Done'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _TaskTabView(tasks: volunteerProv.newTasks, tab: 'new'),
          _TaskTabView(tasks: volunteerProv.activeTasks, tab: 'active'),
          _TaskTabView(tasks: volunteerProv.completedTasks, tab: 'completed'),
        ],
      ),
    );
  }
}

class _TaskTabView extends StatelessWidget {
  final List tasks;
  final String tab;
  const _TaskTabView({required this.tasks, required this.tab});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text('No $tab tasks', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final task = tasks[i];
        return TaskCard(
          task: task,
          tab: tab,
          onTap: () => ctx.push('/volunteer/tasks/${task.id}'),
          onAccept: () {
            ctx.read<VolunteerProvider>().updateTaskStatus(task.id, 'assigned');
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: const Text('Task accepted!'),
                backgroundColor: const Color(0xFF388E3C),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            );
          },
          onDecline: () {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: const Text('Task declined'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            );
          },
          onUpdateStatus: () => _showStatusDialog(ctx, task.id),
        );
      },
    );
  }

  void _showStatusDialog(BuildContext context, String taskId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatusOption(label: 'Mark In Progress', status: 'inProgress', taskId: taskId),
            const SizedBox(height: 8),
            _StatusOption(label: 'Mark Completed', status: 'completed', taskId: taskId),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel'))],
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  final String label;
  final String status;
  final String taskId;
  const _StatusOption({required this.label, required this.status, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.tonal(
        onPressed: () {
          context.read<VolunteerProvider>().updateTaskStatus(taskId, status);
          Navigator.pop(context);
        },
        child: Text(label),
      ),
    );
  }
}
