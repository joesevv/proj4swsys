import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Every write the app makes, firestore will check it based on security rules , if failed permission denied message
class WriteService {
  WriteService({required this.uid, required this.name});

  /// user's id.
  final String uid;

  /// name stamped on tasks this user creates or starts.
  final String name;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _boards =>
      _db.collection('boards');

  CollectionReference<Map<String, dynamic>> _tasks(String boardId) =>
      _boards.doc(boardId).collection('tasks');

  // Letters and digits with no 1/i's and 0/Os
  static const String codeAlphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  static const int codeLength = 6;

  static String newCode() {
    final random = Random.secure();
    return List.generate(
      codeLength,
      (_) => codeAlphabet[random.nextInt(codeAlphabet.length)],
    ).join();
  }

  /// creates a board and returns its join code. code is also docs id
  Future<String> createBoard(String boardName) async {
    try {
      return await _createBoardWithCode(boardName, newCode());
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') throw _message(e);
    }
    try {
      return await _createBoardWithCode(boardName, newCode());
    } on FirebaseException catch (e) {
      throw _message(e);
    }
  }

  Future<String> _createBoardWithCode(String boardName, String code) async {
    await _boards.doc(code).set({
      'name': boardName,
      'code': code,
      'members': [uid],
      'createdBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return code;
  }

  /// join board with code and returns id, edge case of entering existing board code just returns the board
  Future<String> joinBoard(String code) async {
    final ref = _boards.doc(code);

    ///  members can read a board, so a successful read means we are already in.
    try {
      final snap = await ref.get();
      if (snap.exists) return code;
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') throw _message(e);

      /// Not a member yet add ourselves.
    }

    try {
      await ref.update({
        'members': FieldValue.arrayUnion([uid]),
      });
      return code;
    } on FirebaseException catch (e) {
      /// firestore reports missing doc id with following error msg
      if (e.code == 'permission-denied' || e.code == 'not-found') {
        throw 'No board with that code.';
      }
      throw _message(e);
    }
  }

  Future<void> addTask(String boardId, String title) => _write(() async {
    await _tasks(boardId).add({
      'title': title,
      'status': 'todo',
      'createdBy': {'uid': uid, 'name': name},
      'createdAt': FieldValue.serverTimestamp(),
      'startedBy': null,
      'startedAt': null,
      'doneAt': null,
    });
  }, whenDenied: 'You are not a member of this board.');

  /// todo -> inprogress  rules only allow this while the task is still 'todo',
  /// so if two people press Start together, the second one is refused.
  Future<void> startTask(String boardId, String taskId) => _write(
    () => _tasks(boardId).doc(taskId).update({
      'status': 'inprogress',
      'startedBy': {'uid': uid, 'name': name},
      'startedAt': FieldValue.serverTimestamp(),
    }),
    whenDenied: 'Task already started by someone else.',
  );

  /// inprogress -> done. The rules only allow this for the person who started it.
  Future<void> finishTask(String boardId, String taskId) => _write(
    () =>
        _tasks(boardId)
            .doc(taskId)
            .update({'status': 'done', 'doneAt': FieldValue.serverTimestamp()}),
    whenDenied: 'Only the person who started this task can finish it.',
  );

  /// Any current board member can remove a task in any status.
  Future<void> deleteTask(String boardId, String taskId) => _write(
    () => _tasks(boardId).doc(taskId).delete(),
    whenDenied: 'Only board members can delete tasks.',
  );

  Future<void> _write(
    Future<void> Function() action, {
    required String whenDenied,
  }) async {
    try {
      await action();
    } on FirebaseException catch (e) {
      throw e.code == 'permission-denied' ? whenDenied : _message(e);
    }
  }

  String _message(FirebaseException e) => switch (e.code) {
    'permission-denied' => 'You do not have permission to do that.',
    'unavailable' => 'No connection. Check your internet and try again.',
    _ => e.message ?? 'Something went wrong (${e.code}).',
  };
}
