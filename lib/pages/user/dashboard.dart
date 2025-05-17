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
  String _username = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<MapScreenState> _mapScreenKey = GlobalKey<MapScreenState>();

  @override
  void initState() {
    super.initState();
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
            userData['username'].toString().isEmpty)
            debugPrint('Profile is incomplete');
        else {
          debugPrint('Profile is complete');
        }
      }
    } catch (e) {
      debugPrint('Error checking profile completeness: $e');
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

  @override
  Widget build(BuildContext context) {
    // Create screens dynamically to ensure onNavigate callback works properly
    final List<Widget> screens = [
      HomeScreen(
        onNavigate: _onNavigate,
        onSearchTap: _handleSearch,
        username: _username,
        activeMembers: _activeMembers,
      ),
      InformationScreen(
        onSearchTap: _handleSearch,
        username: _username,
        activeMembers: _activeMembers,
      ),
      MapScreen(key: _mapScreenKey),
      TimetablePage(
        username: _username,
        onSearchTap: _handleSearch,
      ),
      SettingsScreen(),
    ];

    return Scaffold(
      // Use only the CommonAppBar, removing the duplicate appBar
      appBar: CommonAppBar(
        username: _username,
        onSearchTap: _handleSearch,
      ),
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: kPrimaryColor,
        onTap: _onNavigate,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'Information',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Maps'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
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
