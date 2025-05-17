import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rukuntetangga/widgets/constants.dart';

class ManageAnnouncementScreen extends StatefulWidget {
  const ManageAnnouncementScreen({super.key});

  @override
  State<ManageAnnouncementScreen> createState() => _ManageAnnouncementScreenState();
}

class _ManageAnnouncementScreenState extends State<ManageAnnouncementScreen> {
  final TextEditingController _announcementController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addAnnouncement() async {
    if (_announcementController.text.trim().isEmpty) return;
    await _firestore.collection('announcements').add({
      'text': _announcementController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    _announcementController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Announcement added!'), backgroundColor: kPrimaryColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Announcements'), backgroundColor: kPrimaryColor),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _announcementController,
                    decoration: const InputDecoration(
                      labelText: 'New Announcement',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addAnnouncement,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('announcements').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['text'] ?? ''),
                      subtitle: Text(data['createdAt']?.toDate().toString() ?? ''),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}