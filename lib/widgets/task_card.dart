import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/write_service.dart';
import '../theme/app_theme.dart';

/// show exactly one of: a Start button (todo), a Done button
/// (in progress and started by me), or nothing. The card never updates itself;
/// the stream repaints it when the write lands.
class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, required this.writer});

  final Task task;
  final WriteService writer;

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text(
          '“${task.title}” will be permanently removed from this board.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await _run(context, () => writer.deleteTask(task.boardId, task.id));
    }
  }

  Future<void> _run(
      BuildContext context,
      Future<void> Function() action,
      ) async {
    /// if another member's change moves this card first, the card is gone by the time the error arrives, but the message must still show.
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final subtitle = switch (task.status) {
      TaskStatus.todo => 'Added by ${task.createdByName}',
      TaskStatus.inprogress => 'Started by ${task.startedByName ?? '?'}',
      TaskStatus.done => 'Finished by ${task.startedByName ?? '?'}',
    };

    Widget? button;
    if (task.status == TaskStatus.todo) {
      button = FilledButton.tonal(
        onPressed: () =>
            _run(context, () => writer.startTask(task.boardId, task.id)),
        child: const Text('Start'),
      );
    } else if (task.status == TaskStatus.inprogress &&
        task.startedByUid == writer.uid) {
      button = FilledButton(
        onPressed: () =>
            _run(context, () => writer.finishTask(task.boardId, task.id)),
        child: const Text('Done'),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Delete task',
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  color: colors.muted,
                  onPressed: () => _delete(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  size: 16,
                  color: colors.muted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.muted,
                    ),
                  ),
                ),
              ],
            ),
            if (button != null) ...[
              const SizedBox(height: 14),
              Align(alignment: Alignment.centerRight, child: button),
            ],
          ],
        ),
      ),
    );
  }
}