import 'package:flutter/material.dart';
import 'manage_announcement.dart';
import 'resolve_emergency.dart';
import 'view_users.dart';
import 'view_timetable.dart';
import 'package:rukuntetangga/widgets/constants.dart';

class MemberDashboard extends StatelessWidget {
  const MemberDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Dashboard'),
        backgroundColor: kPrimaryColor,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.announcement),
            title: const Text('Manage Announcements'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageAnnouncementScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.warning),
            title: const Text('Resolve Emergencies'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ResolveEmergencyScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('View Users'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ViewUsersScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('View Timetable'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ViewTimetableScreen()),
            ),
          ),
        ],
      ),
    );
  }
}