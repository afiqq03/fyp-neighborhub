import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rukuntetangga/widgets/constants.dart';

class ViewTimetableScreen extends StatelessWidget {
  const ViewTimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('View Timetable'), backgroundColor: kPrimaryColor),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('timetable').orderBy('date').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No timetable entries.'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              return ListTile(
                leading: const Icon(Icons.event),
                title: Text(data['title'] ?? ''),
                subtitle: Text(data['date']?.toDate().toString() ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}