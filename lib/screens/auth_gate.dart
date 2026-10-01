import 'package:flutter/material.dart';

import 'login_screen.dart';

typedef AuthStateFactory = Stream<Object?> Function();

class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
    required this.authState,
    required this.onSignIn,
    required this.signedInBuilder,
  });

  final AuthStateFactory authState;
  final Future<void> Function() onSignIn;
  final WidgetBuilder signedInBuilder;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Stream<Object?> _authState;

  @override
  void initState() {
    super.initState();
    _authState = widget.authState();
  }

  void _retry() {
    setState(() => _authState = widget.authState());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object?>(
      stream: _authState,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return _AuthStateError(error: snapshot.error!, onRetry: _retry);
        }
        if (snapshot.data == null) {
          return LoginScreen(onSignIn: widget.onSignIn);
        }
        return widget.signedInBuilder(context);
      },
    );
  }
}

class _AuthStateError extends StatelessWidget {
  const _AuthStateError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Could not check your sign-in status.'),
              const SizedBox(height: 8),
              Text('$error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
