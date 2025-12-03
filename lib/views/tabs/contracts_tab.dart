import 'package:flutter/material.dart';
import './sub_tabs/business_contract_sub_tab.dart';
import './sub_tabs/service_contract_sub_tab.dart';

class ContractsTab extends StatelessWidget {
  const ContractsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            const TabBar(
              labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              tabs: [
                Tab(text: 'Business'),
                Tab(text: 'Service'),
              ],
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  BusinessContractSubTab(),
                  ServiceContractSubTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
