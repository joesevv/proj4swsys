import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/auth_gate.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'services/firebase_emulators.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  /// app talks to the real Firebase project
  if (const bool.fromEnvironment('USE_FIREBASE_EMULATORS')) {
    await connectFirebaseEmulators();
  }

  runApp(TaskBoardApp(authService: AuthService()));
}

class TaskBoardApp extends StatelessWidget {
  const TaskBoardApp({super.key, required this.authService});

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskBoard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF55D6AE),
          brightness: Brightness.dark,
          surface: const Color(0xFF202428),
        ),
        scaffoldBackgroundColor: const Color(0xFF171A1D),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF171A1D),
          foregroundColor: Color(0xFFF2F5F4),
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF2B3035),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      /// routing is login whenn signed out, home when signed in , boards use navigator
      home: AuthGate(
        authState: () => authService.authState,
        onSignIn: authService.signInWithGoogle,
        signedInBuilder: (_) => HomeScreen(auth: authService),
      ),
    );
  }
}
