import 'dart:convert';
import 'dart:html' as html;
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../../auth/add_user.dart';

class AdminHomeTab extends StatefulWidget {
  final Function(int) onSummaryTap;

  const AdminHomeTab({super.key, required this.onSummaryTap});

  @override
  State<AdminHomeTab> createState() => _AdminHomeTabState();
}

class _AdminHomeTabState extends State<AdminHomeTab> {
  bool _isConnecting = false;
  String? _statusMessage;

  String _generateCodeVerifier() {
    final random = Random.secure();
    final values = List<int>.generate(64, (i) => random.nextInt(256));
    return base64UrlEncode(values).replaceAll('=', '');
  }

  String _codeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }

  Future<void> _connectOutlookAccount() async {
    setState(() {
      _isConnecting = true;
      _statusMessage = 'Opening Microsoft login...';
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isConnecting = false;
        _statusMessage = 'Please sign in first.';
      });
      return;
    }

    const clientId = '6d1f1428-3acf-4ce6-a01a-e2cd492741d6';
    const tenantId = 'common';
    const redirectUri = 'https://lms-09090182-ca4a6.web.app/auth.html';
    const scopes = 'openid profile email offline_access Mail.Read';

    final codeVerifier = _generateCodeVerifier();
    final codeChallenge = _codeChallenge(codeVerifier);
    final state = base64UrlEncode(utf8.encode(DateTime.now().toIso8601String()));

    final authUrl = Uri.https(
      'login.microsoftonline.com',
      '/$tenantId/oauth2/v2.0/authorize',
      {
        'client_id': clientId,
        'response_type': 'code',
        'redirect_uri': redirectUri,
        'response_mode': 'query',
        'scope': scopes,
        'prompt': 'select_account',
        'code_challenge_method': 'S256',
        'code_challenge': codeChallenge,
        'state': state,
      },
    ).toString();

    final popup = html.window.open(authUrl, "Microsoft Login", "width=600,height=800");

    html.window.onMessage.firstWhere((event) {
      return event.data.toString().contains('code=');
    }).then((event) async {
      popup.close();

      final redirectedUrl = Uri.parse(event.data.toString());
      final receivedCode = redirectedUrl.queryParameters['code'];
      final receivedState = redirectedUrl.queryParameters['state'];

      if (receivedState != state) {
        setState(() {
           _isConnecting = false;
          _statusMessage = 'Error: Invalid state returned. CSRF attack?' ;
        });
        return;
      }

      if (receivedCode == null) {
        setState(() {
          _isConnecting = false;
          _statusMessage = 'Authorization failed — no code returned.';
        });
        return;
      }
      
      setState(() { _statusMessage = 'Exchanging code for token...'; });

      try {
        final tokenResponse = await http.post(
          Uri.parse('https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token'),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            'client_id': clientId,
            'scope': scopes,
            'code': receivedCode,
            'redirect_uri': redirectUri,
            'grant_type': 'authorization_code',
            'code_verifier': codeVerifier,
          },
        );

        if (tokenResponse.statusCode != 200) {
           throw Exception('Token exchange failed: ${tokenResponse.body}');
        }

        final tokens = json.decode(tokenResponse.body);
        final accessToken = tokens['access_token'];
        final refreshToken = tokens['refresh_token'];
        final expiry = DateTime.now().millisecondsSinceEpoch +
            ((tokens['expires_in'] as int) - 60) * 1000;

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'outlook_access_token': accessToken,
          'outlook_refresh_token': refreshToken,
          'outlook_token_expiry': expiry,
        }, SetOptions(merge: true));

        setState(() {
          _isConnecting = false;
          _statusMessage = 'Microsoft connected successfully!';
        });

      } catch(e) {
         setState(() {
          _isConnecting = false;
          _statusMessage = 'An error occurred: $e';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const AddUserScreen()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: const Text('Add User'),
                    ),
                    const SizedBox(width: 20),
                    OutlinedButton(
                      onPressed: _isConnecting ? null : _connectOutlookAccount,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: const Text('Connect to Outlook'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_isConnecting)
                  const CircularProgressIndicator(),
                if (_statusMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      _statusMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _statusMessage!.startsWith('Error') || _statusMessage!.startsWith('An error') ? Colors.red : Colors.green,
                        fontSize: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
