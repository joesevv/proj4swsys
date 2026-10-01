import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/board.dart';
import '../models/task.dart';

/// Firestore read only. Each method is a live stream (or a one-time read)
/// mapped to model objects. all writes live in WriteService.
class BoardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _boards => _db.collection('boards');

  /// security rules allow this because users uid in members is apart of board
  Stream<List<Board>> myBoards(String uid) => _boards
      .where('members', arrayContains: uid)
      .snapshots()
      .map((snap) => snap.docs.map(Board.fromDoc).toList());

  /// one time read of a single board, used right after joining one.
  Future<Board> board(String boardId) async => Board.fromDoc(await _boards.doc(boardId).get());

  /// tasks on board, oldest first ,
  Stream<List<Task>> tasks(String boardId) => _boards
      .doc(boardId)
      .collection('tasks')
      .orderBy('createdAt')
      .snapshots()
      .map((snap) => snap.docs.map(Task.fromDoc).toList());
}
