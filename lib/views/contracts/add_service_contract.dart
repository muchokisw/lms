import 'package:flutter/material.dart';
import '../../services/theme_notifier.dart';

class AddServiceContractPage extends StatelessWidget {
  const AddServiceContractPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeNotifier.themeMode,
            builder: (context, mode, _) => IconButton(
              icon: Icon(
                mode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode,
              ),
              onPressed: () {
                ThemeNotifier.toggleTheme();
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Contract Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Parties',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Commencement Date',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Expiry Date',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Contract Price',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}