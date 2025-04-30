import 'package:flutter/material.dart';
import 'package:rukuntetangga/widgets/constants.dart';
import 'package:rukuntetangga/pages/admin/home.dart';
import 'package:rukuntetangga/pages/admin/manage_announcement.dart';
import 'package:rukuntetangga/pages/admin/manage_user.dart';
import 'package:rukuntetangga/pages/admin/settings.dart';
import 'package:rukuntetangga/pages/admin/emergency.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  // Navigate to different screens
  void _onNavigate(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // List of admin screens
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Initialize screens with navigation callback
    _screens = [
      AdminHomeScreen(onNavigate: _onNavigate),
      const ManageAnnouncementsScreen(),
      const ManageUsersScreen(),
      const EmergencyScreen(),
      const AdminSettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                kPrimaryColor,
                kPrimaryColor.withAlpha(26),
                const Color.fromARGB(255, 0, 0, 0),
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: AppBar(
            title: Text(
              'Admin Dashboard',
              style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
          ),
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavigate,
        selectedItemColor: kPrimaryColor,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign),
            label: 'Announcements',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: 'Emergency',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}