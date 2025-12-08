import 'package:flutter/material.dart';
import '../../contracts/add_business_contract.dart';

class BusinessContractSubTab extends StatelessWidget {
  const BusinessContractSubTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('Business Contract Sub-Tab'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddBusinessContractPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
