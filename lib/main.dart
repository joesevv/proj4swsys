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
    home: const Scaffold(body: Center(child: Text('TaskBoard'))),
  );
}
}

