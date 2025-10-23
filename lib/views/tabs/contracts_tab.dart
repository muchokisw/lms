import 'package:flutter/material.dart';

class ContractsTab extends StatelessWidget {
  const ContractsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contracts'),
      ),
      body: const Center(
        child: Text('Contracts Tab'),
      ),
    );
  }
}
