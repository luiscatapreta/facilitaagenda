import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'agenda_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _signInWithGoogle(BuildContext context) async {
    final googleProvider = GoogleAuthProvider();
    await FirebaseAuth.instance.signInWithPopup(googleProvider);

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AgendaScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.login),
          label: const Text('Entrar com Google'),
          onPressed: () => _signInWithGoogle(context),
        ),
      ),
    );
  }
}