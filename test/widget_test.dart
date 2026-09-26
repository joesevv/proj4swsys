import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a app renders', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text('TaskBoard'))));
    expect(find.text('TaskBoard'), findsOneWidget);
  });
}