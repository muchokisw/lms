
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/theme_notifier.dart';
import '/services/zoom_notifier.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
           IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => ZoomNotifier.increaseZoom(),
            tooltip: 'Zoom In',
          ),
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () => ZoomNotifier.decreaseZoom(),
            tooltip: 'Zoom Out',
          ),
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => ThemeNotifier.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome, Admin!'),
      ),
    );
  }
}
