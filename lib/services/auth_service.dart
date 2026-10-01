import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

 ///google sign in once per run
  static bool _googleStarted = false;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authState => _auth.authStateChanges();

  ///display name for tasks , fallback is gmail  addr
  String get currentName => currentUser?.displayName ?? currentUser?.email ?? 'Unknown';

  Future<void> _startGoogle() async {
    if (!_googleStarted) {
      await GoogleSignIn.instance.initialize();
      _googleStarted = true;
    }
  }

  ///throws error msg if picker closed
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

  ///sign out of google and firebase so acc picker shows next time
  Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb) {
      await _startGoogle();
      await GoogleSignIn.instance.signOut();
    }
  }
}
