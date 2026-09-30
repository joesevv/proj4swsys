import 'package:flutter/material.dart';
///adding firebase imports and connection for services
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    // The Android emulator reaches the host machine at 10.0.2.2; web/desktop use localhost.
    final host = !kIsWeb && defaultTargetPlatform == TargetPlatform.android ? '10.0.2.2' : 'localhost';
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
  }

  runApp(const TaskBoardApp());
}

class TaskBoardApp extends StatelessWidget {
  const TaskBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskBoard',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const BoardScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

/// The columns on the board. The enum name ('todo', 'doing', 'done') is what
/// gets stored in Firestore, and the label is what's shown on screen.
enum TaskStatus {
  todo('To do'),
  doing('In progress'),
  done('Done');

  const TaskStatus(this.label);
  final String label;

  static TaskStatus fromName(String? name) => TaskStatus.values.firstWhere(
        (s) => s.name == name,
    orElse: () => TaskStatus.todo,
  );
}

class TaskItem {
  const TaskItem({required this.id, required this.title, required this.status});

  final String id;
  final String title;
  final TaskStatus status;

  factory TaskItem.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return TaskItem(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      status: TaskStatus.fromName(data['status'] as String?),
    );
  }
}

// ---------------------------------------------------------------------------
// Firestore access
// ---------------------------------------------------------------------------

/// All reads and writes for tasks go through here, stored in a top-level
/// Firestore collection called 'tasks'.
class TaskRepository {
  final CollectionReference<Map<String, dynamic>> _tasks =
  FirebaseFirestore.instance.collection('tasks');

  Stream<List<TaskItem>> watchTasks() {
    return _tasks
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs.map(TaskItem.fromDoc).toList());
  }

  Future<void> addTask(String title) {
    return _tasks.add({
      'title': title,
      'status': TaskStatus.todo.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> moveTask(String id, TaskStatus status) {
    return _tasks.doc(id).update({'status': status.name});
  }

  Future<void> deleteTask(String id) {
    return _tasks.doc(id).delete();
  }
}

// ---------------------------------------------------------------------------
// Board screen
// ---------------------------------------------------------------------------

class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  final TaskRepository _repo = TaskRepository();
  late final Stream<List<TaskItem>> _tasksStream = _repo.watchTasks();

  /// Runs a Firestore write and shows a message if it fails
  /// (for example, if security rules reject it).
  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong: $e')),
      );
    }
  }

  Future<void> _addTask() async {
    final title = await showDialog<String>(
      context: context,
      builder: (_) => const _AddTaskDialog(),
    );
    if (title == null || title.trim().isEmpty) return;
    await _run(() => _repo.addTask(title.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TaskBoard')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTask,
        icon: const Icon(Icons.add),
        label: const Text('Add task'),
      ),
      body: StreamBuilder<List<TaskItem>>(
        stream: _tasksStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Couldn\'t load tasks: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = snapshot.data!;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final status in TaskStatus.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _BoardColumn(
                      status: status,
                      tasks: tasks.where((t) => t.status == status).toList(),
                      onMove: (task, newStatus) =>
                          _run(() => _repo.moveTask(task.id, newStatus)),
                      onDelete: (task) => _run(() => _repo.deleteTask(task.id)),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// One column of the board. Accepts dropped tasks from other columns.
// ---------------------------------------------------------------------------

class _BoardColumn extends StatelessWidget {
  const _BoardColumn({
    required this.status,
    required this.tasks,
    required this.onMove,
    required this.onDelete,
  });

  final TaskStatus status;
  final List<TaskItem> tasks;
  final void Function(TaskItem task, TaskStatus newStatus) onMove;
  final void Function(TaskItem task) onDelete;

  static const double width = 280;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DragTarget<TaskItem>(
      onWillAcceptWithDetails: (details) => details.data.status != status,
      onAcceptWithDetails: (details) => onMove(details.data, status),
      builder: (context, candidates, rejected) {
        final isHovered = candidates.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: width,
          decoration: BoxDecoration(
            color: isHovered ? colors.primaryContainer : colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Text(status.label, style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    Text('${tasks.length}', style: Theme.of(context).textTheme.labelLarge),
                  ],
                ),
              ),
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                  child: Text(
                    'Drag tasks here',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                )
                    : ListView.builder(
                  // Extra bottom padding so the "Add task" button
                  // doesn't cover the last card.
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 88),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return _TaskCard(
                      task: task,
                      onMove: (newStatus) => onMove(task, newStatus),
                      onDelete: () => onDelete(task),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// A single task card. Long-press to drag it, or use the ⋮ menu to move/delete.
// ---------------------------------------------------------------------------

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, required this.onMove, required this.onDelete});

  final TaskItem task;
  final void Function(TaskStatus newStatus) onMove;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(task.title),
        trailing: PopupMenuButton<VoidCallback>(
          tooltip: 'Task options',
          onSelected: (action) => action(),
          itemBuilder: (context) => [
            for (final status in TaskStatus.values)
              if (status != task.status)
                PopupMenuItem(
                  value: () => onMove(status),
                  child: Text('Move to ${status.label}'),
                ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: onDelete,
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );

    return LongPressDraggable<TaskItem>(
      data: task,
      // What follows your finger while dragging.
      feedback: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: _BoardColumn.width - 16,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(task.title),
          ),
        ),
      ),
      // What stays behind in the column while dragging.
      childWhenDragging: Opacity(opacity: 0.3, child: card),
      child: card,
    );
  }
}

// ---------------------------------------------------------------------------
// Dialog for entering a new task title.
// ---------------------------------------------------------------------------

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
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(hintText: 'What needs doing?'),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Add')),
      ],
    );
  }
}