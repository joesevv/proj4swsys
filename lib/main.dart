import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/auth_gate.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'services/firebase_emulators.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  /// app talks to the real Firebase project
  if (const bool.fromEnvironment('USE_FIREBASE_EMULATORS')) {
    await connectFirebaseEmulators();
  }

  runApp(TaskBoardApp(authService: AuthService()));
}

/// stateful so it can own the light/dark setting for the whole app
class TaskBoardApp extends StatefulWidget {
  const TaskBoardApp({super.key, required this.authService});

  final AuthService authService;

  @override
  State<TaskBoardApp> createState() => _TaskBoardAppState();
}

class _TaskBoardAppState extends State<TaskBoardApp> {
  /// starts dark (the app's original look). ThemeToggleButton changes it.
  final ValueNotifier<ThemeMode> _themeMode = ValueNotifier(ThemeMode.dark);

  @override
  void dispose() {
    _themeMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = widget.authService;

    return ThemeModeScope(
      notifier: _themeMode,
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: _themeMode,
        builder: (context, mode, _) => MaterialApp(
          title: 'TaskBoard',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,

          /// routing is login whenn signed out, home when signed in , boards use navigator
          home: AuthGate(
            authState: () => authService.authState,
            onSignIn: authService.signInWithGoogle,
            signedInBuilder: (_) => HomeScreen(auth: authService),
          ),
        ),
      ),
    );
  }
}