import 'package:flutter/material.dart';
import '../../contracts/add_service_contract.dart';

class ServiceContractSubTab extends StatelessWidget {
  const ServiceContractSubTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('Service Contract Sub-Tab'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddServiceContractPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
