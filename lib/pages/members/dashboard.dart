import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'manage_announcement.dart';
import 'resolve_emergency.dart';
import 'view_users.dart';
import 'view_timetable.dart';
import 'package:rukuntetangga/widgets/constants.dart';
import 'package:rukuntetangga/pages/login.dart';

class MemberDashboard extends StatefulWidget {
  const MemberDashboard({super.key});

  @override
  State<MemberDashboard> createState() => _MemberDashboardState();
}

class _MemberDashboardState extends State<MemberDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _selectedIndex = 0;
  bool _isLoading = true;
  bool _isAuthorized = false;

  @override
  void initState() {
    super.initState();
    _checkAuthAndRole();
  }

  Future<void> _checkAuthAndRole() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _redirectToLogin();
        return;
      }

      // Check user role in Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        _redirectToLogin();
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final role = userData['role'] as String?;

      if (role?.toLowerCase() != 'member') {
        _redirectToLogin();
        return;
      }

      setState(() {
        _isAuthorized = true;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error checking auth: $e');
      _redirectToLogin();
    }
  }

  void _redirectToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isAuthorized) {
      return const Scaffold(
        body: Center(
          child: Text('Unauthorized access'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                kPrimaryColor,
                kSecondaryColor,
                kSurfaceColor,
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: AppBar(
            title: const Text(
              'Member Dashboard',
              style: TextStyle(
                color: kTextPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
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
      drawer: Drawer(
        backgroundColor: kSurfaceColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kPrimaryColor, kSecondaryColor],
                ),
              ),
              child: StreamBuilder<DocumentSnapshot>(
                stream: _firestore.collection('users').doc(_auth.currentUser?.uid).snapshots(),
                builder: (context, snapshot) {
                  final userData = snapshot.data?.data() as Map<String, dynamic>?;
                  final userName = userData?['name'] ?? 'Member';
                  final userEmail = userData?['email'] ?? '';
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: kAccentColor,
                        child: Icon(Icons.person, size: 35, color: kTextPrimaryColor),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        userName,
                        style: const TextStyle(
                          color: kTextPrimaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        userEmail,
                        style: const TextStyle(
                          color: kTextSecondaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: kAccentColor),
              title: const Text('Home', style: TextStyle(color: kTextPrimaryColor)),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedIndex = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.announcement, color: kAccentColor),
              title: const Text('Announcements', style: TextStyle(color: kTextPrimaryColor)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageAnnouncementScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning, color: kAccentColor),
              title: const Text('Emergencies', style: TextStyle(color: kTextPrimaryColor)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ResolveEmergencyScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.people, color: kAccentColor),
              title: const Text('Community', style: TextStyle(color: kTextPrimaryColor)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ViewUsersScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: kAccentColor),
              title: const Text('Schedule', style: TextStyle(color: kTextPrimaryColor)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ViewTimetableScreen()),
                );
              },
            ),
            const Divider(color: kDividerColor),
            ListTile(
              leading: const Icon(Icons.settings, color: kAccentColor),
              title: const Text('Settings', style: TextStyle(color: kTextPrimaryColor)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to settings page
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: kErrorColor),
              title: const Text('Sign Out', style: TextStyle(color: kErrorColor)),
              onTap: () {
                Navigator.pop(context);
                _signOut();
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          _buildAnnouncementsTab(),
          _buildEmergenciesTab(),
          _buildCommunityTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: kSurfaceColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: kSurfaceColor,
          selectedItemColor: kAccentColor,
          unselectedItemColor: kTextSecondaryColor,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.announcement),
              label: 'Announcements',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.warning),
              label: 'Emergencies',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Community',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section with User Info
            StreamBuilder<DocumentSnapshot>(
              stream: _firestore.collection('users').doc(_auth.currentUser?.uid).snapshots(),
              builder: (context, snapshot) {
                final userData = snapshot.data?.data() as Map<String, dynamic>?;
                final userName = userData?['name'] ?? 'Member';
                
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        kPrimaryColor.withOpacity(0.8),
                        kSecondaryColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: kAccentColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.waving_hand,
                          color: kAccentColor,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, $userName!',
                              style: const TextStyle(
                                color: kTextPrimaryColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Manage your community activities',
                              style: TextStyle(
                                color: kTextSecondaryColor,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 25),

            // Quick Actions Grid
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kTextPrimaryColor,
              ),
            ),
            const SizedBox(height: 15),
            AnimationLimiter(
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 375),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: widget,
                    ),
                  ),
                  children: [
                    _buildActionCard(
                      context,
                      'Manage Announcements',
                      Icons.announcement,
                      kAccentColor,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ManageAnnouncementScreen()),
                      ),
                    ),
                    _buildActionCard(
                      context,
                      'Resolve Emergencies',
                      Icons.warning,
                      kWarningColor,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ResolveEmergencyScreen()),
                      ),
                    ),
                    _buildActionCard(
                      context,
                      'View Users',
                      Icons.people,
                      kSuccessColor,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ViewUsersScreen()),
                      ),
                    ),
                    _buildActionCard(
                      context,
                      'View Timetable',
                      Icons.calendar_today,
                      kInfoColor,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ViewTimetableScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Recent Announcements
            const Text(
              'Recent Announcements',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kTextPrimaryColor,
              ),
            ),
            const SizedBox(height: 15),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('announcements')
                  .orderBy('createdAt', descending: true)
                  .limit(3)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final announcements = snapshot.data!.docs;
                return Column(
                  children: announcements.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      color: kCardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.announcement, color: kAccentColor),
                        title: Text(
                          data['text'] ?? '',
                          style: const TextStyle(color: kTextPrimaryColor),
                        ),
                        subtitle: Text(
                          data['createdAt']?.toDate().toString() ?? '',
                          style: const TextStyle(color: kTextSecondaryColor),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementsTab() {
    return const ManageAnnouncementScreen();
  }

  Widget _buildEmergenciesTab() {
    return const ResolveEmergencyScreen();
  }

  Widget _buildCommunityTab() {
    return const ViewUsersScreen();
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      color: kCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.2),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 