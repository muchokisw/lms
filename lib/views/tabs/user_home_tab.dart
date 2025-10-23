import 'package:flutter/material.dart';

class UserHomeTab extends StatelessWidget {
  const UserHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Home'),
      ),
      body: const Center(
        child: Text('User Home Tab'),
      ),
    );
  }
}
