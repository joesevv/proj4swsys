import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

String firebaseEmulatorHost({
  required bool isWeb,
  required TargetPlatform platform,
}) {
  if (isWeb) return 'localhost';
  if (platform == TargetPlatform.android) return '10.0.2.2';
  return 'localhost';
}

Future<void> connectFirebaseEmulators() async {
  final host = firebaseEmulatorHost(
    isWeb: kIsWeb,
    platform: defaultTargetPlatform,
  );
  await FirebaseAuth.instance.useAuthEmulator(host, 9099);
  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
}
