import 'package:flutter/material.dart';
import 'package:rukuntetangga/widgets/constants.dart';
import 'package:rukuntetangga/pages/admin/home.dart';
import 'package:rukuntetangga/pages/admin/manage_announcement.dart';
import 'package:rukuntetangga/pages/admin/manage_user.dart';
import 'package:rukuntetangga/pages/admin/settings.dart';
import 'package:rukuntetangga/pages/admin/emergency.dart';
import 'package:rukuntetangga/pages/admin/timetable.dart';
import 'package:rukuntetangga/widgets/gradient_app_bar.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AdminHomeScreen(),
    const ManageAnnouncementsScreen(),
    const ManageUsersScreen(),
    const EmergencyScreen(),
    const AdminTimetablePage(),
    const AdminSettingsScreen(),
  ];

  void _onNavigate(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: 'Admin Dashboard',
        centerTitle: true,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavigate,
        selectedItemColor: kPrimaryColor,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign), label: 'Announcements'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'Emergency'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Timetable'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}