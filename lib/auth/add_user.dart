import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/theme_notifier.dart';
import '../services/zoom_notifier.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'Client';
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      // Create user with email and password
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      final user = userCredential.user;
      if (user != null) {
        // Save user data to Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'userId': user.uid,
          'firstName': _firstNameController.text.trim(),
          'secondName': _lastNameController.text
              .trim(), // Corrected from 'lastName' to 'secondName'
          'email': _emailController.text.trim(),
          'role': _selectedRole,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User registered successfully!')),
        );
        Navigator.of(
          context,
        ).pop(); // Go back to the previous screen after success
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.message ?? 'An error occurred during registration.',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New User'),
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
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Create a New Account',
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    controller: _firstNameController,
                    labelText: 'First Name',
                    focusNode: _firstNameFocusNode,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_lastNameFocusNode);
                    },
                    validator: (value) => (value ?? '').isEmpty
                        ? 'Please enter a first name.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _lastNameController,
                    labelText: 'Second Name',
                    focusNode: _lastNameFocusNode,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_emailFocusNode);
                    },
                    validator: (value) => (value ?? '').isEmpty
                        ? 'Please enter a second name.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    labelText: 'Email Address',
                    keyboardType: TextInputType.emailAddress,
                    focusNode: _emailFocusNode,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_passwordFocusNode);
                    },
                    validator: (value) => !(value ?? '').contains('@')
                        ? 'Please enter a valid email.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordField(),
                  const SizedBox(height: 16),
                  _buildRoleDropdown(),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 22),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Register User',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    FocusNode? focusNode,
    void Function(String)? onFieldSubmitted,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.0),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.0),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.0),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.white : Colors.black,
            width: 2.0,
          ),
        ),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildPasswordField() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      onFieldSubmitted: (_) => _submit(),
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.0),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.0),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.0),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.white : Colors.black,
            width: 2.0,
          ),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () {
            setState(() => _isPasswordVisible = !_isPasswordVisible);
          },
        ),
      ),
      obscureText: !_isPasswordVisible,
      validator: (value) => (value ?? '').length < 6
          ? 'Password must be at least 6 characters.'
          : null,
    );
  }

  Widget _buildRoleDropdown() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final dropdownColor = isDarkMode ? Colors.grey[800] : Colors.white;

    return DropdownButtonFormField<String>(
      value: _selectedRole,
      dropdownColor: dropdownColor,
      decoration: InputDecoration(
        labelText: 'Role',
        labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.0),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.0),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.0),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.white : Colors.black,
            width: 2.0,
          ),
        ),
      ),
      items: ['Legal Officer', 'Client', 'Administrator']
          .map((role) => DropdownMenuItem(value: role, child: Text(role)))
          .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedRole = value;
          });
        }
      },
      validator: (value) => value == null ? 'Please select a role.' : null,
    );
  }
}
