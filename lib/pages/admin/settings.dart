import 'package:flutter/material.dart';
import 'package:rukuntetangga/services/auth_services.dart';
import 'package:rukuntetangga/pages/login.dart';
import 'package:rukuntetangga/widgets/constants.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final AuthService _authService = AuthService();

  // Properly handle logout with mounted check
  Future<void> _handleLogout(BuildContext context) async {
    final navigatorContext = context;
    await _authService.signOut();
    
    // Check if the widget is still in the tree before using context
    if (mounted) {
      Navigator.of(navigatorContext).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Admin profile section
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
                  'Admin Profile',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color.fromARGB(255, 255, 255, 255),
                      radius: 30,
                      child: Icon(
                        Icons.admin_panel_settings,
                        size: 30,
                        color: kPrimaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Role: Administrator',
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
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Account settings section
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
                  title: const Text('Admin Guide'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Admin Guide'),
                            content: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Managing Users',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '• To add new users, go to Users section and tap the + button',
                                    style: TextStyle(color: Colors.grey[800]),
                                  ),
                                  Text(
                                    '• To edit user details, tap the edit (pencil) icon',
                                    style: TextStyle(color: Colors.grey[800]),
                                  ),
                                  Text(
                                    '• To activate/deactivate users, tap the toggle icon',
                                    style: TextStyle(color: Colors.grey[800]),
                                  ),
                                  Text(
                                    '• To delete users, tap the delete icon (red trash bin)',
                                    style: TextStyle(color: Colors.grey[800]),
                                  ),
                                  Text(
                                    '• Search for users using the search bar at the top',
                                    style: TextStyle(color: Colors.grey[800]),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Managing Announcements',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '• Create announcements from the Announcements section',
                                    style: TextStyle(color: Colors.grey[800]),
                                  ),
                                  Text(
                                    '• Set priority levels appropriately for different types of announcements',
                                    style: TextStyle(color: Colors.grey[800]),
                                  ),
                                  Text(
                                    '• Add detailed information to ensure clear communication',
                                    style: TextStyle(color: Colors.grey[800]),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Emergency Alerts',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '• Monitor emergency alerts from the Emergencies section',
                                    style: TextStyle(color: Colors.grey[800]),
                                  ),
                                  Text(
                                    '• Review and respond to community emergencies promptly',
                                    style: TextStyle(color: Colors.grey[800]),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'System Maintenance',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '• Regular backups should be performed weekly',
                                    style: TextStyle(color: Colors.grey[800]),
                                  ),
                                  Text(
                                    '• Check dashboard statistics to monitor community activity',
                                    style: TextStyle(color: Colors.grey[800]),
                                  ),
                                  Text(
                                    '• Default password for new users is "123456"',
                                    style: TextStyle(color: Colors.grey[800]),
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
                                          'Version 1.0.0 (Admin)',
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
                                    'Rukun Tetangga Admin Panel is a comprehensive management tool designed for community administrators.',
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
                                    'Final Year Project Students - Wan Afiq',
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
                  onTap: () => _handleLogout(context),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
