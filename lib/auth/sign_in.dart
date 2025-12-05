import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import '../services/theme_notifier.dart';
import '../services/zoom_notifier.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key}); 

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  final String clientId = '6d1f1428-3acf-4ce6-a01a-e2cd492741d6';
  final String tenantId = 'common';

  Future<void> _handleSignIn(UserCredential userCredential) async {
    final user = userCredential.user;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final docSnapshot = await userRef.get(const GetOptions(source: Source.server));

    if (!docSnapshot.exists) {
      final displayName = user.displayName ?? '';
      final nameParts = displayName.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final secondName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      try {
        await userRef.set({
          'userId': user.uid,
          'firstName': firstName,
          'secondName': secondName,
          'email': user.email,
          'role': 'Client',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('Error creating user document: $e');
      }
    }
  }

  Future<void> _signInWithMicrosoft() async {
    setState(() => _isLoading = true);

    try {
      UserCredential userCredential;
      if (kIsWeb) {
        final provider = OAuthProvider("microsoft.com");
        provider.setCustomParameters({'tenant': tenantId});
        userCredential = await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        final String redirectUri = 'jubileeinsurancelms://auth';
        final url =
            'https://login.microsoftonline.com/$tenantId/oauth2/v2.0/authorize'
            '?client_id=$clientId'
            '&response_type=code'
            '&redirect_uri=${Uri.encodeComponent(redirectUri)}'
            '&response_mode=query'
            '&scope=openid%20email%20profile%20offline_access%20User.Read';

        final result = await FlutterWebAuth.authenticate(url: url, callbackUrlScheme: "jubileeinsurancelms");
        final code = Uri.parse(result).queryParameters['code'];

        if (code == null) {
          throw Exception('Authorization code not found in response.');
        }

        final response = await http.post(
          Uri.parse('https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token'),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            'client_id': clientId,
            'grant_type': 'authorization_code',
            'scope': 'openid email profile offline_access User.Read',
            'code': code,
            'redirect_uri': redirectUri,
          },
        );

        final body = json.decode(response.body);
        final String? accessToken = body['access_token'];
        final String? idToken = body['id_token'];

        if (accessToken == null || idToken == null) {
          throw Exception('Access token or ID token is null');
        }

        final credential = OAuthProvider("microsoft.com").credential(
          idToken: idToken,
          accessToken: accessToken,
        );

        userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      }

      await _handleSignIn(userCredential);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthWrapper()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing in: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthWrapper()),
        );
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
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
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
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Welcome',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
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
                  const SizedBox(height: 24),
                  
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 22),
                       shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Sign In',
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
        labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black,
        
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.0),
          borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.0),
          borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.0),
          borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black, width: 2.0),
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
          borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.0),
          borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.0),
          borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black, width: 2.0),
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
      validator: (value) =>
          (value ?? '').length < 4 ? 'Password must be at least 4 characters.' : null,
    );
  }
}
