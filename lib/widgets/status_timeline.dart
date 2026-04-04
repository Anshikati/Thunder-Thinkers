import 'package:flutter/material.dart';

class StatusTimeline extends StatelessWidget {
  final String currentStatus;

  const StatusTimeline({super.key, required this.currentStatus});

  static const _steps = ['Reported', 'Assigned', 'In Progress', 'Completed'];

  int get _currentIndex {
    switch (currentStatus.toLowerCase().replaceAll(' ', '')) {
      case 'assigned': return 1;
      case 'inprogress': return 2;
      case 'completed': return 3;
      default: return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = _currentIndex;

    return Row(
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final stepIdx = i ~/ 2;
          final filled = stepIdx < current;
          return Expanded(
            child: Container(
              height: 2,
              color: filled ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
            ),
          );
        }
        final stepIdx = i ~/ 2;
        final isDone = stepIdx < current;
        final isCurrent = stepIdx == current;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone
                    ? theme.colorScheme.primary
                    : isCurrent
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainerHighest,
                border: isCurrent
                    ? Border.all(color: theme.colorScheme.primary, width: 2)
                    : null,
              ),
              child: isDone
                  ? Icon(Icons.check, size: 16, color: theme.colorScheme.onPrimary)
                  : isCurrent
                      ? Icon(Icons.circle, size: 10, color: theme.colorScheme.primary)
                      : null,
            ),
            const SizedBox(height: 4),
            Text(
              _steps[stepIdx],
              style: theme.textTheme.labelSmall?.copyWith(
                color: isCurrent || isDone
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      }),
    );
  }
}
