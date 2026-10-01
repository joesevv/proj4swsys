import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proj4swsys/main.dart';
import 'package:proj4swsys/screens/auth_gate.dart';
import 'package:proj4swsys/services/firebase_emulators.dart';

void main() {
  test('task repository uses the rules-scoped shared board', () {
    expect(TaskRepository.boardId, 'shared');
  });

  testWidgets('shows loading until authentication state is available', (
    tester,
  ) async {
    final auth = StreamController<Object?>();
    addTearDown(auth.close);

    await tester.pumpWidget(_testApp(authState: () => auth.stream));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    auth.add(null);
    await tester.pump();
    expect(find.text('Sign in with Google'), findsOneWidget);
  });

  testWidgets('shows login when the user is signed out', (tester) async {
    await tester.pumpWidget(_testApp(authState: () => Stream.value(null)));

    await tester.pumpAndSettle();
    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(find.text('Test board'), findsNothing);
  });

  testWidgets('shows the board when the user is signed in', (tester) async {
    await tester.pumpWidget(_testApp(authState: () => Stream.value(Object())));

    await tester.pumpAndSettle();
    expect(find.text('Test board'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsNothing);
  });

  testWidgets('shows auth errors and retries the auth stream', (tester) async {
    final firstAuth = StreamController<Object?>();
    final retriedAuth = StreamController<Object?>();
    addTearDown(firstAuth.close);
    addTearDown(retriedAuth.close);
    var attempts = 0;

    await tester.pumpWidget(
      _testApp(
        authState: () {
          attempts++;
          return attempts == 1 ? firstAuth.stream : retriedAuth.stream;
        },
      ),
    );
    firstAuth.addError(StateError('Auth unavailable'));
    await tester.pump();

    expect(find.text('Could not check your sign-in status.'), findsOneWidget);
    expect(find.textContaining('Auth unavailable'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(attempts, 2);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    retriedAuth.add(null);
    await tester.pump();
    expect(find.text('Sign in with Google'), findsOneWidget);
  });

  testWidgets('shows sign-in failures to the user', (tester) async {
    await tester.pumpWidget(
      _testApp(
        authState: () => Stream.value(null),
        onSignIn: () async => throw StateError('Provider unavailable'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign in with Google'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('Provider unavailable'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
  });

  test('uses the correct emulator host for Android and browser clients', () {
    expect(
      firebaseEmulatorHost(isWeb: false, platform: TargetPlatform.android),
      '10.0.2.2',
    );
    expect(
      firebaseEmulatorHost(isWeb: true, platform: TargetPlatform.android),
      'localhost',
    );
    expect(
      firebaseEmulatorHost(isWeb: false, platform: TargetPlatform.windows),
      'localhost',
    );
  });
}

Widget _testApp({
  required AuthStateFactory authState,
  Future<void> Function()? onSignIn,
}) {
  return MaterialApp(
    home: AuthGate(
      authState: authState,
      onSignIn: onSignIn ?? () async {},
      signedInBuilder: (_) => const Scaffold(body: Text('Test board')),
    ),
  );
}
