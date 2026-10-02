import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/theme_toggle_button.dart';

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
    final colors = context.appColors;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors.loginGradient,
          ),
        ),
        /// toggle sits in the top-right corner above the centered content
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colors.brand.withValues(alpha: .15),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(
                            Icons.space_dashboard_rounded,
                            color: colors.brand,
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
                        Text(
                          'A shared space to turn your team’s ideas into progress.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colors.muted, height: 1.6),
                        ),
                        const SizedBox(height: 28),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: [
                            Chip(
                              avatar: Icon(
                                Icons.radio_button_unchecked,
                                size: 16,
                                color: colors.todo,
                              ),
                              label: const Text('To Do'),
                            ),
                            Chip(
                              avatar: Icon(
                                Icons.timelapse,
                                size: 16,
                                color: colors.inProgress,
                              ),
                              label: const Text('In Progress'),
                            ),
                            Chip(
                              avatar: Icon(
                                Icons.check_circle_outline,
                                size: 16,
                                color: colors.done,
                              ),
                              label: const Text('Done'),
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
              const Positioned(
                top: 8,
                right: 8,
                child: ThemeToggleButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}