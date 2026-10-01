import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/write_service.dart';

/// show exactly one of: a Start button (todo), a Done button
/// (in progress and started by me), or nothing. The card never updates itself;
/// the stream repaints it when the write lands.
class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, required this.writer});

  final Task task;
  final WriteService writer;

  Future<void> _run(BuildContext context, Future<void> Function() action) async {
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
    final subtitle = switch (task.status) {
      TaskStatus.todo => 'Added by ${task.createdByName}',
      TaskStatus.inprogress => 'Started by ${task.startedByName ?? '?'}',
      TaskStatus.done => 'Finished by ${task.startedByName ?? '?'}',
    };

    Widget? button;
    if (task.status == TaskStatus.todo) {
      button = FilledButton.tonal(
        onPressed: () => _run(context, () => writer.startTask(task.boardId, task.id)),
        child: const Text('Start'),
      );
    } else if (task.status == TaskStatus.inprogress && task.startedByUid == writer.uid) {
      button = FilledButton(
        onPressed: () => _run(context, () => writer.finishTask(task.boardId, task.id)),
        child: const Text('Done'),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(task.title),
        subtitle: Text(subtitle),
        trailing: button,
      ),
    );
  }
}
