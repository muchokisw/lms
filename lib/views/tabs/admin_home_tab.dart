import 'package:flutter/material.dart';

class AdminHomeTab extends StatelessWidget {
  final Function(int) onSummaryTap;

  const AdminHomeTab({super.key, required this.onSummaryTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: const Text('Admin Home'),
      ),
      body: const Center(
        child: Text('Admin Home Tab'),
      ),
    );
  }
}
