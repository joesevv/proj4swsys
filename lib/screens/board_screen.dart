import 'package:flutter/material.dart';
import '../models/board.dart';
import '../models/task.dart';
import '../services/auth_service.dart';
import '../services/board_service.dart';
import '../services/write_service.dart';
import '../widgets/task_column.dart';

///three columns of tasks that update live for every member.
class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key, required this.board, required this.auth});

  final Board board;
  final AuthService auth;

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  final BoardService _boards = BoardService();
  late final WriteService _writer;

  /// so rebuild doenst open a second firestore listener
  late final Stream<List<Task>> _tasks;

  @override
  void initState() {
    super.initState();
    _writer = WriteService(uid: widget.auth.currentUser!.uid, name: widget.auth.currentName);
    _tasks = _boards.tasks(widget.board.id);
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _addTask() async {
    final title = await showDialog<String>(
      context: context,
      builder: (_) => const _AddTaskDialog(),
    );
    final trimmed = title?.trim() ?? '';
    if (trimmed.isEmpty) return;
    try {
      await _writer.addTask(widget.board.id, trimmed);
    } catch (e) {
      _snack('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.board.name),
            Text('Code: ${widget.board.code}', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTask,
        icon: const Icon(Icons.add),
        label: const Text('Add task'),
      ),
      body: StreamBuilder<List<Task>>(
        stream: _tasks,
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Could not load tasks: ${snap.error}', textAlign: TextAlign.center),
              ),
            );
          }
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final tasks = snap.data!;

          /// ostream, split three ways in Dart. On a wide screen the three columns , share the width, phone has own styling parameters as well
          return LayoutBuilder(
            builder: (context, constraints) {
              const padding = 12.0;
              const spacing = 12.0;
              final available = constraints.maxWidth - padding * 2;
              final columnWidth = available >= 3 * 280 + 2 * spacing
                  ? (available - 2 * spacing) / 3
                  : (available - spacing).clamp(280.0, 560.0);

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(padding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final status in TaskStatus.values)
                      Padding(
                        padding: const EdgeInsets.only(right: spacing),
                        child: TaskColumn(
                          title: status.label,
                          width: columnWidth,
                          tasks: tasks.where((t) => t.status == status).toList(),
                          writer: _writer,
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
/// dialog for entering new task title , text controller disposed of when dialog closed
class _AddTaskDialog extends StatefulWidget {
  const _AddTaskDialog();

  @override
  State<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<_AddTaskDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_controller.text);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New task'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 200,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(hintText: 'What needs doing?'),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: _submit, child: const Text('Add')),
      ],
    );
  }
}