import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/write_service.dart';
import 'task_card.dart';

/// panel with a title, a task count, and a list of TaskCards.
class TaskColumn extends StatelessWidget {
  const TaskColumn({
    super.key,
    required this.title,
    required this.width,
    required this.tasks,
    required this.writer,
  });

  final String title;
  final double width;
  final List<Task> tasks;
  final WriteService writer;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Text(title, style: textTheme.titleMedium),
                const Spacer(),
                Text('${tasks.length}', style: textTheme.labelLarge),
              ],
            ),
          ),
          Expanded(
            child: tasks.isEmpty
                ? Center(
              child: Text('Nothing here yet', style: TextStyle(color: colors.onSurfaceVariant)),
            )
                : ListView.builder(
              // Extra bottom padding so the "Add task" button doesn't cover the last card.
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 88),
              itemCount: tasks.length,
              itemBuilder: (context, i) => TaskCard(task: tasks[i], writer: writer),
            ),
          ),
        ],
      ),
    );
  }
}
