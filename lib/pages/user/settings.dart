import 'package:flutter/material.dart';
import 'package:rukuntetangga/services/auth_services.dart';
import 'package:rukuntetangga/pages/login.dart';
import 'package:rukuntetangga/pages/user/editprofile.dart';
import 'package:rukuntetangga/widgets/constants.dart';
import 'package:rukuntetangga/widgets/common_app_bar.dart';

class SettingsScreen extends StatefulWidget {
  final int notificationCount;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSearchTap;
  final String username;
  final int activeMembers;

  const SettingsScreen({
    super.key,
    this.notificationCount = 0,
    this.onNotificationTap,
    this.onSearchTap,
    this.username = '',
    this.activeMembers = 0,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        username: widget.username,
        notificationCount: widget.notificationCount,
        onSearchTap: widget.onSearchTap,
        onNotificationTap: widget.onNotificationTap,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // User profile section
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color.fromARGB(255, 255, 255, 255),
                        radius: 30,
                        child: Icon(Icons.person, size: 30, color: kPrimaryColor),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _authService.currentUser?.email ?? 'User',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'User ID: ${_authService.currentUser?.uid.substring(0, 8) ?? 'Unknown'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      // Navigate to edit profile screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: kPrimaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(color: kPrimaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // App settings section
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'App Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Notifications'),
                    subtitle: const Text('Enable push notifications'),
                    value: _notifications,
                    onChanged: (value) {
                      setState(() {
                        _notifications = value;
                      });
                      // TODO: Implement notifications toggle
                    },
                    secondary: const Icon(Icons.notifications),
                    activeColor: kPrimaryColor,
                  ),
                  const Divider(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Account options section
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: const Text('Change Password'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Implement change password functionality
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Help & Support'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Help & Support'),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Contact Information',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Email: support@rukuntetangga.com',
                                      style: TextStyle(color: Colors.grey[800]),
                                    ),
                                    Text(
                                      'Phone: +60 13-295-3112',
                                      style: TextStyle(color: Colors.grey[800]),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Frequently Asked Questions',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      '• How do I update my profile information?',
                                    ),
                                    const Text('• How can I reset my password?'),
                                    const Text(
                                      '• How do I report an issue in my community?',
                                    ),
                                    const Text(
                                      '• How can I volunteer for community activities?',
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    'Close',
                                    style: TextStyle(color: kPrimaryColor),
                                  ),
                                ),
                              ],
                            ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('About'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Center(
                                      child: Column(
                                        children: [
                                          const Icon(
                                            Icons.people_alt_rounded,
                                            size: 50,
                                            color: kPrimaryColor,
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Rukun Tetangga',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Version 1.0.0',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Description',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Rukun Tetangga is a community management application designed to facilitate communication and organization within neighborhood communities.',
                                      style: TextStyle(color: Colors.grey[800]),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Developed By',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Final Year Student Project',
                                      style: TextStyle(color: Colors.grey[800]),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Legal',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '© 2025 Rukun Tetangga. All rights reserved.',
                                      style: TextStyle(color: Colors.grey[800]),
                                    ),
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () {
                                        // TODO: Link to Privacy Policy
                                      },
                                      child: const Text(
                                        'Privacy Policy',
                                        style: TextStyle(
                                          color: kPrimaryColor,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () {
                                        // TODO: Link to Terms of Service
                                      },
                                      child: const Text(
                                        'Terms of Service',
                                        style: TextStyle(
                                          color: kPrimaryColor,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    'Close',
                                    style: TextStyle(color: kPrimaryColor),
                                  ),
                                ),
                              ],
                            ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () async {
                      await _authService.signOut();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}