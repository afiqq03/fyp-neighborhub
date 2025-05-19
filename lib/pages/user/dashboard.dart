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

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<UserDashboard> {
  int _selectedIndex = 0;
  String _username = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<MapScreenState> _mapScreenKey = GlobalKey<MapScreenState>();
  bool _isProfileComplete = false;

  @override
  void initState() {
    super.initState();
    _fetchUserInfoAndCheckProfile();
  }

  // Combined method to fetch user info and check profile completeness
  Future<void> _fetchUserInfoAndCheckProfile() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        debugPrint('User ID is null');
        return;
      }

      // Try to get from cache first, then from server if needed
      final userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get(const GetOptions(source: Source.cache))
          .catchError((_) => _firestore.collection('users').doc(userId).get());

      if (userDoc.exists && mounted) {
        final userData = userDoc.data() as Map<String, dynamic>;
        
        // Update username
        setState(() {
          _username = userData['fullName'] ?? 'User';
        });

        // Check profile completeness
        _isProfileComplete = userData['phone'] != null &&
            userData['phone'].toString().isNotEmpty &&
            userData['address'] != null &&
            userData['address'].toString().isNotEmpty &&
            userData['username'] != null &&
            userData['username'].toString().isNotEmpty;

        debugPrint('Profile is ${_isProfileComplete ? 'complete' : 'incomplete'}');
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
      ),
      InformationScreen(onSearchTap: _handleSearch, username: _username),
      MapScreen(key: _mapScreenKey),
      TimetablePage(username: _username, onSearchTap: _handleSearch),
      SettingsScreen(),
    ];

    return Scaffold(
      // Use only the CommonAppBar, removing the duplicate appBar
      appBar: CommonAppBar(username: _username, onSearchTap: _handleSearch),
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
