
import 'dart:developer' as developer; // Import the developer log
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  Future<void> _signInWithMicrosoft(BuildContext context) async {
    if (!context.mounted) return;

    try {
      final microsoftProvider = OAuthProvider('microsoft.com');
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithPopup(microsoftProvider);
      final user = userCredential.user;
      if (user != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-in successful for \${user.displayName}')),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Log the full error for better debugging in the browser console
      developer.log(
        'Firebase Auth Error',
        name: 'com.myapp.auth',
        error: e,
        stackTrace: e.stackTrace,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: \${e.code} - See browser console for details.')),
        );
      }
    } catch (e, s) {
      // Log the full error for better debugging in the browser console
      developer.log(
        'Generic Error',
        name: 'com.myapp.auth',
        error: e,
        stackTrace: s,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An unknown error occurred. See browser console.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2F2F2F),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: () => _signInWithMicrosoft(context),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.login),
              SizedBox(width: 12),
              Text('Sign in with Microsoft'),
            ],
          ),
        ),
      ),
    );
  }
}
