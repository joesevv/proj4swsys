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
          seedColor: const Color(0xFFB7A0FF),
          brightness: Brightness.dark,
          surface: const Color(0xFF1D2030),
        ),
        scaffoldBackgroundColor: const Color(0xFF10121C),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF10121C),
          foregroundColor: Color(0xFFF2F5F4),
          centerTitle: false,
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF242839),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF242839),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
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
