import 'package:flutter/material.dart';

class LitigationTab extends StatelessWidget {
  const LitigationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Litigation'),
      ),
      body: const Center(
        child: Text('Litigation Tab'),
      ),
    );
  }
}
