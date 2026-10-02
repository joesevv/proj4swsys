import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/write_service.dart';
import '../theme/app_theme.dart';
import 'task_card.dart';

/// panel with a title, a task count, and a list of TaskCards.
class TaskColumn extends StatelessWidget {
  const TaskColumn({
    super.key,
    required this.title,
    required this.width,
    required this.tasks,
    required this.writer,
    required this.status,
  });

  final String title;
  final double width;
  final List<Task> tasks;
  final WriteService writer;
  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final appColors = context.appColors;
    final accent = switch (status) {
      TaskStatus.todo => appColors.todo,
      TaskStatus.inprogress => appColors.inProgress,
      TaskStatus.done => appColors.done,
    };
    final icon = switch (status) {
      TaskStatus.todo => Icons.radio_button_unchecked,
      TaskStatus.inprogress => Icons.timelapse_rounded,
      TaskStatus.done => Icons.check_circle_outline_rounded,
    };

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: appColors.columnBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: appColors.columnBorder),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            child: Row(
              children: [
                Icon(icon, color: accent, size: 20),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${tasks.length}',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: tasks.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 38,
                      color: accent.withValues(alpha: .5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      switch (status) {
                        TaskStatus.todo => 'Room for your next idea',
                        TaskStatus.inprogress => 'Ready when you are',
                        TaskStatus.done => 'Good things take teamwork',
                      },
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            )
                : ListView.builder(
              // Extra bottom padding so the "Add task" button doesn't cover the last card.
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
              itemCount: tasks.length,
              itemBuilder: (context, i) =>
                  TaskCard(task: tasks[i], writer: writer),
            ),
          ),
        ],
      ),
    );
  }
}