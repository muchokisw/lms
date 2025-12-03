import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// A simple model for an email
class Email {
  final String id;
  final String subject;
  final String from;
  final String bodyPreview;
  final DateTime receivedDateTime;

  Email({
    required this.id,
    required this.subject,
    required this.from,
    required this.bodyPreview,
    required this.receivedDateTime,
  });

  factory Email.fromJson(Map<String, dynamic> json) {
    return Email(
      id: json['id'] ?? '',
      subject: json['subject'] ?? 'No Subject',
      from: json['from']?['emailAddress']?['address'] ?? 'Unknown Sender',
      bodyPreview: json['bodyPreview'] ?? '',
      receivedDateTime: DateTime.parse(json['receivedDateTime'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class EmailsTab extends StatefulWidget {
  const EmailsTab({super.key});

  @override
  State<EmailsTab> createState() => _EmailsTabState();
}

class _EmailsTabState extends State<EmailsTab> {
  List<Email> _emails = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchEmails();
  }

  Future<Map<String, String?>> _getAdminTokens() async {
    final adminUser = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Admin')
        .limit(1)
        .get();

    if (adminUser.docs.isEmpty) {
      throw Exception('Admin user with Outlook tokens not found.');
    }

    final adminData = adminUser.docs.first.data();
    return {
      'accessToken': adminData['outlook_access_token'],
      'refreshToken': adminData['outlook_refresh_token'],
    };
  }

  Future<void> _fetchEmails() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final tokens = await _getAdminTokens();
      final accessToken = tokens['accessToken'];

      if (accessToken == null) {
        throw Exception('Access token not available. Please connect to Outlook in settings.');
      }

      final response = await http.get(
        Uri.parse('https://graph.microsoft.com/v1.0/me/mailfolders/inbox/messages?\$top=50&select=id,subject,from,bodyPreview,receivedDateTime'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> messages = data['value'];
        if (!mounted) return;
        setState(() {
          _emails = messages.map((json) => Email.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load emails: ${response.body}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredEmails = _emails.where((email) {
      final query = _searchQuery.toLowerCase();
      return email.subject.toLowerCase().contains(query) ||
          email.from.toLowerCase().contains(query) ||
          email.bodyPreview.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'refresh_emails',
        onPressed: _fetchEmails,
        tooltip: 'Refresh Emails',
        child: const Icon(Icons.refresh),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search incoming emails...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.light
                        ? Colors.grey[200]
                        : Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text('Error: $_error', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                            ),
                          )
                        : Container(
                            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.light
                                  ? Colors.white
                                  : Colors.grey[850],
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                )
                              ]
                            ),
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: filteredEmails.length,
                              separatorBuilder: (context, index) => const Divider(height: 1, indent: 72, endIndent: 16),
                              itemBuilder: (context, index) {
                                final email = filteredEmails[index];
                                return InkWell(
                                  onTap: () {
                                    // TODO: Implement assignment logic
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Tapped on ${email.subject}')),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          child: Text(
                                            email.from.isNotEmpty ? email.from[0].toUpperCase() : '?',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                email.from,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                email.subject,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                DateFormat.yMMMd().add_jm().format(email.receivedDateTime),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
