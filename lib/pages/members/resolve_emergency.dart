import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rukuntetangga/widgets/constants.dart';

class ResolveEmergencyScreen extends StatelessWidget {
  const ResolveEmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _firestore = FirebaseFirestore.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Resolve Emergencies'), backgroundColor: kPrimaryColor),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('emergencies').where('resolved', isEqualTo: false).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No emergencies.'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['description'] ?? ''),
                subtitle: Text(data['createdAt']?.toDate().toString() ?? ''),
                trailing: ElevatedButton(
                  onPressed: () async {
                    await _firestore.collection('emergencies').doc(docs[i].id).update({'resolved': true});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Emergency resolved!'), backgroundColor: kPrimaryColor),
                    );
                  },
                  child: const Text('Resolve'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}