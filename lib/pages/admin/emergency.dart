import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:rukuntetangga/widgets/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  // Replace Realtime Database with Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger('EmergencyScreen');

  bool _isLoading = true;
  List<Map<String, dynamic>> _emergencies = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadEmergencies();
  }

  Future<void> _loadEmergencies() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Listen for emergencies in real-time using Firestore snapshot listener
      _firestore
          .collection('emergencies')
          .snapshots()
          .listen(
            (QuerySnapshot snapshot) {
              if (!mounted) return;

              try {
                // Convert to list of emergencies
                List<Map<String, dynamic>> emergencyList = [];

                for (final doc in snapshot.docs) {
                  final emergency = doc.data() as Map<String, dynamic>;
                  emergency['id'] = doc.id; // Store document ID
                  emergencyList.add(emergency);
                }

                // Sort by timestamp (newest first)
                emergencyList.sort(
                  (a, b) =>
                      (b['timestamp'] as int).compareTo(a['timestamp'] as int),
                );

                setState(() {
                  _emergencies = emergencyList;
                  _isLoading = false;
                });
              } catch (e) {
                _logger.warning('Error parsing emergencies: $e');
                if (!mounted) return;
                setState(() {
                  _isLoading = false;
                });
              }
            },
            onError: (error) {
              _logger.warning('Error loading emergencies: $error');
              if (!mounted) return;
              setState(() {
                _isLoading = false;
              });
            },
          );
    } catch (e) {
      _logger.warning('Error setting up emergency listener: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Handle emergency resolution - fixed for Firestore
  Future<void> _resolveEmergency(Map<String, dynamic> emergency) async {
    // Ensure we have the document ID
    final String? emergencyId = emergency['id'];

    if (emergencyId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Cannot resolve emergency with no ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    _logger.info('Resolving emergency with ID: $emergencyId');

    // Confirm action
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Resolution'),
            content: const Text(
              'Mark this emergency as resolved? This will remove it from the active emergencies list.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.green),
                child: const Text('Resolve'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    // Show loading indicator
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Processing...'),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      // First, save this to emergency_stats for historical tracking
      final statsData = {
        'userId': emergency['userId'],
        'userEmail': emergency['userEmail'],
        'latitude': emergency['latitude'],
        'longitude': emergency['longitude'],
        'timestamp': emergency['timestamp'],
        'resolvedAt': DateTime.now().millisecondsSinceEpoch,
        'resolvedBy': _auth.currentUser?.uid ?? 'unknown',
        'month': DateFormat(
          'yyyy-MM',
        ).format(DateTime.fromMillisecondsSinceEpoch(emergency['timestamp'])),
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Save to emergency_stats collection in Firestore
      await _firestore.collection('emergency_stats').add(statsData);
      debugPrint('Added emergency to stats');

      // Then delete the emergency document from Firestore
      await _firestore.collection('emergencies').doc(emergencyId).delete();
      debugPrint('Deleted emergency from active list');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Emergency marked as resolved'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Error resolving emergency: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error resolving emergency: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Open location in maps app - unchanged
  Future<void> _openLocation(double lat, double lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    final uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open maps')));
      }
    } catch (e) {
      _logger.warning('Error opening map: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error opening map')));
    }
  }

  // Format timestamp as readable date/time - unchanged
  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd MMM yyyy, HH:mm:ss').format(date);
  }

  // Calculate time elapsed - unchanged
  String _timeElapsed(int timestamp) {
    final now = DateTime.now();
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day(s) ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour(s) ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute(s) ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Emergency Alerts',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage emergency alerts from community members',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ),

          // Emergency list
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _emergencies.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No active emergency alerts',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _emergencies.length,
                      itemBuilder: (context, index) {
                        final emergency = _emergencies[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.red, width: 1),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withAlpha(26),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.warning_amber_rounded,
                                            size: 18,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            emergency['status']
                                                    ?.toUpperCase() ??
                                                'PENDING',
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      _timeElapsed(emergency['timestamp']),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const CircleAvatar(
                                    backgroundColor: Colors.red,
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    emergency['userEmail'] ?? 'Unknown User',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'ID: ${emergency['userId']?.toString().substring(0, 8) ?? 'Unknown'}',
                                  ),
                                ),
                                const Divider(),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const CircleAvatar(
                                    backgroundColor: Colors.blue,
                                    child: Icon(
                                      Icons.location_on,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: const Text('Emergency Location'),
                                  subtitle: Text(
                                    'Latitude: ${emergency['latitude']?.toStringAsFixed(6)}\nLongitude: ${emergency['longitude']?.toStringAsFixed(6)}',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.map),
                                    onPressed:
                                        () => _openLocation(
                                          emergency['latitude'],
                                          emergency['longitude'],
                                        ),
                                    tooltip: 'View on map',
                                  ),
                                ),
                                const Divider(),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const CircleAvatar(
                                    backgroundColor: Colors.orange,
                                    child: Icon(
                                      Icons.access_time,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: const Text('Reported Time'),
                                  subtitle: Text(
                                    _formatTimestamp(emergency['timestamp']),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton.icon(
                                      icon: const Icon(Icons.call),
                                      label: const Text('Call User'),
                                      onPressed: () {
                                        // Phone call functionality would go here
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Call feature coming soon',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.check),
                                      label: const Text('Mark Resolved'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed:
                                          () => _resolveEmergency(emergency),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
