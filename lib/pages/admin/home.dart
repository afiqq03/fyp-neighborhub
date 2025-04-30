import 'package:flutter/material.dart';
import 'package:rukuntetangga/widgets/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:io';

class AdminHomeScreen extends StatefulWidget {
  final Function(int)? onNavigate;

  const AdminHomeScreen({super.key, this.onNavigate});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  int _userCount = 0;
  int _announcementCount = 0;
  int _emergencyCount = 0;

  // Store previous values to show while loading new data
  int _lastUserCount = 0;
  int _lastAnnouncementCount = 0;
  int _lastEmergencyCount = 0;

  // Add cancelable timers
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.settings = Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    Future.delayed(const Duration(milliseconds: 100), _loadStats);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  // Check internet connectivity with multiple servers for reliability
  Future<bool> _checkConnectivity() async {
    try {
      // Try multiple DNS servers to increase reliability
      final addresses = [
        'google.com',
        'firebase.google.com',
        'firestore.googleapis.com'
      ];
      
      for (final address in addresses) {
        try {
          final result = await InternetAddress.lookup(address)
              .timeout(const Duration(seconds: 5));
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            return true;
          }
        } catch (_) {
          // Try next address
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _loadStats() async {
    // Don't start loading if already in progress
    if (_isLoading) return;

    // Check connectivity first
    final hasConnection = await _checkConnectivity();

    if (!hasConnection) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No internet connection. Using cached data.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        // Show previous data while loading
        _userCount = _lastUserCount;
        _announcementCount = _lastAnnouncementCount;
        _emergencyCount = _lastEmergencyCount;
      });
    }

    try {
      // Increased timeout for better reliability
      final timeout = const Duration(seconds: 8);

      // Handle each collection fetch separately
      try {
        final usersSnapshot = await _firestore
            .collection('users')
            .get()
            .timeout(timeout);
        
        if (mounted) {
          setState(() {
            _userCount = usersSnapshot.docs.length;
            _lastUserCount = _userCount;
          });
        }
      } catch (e) {
        debugPrint('Error loading users: $e');
      }

      try {
        final announcementsSnapshot = await _firestore
            .collection('announcements')
            .get()
            .timeout(timeout);
        
        if (mounted) {
          setState(() {
            _announcementCount = announcementsSnapshot.docs.length;
            _lastAnnouncementCount = _announcementCount;
          });
        }
      } catch (e) {
        debugPrint('Error loading announcements: $e');
      }

      try {
        final emergenciesSnapshot = await _firestore
            .collection('emergencies')
            .get()
            .timeout(timeout);
        
        if (mounted) {
          setState(() {
            _emergencyCount = emergenciesSnapshot.docs.length;
            _lastEmergencyCount = _emergencyCount;
          });
        }
      } catch (e) {
        debugPrint('Error loading emergencies: $e');
      }

      // Set loading state to false once all queries are done
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Only show error message if we don't have cached data
        if (_lastUserCount == 0 &&
            _lastAnnouncementCount == 0 &&
            _lastEmergencyCount == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Unable to load data. Please check your connection.',
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }
        debugPrint('Error loading stats: $e');
        if (e is TimeoutException) {
          debugPrint('Request timed out');
        } else if (e is FirebaseException) {
          debugPrint('Firebase error code: ${e.code}, message: ${e.message}');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Admin welcome card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kPrimaryColor, kPrimaryColor.withAlpha(26),],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white.withAlpha(230),
                            radius: 25,
                            child: const Icon(
                              Icons.admin_panel_settings,
                              color: kPrimaryColor,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 15),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, Admin',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'NeighborHub Dashboard',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Manage your community effectively',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Community Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Community Statistics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  if (_isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Stats cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context: context,
                      icon: Icons.people,
                      title: 'Users',
                      value: _userCount.toString(),
                      color: Colors.blue,
                      onTap: () => widget.onNavigate?.call(2),
                      isLoading: _isLoading,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      context: context,
                      icon: Icons.campaign,
                      title: 'Announcements',
                      value: _announcementCount.toString(),
                      color: Colors.orange,
                      onTap: () => widget.onNavigate?.call(1),
                      isLoading: _isLoading,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context: context,
                      icon: Icons.warning,
                      title: 'Emergencies',
                      value: _emergencyCount.toString(),
                      color: Colors.red,
                      onTap: () => widget.onNavigate?.call(3),
                      isLoading: _isLoading,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),

              // Quick action buttons
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildActionButton(
                        icon: Icons.add_alert,
                        label: 'Create New Announcement',
                        onTap: () => widget.onNavigate?.call(1),
                      ),
                      const Divider(),
                      _buildActionButton(
                        icon: Icons.person_add,
                        label: 'Add New Members',
                        onTap: () => widget.onNavigate?.call(2),
                      ),
                      const Divider(),
                      _buildActionButton(
                        icon: Icons.warning_amber,
                        label: 'View Emergency Alerts',
                        onTap: () => widget.onNavigate?.call(3),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required VoidCallback onTap,
    required bool isLoading,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 36),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child:
                    isLoading
                        ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        )
                        : Text(
                          value,
                          key: ValueKey<String>(value),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: kPrimaryColor),
      title: Text(label),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}