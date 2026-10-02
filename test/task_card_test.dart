import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proj4swsys/models/task.dart';
import 'package:proj4swsys/services/write_service.dart';
import 'package:proj4swsys/widgets/task_card.dart';

class _Writer implements WriteService {
  final List<String> deleted = [];
  bool fail = false;
  @override
  String get uid => 'member';
  @override
  Future<void> deleteTask(String boardId, String taskId) async {
    if (fail) throw 'Only board members can delete tasks.';
    deleted.add('$boardId/$taskId');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(_Writer writer, TaskStatus status) => MaterialApp(
  home: Scaffold(
    body: TaskCard(
      task: Task(
        id: 'task',
        boardId: 'board',
        title: 'Write report',
        status: status,
        createdByName: 'Alex',
      ),
      writer: writer,
    ),
  ),
);

void main() {
  testWidgets('cancel or dismiss leaves the task intact', (tester) async {
    final writer = _Writer();
    await tester.pumpWidget(_app(writer, TaskStatus.todo));
    await tester.tap(find.byTooltip('Delete task'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Write report', findRichText: true),
      findsNWidgets(2),
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(writer.deleted, isEmpty);
    await tester.tap(find.byTooltip('Delete task'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(writer.deleted, isEmpty);
  });

  for (final status in TaskStatus.values) {
    testWidgets('confirmed deletion targets the task in ${status.name}', (
      tester,
    ) async {
      final writer = _Writer();
      await tester.pumpWidget(_app(writer, status));
      await tester.tap(find.byTooltip('Delete task'));
      await tester.pumpAndSettle();
      expect(writer.deleted, isEmpty);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(writer.deleted, ['board/task']);
    });
  }

  testWidgets('failed deletion displays an error', (tester) async {
    final writer = _Writer()..fail = true;
    await tester.pumpWidget(_app(writer, TaskStatus.todo));
    await tester.tap(find.byTooltip('Delete task'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Only board members can delete tasks.'), findsOneWidget);
    expect(writer.deleted, isEmpty);
    expect(find.text('Write report'), findsOneWidget);
  });
}
