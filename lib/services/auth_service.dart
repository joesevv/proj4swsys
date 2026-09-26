import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static bool _googleStarted = false;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authState => _auth.authStateChanges();

  Future<void> _startGoogle() async {
    if (!_googleStarted) {
      await GoogleSignIn.instance.initialize();
      _googleStarted = true;
    }
  }

  // Signs in with Google.
  // Throws a short message if something goes wrong.
  Future<void> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        await _auth.signInWithPopup(GoogleAuthProvider());
      } else {
        await _startGoogle();
        final account = await GoogleSignIn.instance.authenticate();
        final idToken = account.authentication.idToken;
        if (idToken == null) {
          throw 'Google did not return an ID token. Check the SHA-1 step (2.1) and rebuild.';
        }
        await _auth.signInWithCredential(GoogleAuthProvider.credential(idToken: idToken));
      }
    } on GoogleSignInException catch (e) {
      if (e.code != GoogleSignInExceptionCode.canceled) {
        throw 'Google sign-in failed (${e.code.name}).';
      }
    } on FirebaseAuthException catch (e) {
      if (e.code != 'popup-closed-by-user') {
        throw e.message ?? 'Sign-in failed.';
      }
    }
  }

  // Signs out of Firebase and Google
  Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb) {
      await _startGoogle();
      await GoogleSignIn.instance.signOut();
    }
  }
}