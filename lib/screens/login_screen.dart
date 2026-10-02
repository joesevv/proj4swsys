import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onSignIn});

  final Future<void> Function() onSignIn;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _signIn() async {
    setState(() => _loading = true);
    try {
      await widget.onSignIn();
    } catch (e) {
      _snack('$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF25213E), Color(0xFF10121C), Color(0xFF142E2D)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB7A0FF).withValues(alpha: .15),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.space_dashboard_rounded,
                      color: Color(0xFFB7A0FF),
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'TaskBoard',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Less chaos. More done.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'A shared space to turn your team’s ideas into progress.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFFAAAFC5), height: 1.6),
                  ),
                  const SizedBox(height: 28),
                  const Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      Chip(
                        avatar: Icon(
                          Icons.radio_button_unchecked,
                          size: 16,
                          color: Color(0xFFB7A0FF),
                        ),
                        label: Text('To Do'),
                      ),
                      Chip(
                        avatar: Icon(
                          Icons.timelapse,
                          size: 16,
                          color: Color(0xFFFFC978),
                        ),
                        label: Text('In Progress'),
                      ),
                      Chip(
                        avatar: Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: Color(0xFF71DEBB),
                        ),
                        label: Text('Done'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: _loading ? null : _signIn,
                    icon: const Icon(Icons.login),
                    label: Text(
                      _loading ? 'Signing in…' : 'Sign in with Google',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
