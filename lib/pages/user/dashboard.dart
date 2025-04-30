import 'package:flutter/material.dart';
import 'package:rukuntetangga/pages/user/home.dart';
import 'package:rukuntetangga/pages/user/information.dart';
import 'package:rukuntetangga/pages/user/settings.dart';
import 'package:rukuntetangga/pages/user/maps.dart';
import 'package:rukuntetangga/pages/user/timetable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rukuntetangga/widgets/constants.dart';
import 'package:rukuntetangga/widgets/common_app_bar.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  int _activeMembers = 0;
  int _notificationCount = 0;
  String _username = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<MapScreenState> _mapScreenKey = GlobalKey<MapScreenState>();

  @override
  void initState() {
    super.initState();
    _fetchNotificationCount();
    _fetchActiveMembers();
    _fetchUserInfo();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkProfileCompleteness();
    });
  }

Future<void> _checkProfileCompleteness() async {
  debugPrint('Checking profile completeness...');
  try {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      debugPrint('User ID is null');
      return;
    }

    final DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();
    
    debugPrint('User document exists: ${userDoc.exists}');
    
    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      
      // Print the relevant fields to debug
      debugPrint('Phone: ${userData['phone']}');
      debugPrint('Address: ${userData['address']}');
      debugPrint('Username: ${userData['username']}');

      if (userData['phone'] == null ||
          userData['phone'].toString().isEmpty ||
          userData['address'] == null ||
          userData['address'].toString().isEmpty ||
          userData['username'] == null ||
          userData['username'].toString().isEmpty) {;
        debugPrint('Profile is incomplete');
      } else {
        debugPrint('Profile is complete');
      }
    }
  } catch (e) {
    debugPrint('Error checking profile completeness: $e');
  }
}

  // Fetch notification count
  Future<void> _fetchNotificationCount() async {
    try {
      // Get unread notifications for current user
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final QuerySnapshot snapshot =
          await _firestore
              .collection('notifications')
              .where('userId', isEqualTo: userId)
              .where('read', isEqualTo: false)
              .get();

      if (mounted) {
        setState(() {
          _notificationCount = snapshot.docs.length;
        });
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    }
  }

  // Fetch active community members
  Future<void> _fetchActiveMembers() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore
              .collection('users')
              .where('status', isEqualTo: 'Active')
              .get();

      if (mounted) {
        setState(() {
          _activeMembers = snapshot.docs.length;
        });
      }
    } catch (e) {
      debugPrint('Error fetching active members: $e');
    }
  }

  // Fetch user info
  Future<void> _fetchUserInfo() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists && mounted) {
        setState(() {
          _username =
              (userDoc.data() as Map<String, dynamic>)['fullName'] ?? 'User';
        });
      }
    } catch (e) {
      debugPrint('Error fetching user info: $e');
    }
  }

  void _onNavigate(int index) {
    // Don't rebuild if selecting the same index
    if (_selectedIndex != index) {
      // If map tab is selected (index 2), activate the map
      if (index == 2) {
        _mapScreenKey.currentState?.activateMap();
      }

      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Simple search function that doesn't crash
  void _handleSearch() {
    // Use a simple dialog instead of SearchDelegate for now
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Search'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search community...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    // You can implement search logic here
                  },
                ),
                const SizedBox(height: 16),
                const Text('Search feature coming soon!'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  // Simple notifications view that doesn't crash
  void _handleNotifications() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Simple placeholder for marking notifications as read
                          setState(() {
                            _notificationCount = 0;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Mark all as read'),
                      ),
                    ],
                  ),
                  const Divider(),

                  // Simplified notification list
                  Expanded(
                    child:
                        _notificationCount > 0
                            ? ListView.builder(
                              itemCount: _notificationCount,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: kPrimaryColor,
                                    child: Icon(
                                      Icons.notifications,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text('Notification ${index + 1}'),
                                  subtitle: const Text('Tap to view details'),
                                  onTap: () {
                                    // Handle notification tap
                                  },
                                );
                              },
                            )
                            : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.notifications_off_outlined,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No notifications yet',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Create screens dynamically to ensure onNavigate callback works properly
    final List<Widget> screens = [
      HomeScreen(
        onNavigate: _onNavigate,
        notificationCount: _notificationCount,
        onNotificationTap: _handleNotifications,
        onSearchTap: _handleSearch,
        username: _username,
        activeMembers: _activeMembers,
      ),
      InformationScreen(
        notificationCount: _notificationCount,
        onNotificationTap: _handleNotifications,
        onSearchTap: _handleSearch,
        username: _username,
        activeMembers: _activeMembers,
      ),
      MapScreen(key: _mapScreenKey),
      const TimetablePage(),
      SettingsScreen(),
    ];

    return Scaffold(
      // Use only the CommonAppBar, removing the duplicate appBar
      appBar: CommonAppBar(
        username: _username,
        notificationCount: _notificationCount,
        onSearchTap: _handleSearch,
        onNotificationTap: _handleNotifications,
      ),
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: kPrimaryColor,
        onTap: _onNavigate,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.info_outline),label: 'Information',),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Maps'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings',
          ),
        ],
      ),
    );
  }
}
