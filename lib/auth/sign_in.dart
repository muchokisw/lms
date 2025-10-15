import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/theme_notifier.dart';
import '/services/zoom_notifier.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _secondNameController = TextEditingController();
  String _selectedRole = 'Legal Officer'; // Default role
  bool _isLogin = true;
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
              'userId': userCredential.user!.uid,
              'firstName': _firstNameController.text.trim(),
              'secondName': _secondNameController.text.trim(),
              'email': _emailController.text.trim(),
              'createdAt': Timestamp.now(),
              'updatedAt': Timestamp.now(),
              'role': _selectedRole,
            });
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'An error occurred.'),
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
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _secondNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
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
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _isLogin ? 'Welcome' : 'Create your Account',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      if (!_isLogin) ...[
                        _buildTextField(
                          controller: _firstNameController,
                          labelText: 'First Name',
                          validator: (value) => value!.trim().isEmpty
                              ? 'Please enter your first name.'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _secondNameController,
                          labelText: 'Second Name',
                          validator: (value) => value!.trim().isEmpty
                              ? 'Please enter your second name.'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        // Role Dropdown remains standard
                        DropdownButtonFormField<String>(
                          value: _selectedRole,
                          decoration: const InputDecoration(
                            labelText: 'Role',
                            border: OutlineInputBorder(),
                          ),
                          items: ['Administrator', 'Legal Officer']
                              .map(
                                (role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(role),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedRole = value);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                      _buildTextField(
                        controller: _emailController,
                        labelText: 'Email Address',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => !value!.contains('@')
                            ? 'Please enter a valid email.'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(),
                      const SizedBox(height: 16),
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 22),
                          ),
                          child: Text(
                            _isLogin ? 'Sign In' : 'Create Account',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      // TextButton(
                      //   onPressed: () => setState(() => _isLogin = !_isLogin),
                      //   child: Text(
                      //     _isLogin
                      //         ? 'Don\'t have an account? Sign up'
                      //         : 'Already have an account? Sign in',
                      //   ),
                      // ),
                    ],
                  ),
                ),
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
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black : Colors.grey[200],
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  Widget _buildPasswordField() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black : Colors.grey[200],
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              obscureText: !_isPasswordVisible,
              validator: (value) => value!.length < 6
                  ? 'Password must be at least 6 characters.'
                  : null,
            ),
          ),
          IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: isDarkMode ? Colors.grey[600] : Colors.grey,
            ),
            onPressed: () {
              setState(() => _isPasswordVisible = !_isPasswordVisible);
            },
          ),
        ],
      ),
    );
  }
}
