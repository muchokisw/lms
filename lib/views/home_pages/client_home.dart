import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/theme_notifier.dart';
import '../../services/zoom_notifier.dart';
import '../tabs/client/client_home_tab.dart';
import '../tabs/client/client_contracts_tab.dart';
import '../tabs/client/client_demands_tab.dart';
import '../tabs/client/client_intellectual_property_tab.dart';
import '../tabs/client/client_leases_tab.dart';
import '../tabs/client/client_litigation_tab.dart';
import '../tabs/settings_tab.dart'; 

// Avatar context menu content widget
class _AvatarMenuContent extends StatelessWidget {
  final String fullName;
  final String email;
  final String role;

  const _AvatarMenuContent({
    required this.fullName,
    required this.email,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final foregroundColor = isDarkMode ? Colors.black : Colors.black;
    final buttonBackgroundColor = isDarkMode ? Colors.black : Colors.black;
    final buttonForegroundColor = isDarkMode ? Colors.white : Colors.white;
    final initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';

    return Container(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 320),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            child: Text(
              initial,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            fullName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: foregroundColor,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(color: foregroundColor),
          ),
          const SizedBox(height: 4),
          Text(
            role,
            style: TextStyle(color: foregroundColor),
          ),
          const SizedBox(height: 16), // Increased spacing
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonBackgroundColor,
              foregroundColor: buttonForegroundColor,
              minimumSize: const Size(double.infinity, 48), // Make button wider
            ),
            child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pop(); // Close the menu
              Navigator.of(context).pushNamedAndRemoveUntil('/sign_in', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}

class ClientDashboardPage extends StatefulWidget {
  const ClientDashboardPage({super.key});

  @override
  State<ClientDashboardPage> createState() => _ClientDashboardPageState();
}

class _ClientDashboardPageState extends State<ClientDashboardPage> {
  String? _firstNameInitial;
  String? _fullName;
  String? _email;
  String? _role;
  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    const ClientHomeTab(),
    const ClientContractsTab(),
    const ClientDemandsTab(),
    const ClientIntellectualPropertyTab(),
    const ClientLeasesTab(),
    const ClientLitigationTab(),
    const SettingsTab(), // Assuming settings is a shared tab
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          final firstName = data['firstName'] as String? ?? '';
          final lastName = data['lastName'] as String? ?? '';
          setState(() {
            _firstNameInitial = (firstName.isNotEmpty) ? firstName[0].toUpperCase() : '';
            _fullName = '$firstName $lastName'.trim();
            _email = user.email;
            _role = data['role'] as String? ?? 'Client';
          });
        }
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: screenWidth >= 800,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => ZoomNotifier.increaseZoom(),
          ),
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () => ZoomNotifier.decreaseZoom(),
          ),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeNotifier.themeMode,
            builder: (context, mode, _) => IconButton(
              icon: Icon(mode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode),
              onPressed: () => ThemeNotifier.toggleTheme(),
            ),
          ),
          if (_firstNameInitial != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: _AvatarMenu(
                initial: _firstNameInitial!,
                fullName: _fullName,
                email: _email,
                role: _role,
              ),
            ),
        ],
      ),
      body: Row(
        children: [
          _SideNavigationMenu(
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _tabs,
            ),
          ),
        ],
      ),
    );
  }
}

class _SideNavigationMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const _SideNavigationMenu({
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 80,
      color: isDarkMode ? Colors.grey[900] : Colors.white,
      child: Column(
        children: [
          _buildNavItem(context, Icons.home, 'Home', 0),
          _buildNavItem(context, Icons.draw, 'Contracts', 1),
          _buildNavItem(context, Icons.front_hand, 'Demands', 2),
          _buildNavItem(context, Icons.lightbulb, 'Intellectual Property', 3),
          _buildNavItem(context, Icons.apartment, 'Leases', 4),
          _buildNavItem(context, Icons.gavel, 'Litigation', 5),
          _buildNavItem(context, Icons.settings, 'Settings', 6),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String title, int index) {
    final isSelected = selectedIndex == index;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Tooltip(
      message: title,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
      //preferBelow: false,
      child: InkWell(
        onTap: () => onItemTapped(index),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? (isDarkMode ? Colors.grey : Colors.black) : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            icon,
            color: isSelected ? (isDarkMode ? Colors.black : Colors.white) : (isDarkMode ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }
}

class _AvatarMenu extends StatefulWidget {
  final String initial;
  final String? fullName;
  final String? email;
  final String? role;
  const _AvatarMenu({required this.initial, this.fullName, this.email, this.role});

  @override
  State<_AvatarMenu> createState() => _AvatarMenuState();
}

class _AvatarMenuState extends State<_AvatarMenu> {
  final GlobalKey _avatarKey = GlobalKey();

  void _showMenu() async {
    final RenderBox renderBox = _avatarKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    await showMenu(
      context: context,
      color: isDarkMode ? Colors.grey : Colors.grey[200],
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        offset.dx + size.width,
        offset.dy,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      items: [
        PopupMenuItem(
          enabled: false,
          padding: EdgeInsets.zero,
          child: _AvatarMenuContent(
            fullName: widget.fullName ?? '',
            email: widget.email ?? '',
            role: widget.role ?? '',
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _avatarKey,
      onTap: _showMenu,
      child: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
        child: Text(
          widget.initial,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
