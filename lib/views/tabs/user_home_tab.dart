import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'emails_tab.dart'; // Re-using the Email model

class UserHomeTab extends StatefulWidget {
  final String userId;
  const UserHomeTab({super.key, required this.userId});

  @override
  State<UserHomeTab> createState() => _UserHomeTabState();
}

class _UserHomeTabState extends State<UserHomeTab> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    hintText: 'Search your assigned contracts...',
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
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('contracts')
                      .where('assignedTo', isEqualTo: widget.userId)
                      .orderBy('receivedDateTime', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                       return Center(
                         child: Padding(
                           padding: const EdgeInsets.all(16.0),
                           child: Text('Error: ${snapshot.error}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                         ),
                       );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No contracts have been assigned to you yet.'));
                    }

                    final filteredDocs = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final query = _searchQuery.toLowerCase();
                      final subject = data['subject']?.toString().toLowerCase() ?? '';
                      final from = data['from']?.toString().toLowerCase() ?? '';
                      final body = data['bodyPreview']?.toString().toLowerCase() ?? '';
                      return subject.contains(query) || from.contains(query) || body.contains(query);
                    }).toList();

                    if (filteredDocs.isEmpty) {
                      return const Center(child: Text('No contracts match your search.'));
                    }

                    return Container(
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
                        itemCount: filteredDocs.length,
                        separatorBuilder: (context, index) => const Divider(height: 1, indent: 72, endIndent: 16),
                        itemBuilder: (context, index) {
                          final doc = filteredDocs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          // We use the same Email model for consistency
                          final email = Email(
                            id: doc.id,
                            subject: data['subject'] ?? 'No Subject',
                            from: data['from'] ?? 'Unknown Sender',
                            bodyPreview: data['bodyPreview'] ?? '',
                            receivedDateTime: (data['receivedDateTime'] as Timestamp).toDate(),
                          );

                          return InkWell(
                            onTap: () {
                              // TODO: Implement contract detail view
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
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
