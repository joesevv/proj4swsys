import 'package:cloud_firestore/cloud_firestore.dart';

/// read only view of docs, docs is join code
class Board {
  const Board({
    required this.id,
    required this.name,
    required this.members,
    required this.createdBy,
  });

  final String id;
  final String name;
  final List<String> members;
  final String createdBy;
///join code=docs id
  String get code => id;

  factory Board.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const <String, dynamic>{};
    return Board(
      id: doc.id,
      name: (d['name'] ?? '') as String,
      members: List<String>.from(d['members'] as List? ?? const []),
      createdBy: (d['createdBy'] ?? '') as String,
    );
  }
}
