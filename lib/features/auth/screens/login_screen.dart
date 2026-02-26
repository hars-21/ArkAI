import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Login Screen'),
            ElevatedButton(
              onPressed: () => context.go('/browser'),
              child: const Text('Go to Browser'),
            ),
            ElevatedButton(
              onPressed: () => context.go('/analysis'),
              child: const Text('Go to Analysis'),
            ),
          ],
        ),
      ),
    );
  }
}
