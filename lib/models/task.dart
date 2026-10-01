import 'package:cloud_firestore/cloud_firestore.dart';

///three columns. to do, in progress, done is whats stored in firestore, screen shows label

enum TaskStatus {
  todo('To Do'),
  inprogress('In Progress'),
  done('Done');

  const TaskStatus(this.label);
  final String label;

  static TaskStatus fromString(String? value) =>
      TaskStatus.values.firstWhere((s) => s.name == value, orElse: () => TaskStatus.todo);
}

/// read only in boards/{boardId}/tasks/{taskId}.
class Task {
  const Task({
    required this.id,
    required this.boardId,
    required this.title,
    required this.status,
    required this.createdByName,
    this.startedByUid,
    this.startedByName,
  });

  final String id;
  final String boardId;
  final String title;
  final TaskStatus status;
  final String createdByName;
  final String? startedByUid;
  final String? startedByName;

  factory Task.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const <String, dynamic>{};
    final createdBy = d['createdBy'] as Map?;
    final startedBy = d['startedBy'] as Map?;
    return Task(
      id: doc.id,
      ///path is boards/{boardId}/tasks/{taskId}
      boardId: doc.reference.parent.parent?.id ?? '',
      title: (d['title'] ?? '') as String,
      status: TaskStatus.fromString(d['status'] as String?),
      createdByName: (createdBy?['name'] ?? '') as String,
      startedByUid: startedBy?['uid'] as String?,
      startedByName: startedBy?['name'] as String?,
    );
  }
}
