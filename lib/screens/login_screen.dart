import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  bool _loading = false;

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _signIn() async {
    setState(() => _loading = true);
    try {
      await _auth.signInWithGoogle();
    } catch (e) {
      _snack('$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('TaskBoard', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 8),
              const Text('A small shared board: To Do, In Progress, Done.'),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _loading ? null : _signIn,
                icon: const Icon(Icons.login),
                label: Text(_loading ? 'Signing in…' : 'Sign in with Google'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
