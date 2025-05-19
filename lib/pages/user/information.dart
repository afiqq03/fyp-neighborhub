import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:rukuntetangga/widgets/constants.dart';
import 'package:rukuntetangga/widgets/gradient_app_bar.dart';

class InformationScreen extends StatefulWidget {
  final VoidCallback? onSearchTap;
  final String username;
  final int activeMembers;

  const InformationScreen({
    super.key,
    this.onSearchTap,
    this.username = '',
    this.activeMembers = 0,
  });

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  List<Map<String, dynamic>> _announcements = [];
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    // Existing loadAnnouncements code...
    // (Your implementation remains unchanged)
    setState(() {
      _isLoading = true;
    });

    try {
      // Load announcements from Firestore
      final snapshot = await _firestore
          .collection('announcements')
          .orderBy('date', descending: true)
          .get();
      
      setState(() {
        _announcements = snapshot.docs.map((doc) => {
          'id': doc.id,
          ...doc.data(),
        }).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading announcements: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get filteredAnnouncements {
    // Existing filteredAnnouncements getter...
    // (Your implementation remains unchanged)
    if (_selectedFilter == 'All') return _announcements;
    if (_selectedFilter == 'High Priority') {
      return _announcements.where((a) => a['priority'] == 'High').toList();
    }
    if (_selectedFilter == 'Recent') {
      // Return announcements from the last 7 days
      final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
      return _announcements.where((a) {
        if (a['date'] is Timestamp) {
          return (a['date'] as Timestamp).toDate().isAfter(oneWeekAgo);
        }
        return true; // Keep it if we can't determine the date
      }).toList();
    }
    return _announcements;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: 'Information',
        showGreeting: true,
        username: widget.username,
        onSearchTap: widget.onSearchTap,
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Information header
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Community Announcements',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Stay updated with the latest information from your community',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          
          // Filter chips
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  selected: _selectedFilter == 'All',
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = 'All';
                    });
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: kPrimaryColor,
                  checkmarkColor: Colors.white,
                ),
                FilterChip(
                  label: const Text('High Priority'),
                  selected: _selectedFilter == 'High Priority',
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = selected ? 'High Priority' : 'All';
                    });
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: Colors.red[400],
                  checkmarkColor: Colors.white,
                ),
                FilterChip(
                  label: const Text('Recent'),
                  selected: _selectedFilter == 'Recent',
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = selected ? 'Recent' : 'All';
                    });
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: Colors.blue[400],
                  checkmarkColor: Colors.white,
                ),
              ],
            ),
          ),
          
          // Announcements list
          Expanded(
            child: _isLoading 
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : filteredAnnouncements.isEmpty
                    ? const Center(
                        child: Text('No announcements available'),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadAnnouncements,
                        child: ListView.builder(
                          // Your existing ListView.builder implementation...
                          // (No changes needed here)
                          padding: const EdgeInsets.all(8),
                          itemCount: filteredAnnouncements.length,
                          itemBuilder: (context, index) {
                            // Existing item builder code
                            final announcement = filteredAnnouncements[index];
                            
                            // Rest of the implementation remains the same
                            // Determine priority color
                            Color priorityColor;
                            switch (announcement['priority']) {
                              case 'High':
                                priorityColor = Colors.red;
                                break;
                              case 'Medium':
                                priorityColor = Colors.orange;
                                break;
                              case 'Low':
                                priorityColor = Colors.green;
                                break;
                              default:
                                priorityColor = Colors.blue;
                            }
                            
                            // Format the date if it's a Timestamp
                            String formattedDate = 'Unknown date';
                            if (announcement['date'] is Timestamp) {
                              final date = (announcement['date'] as Timestamp).toDate();
                              formattedDate = DateFormat('MMMM d, yyyy').format(date);
                            } else if (announcement['date'] is String) {
                              formattedDate = announcement['date'];
                            }
                            
                            return Card(
                              // Existing card implementation
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: InkWell(
                                onTap: () {
                                  _showAnnouncementDetails(context, announcement, formattedDate, priorityColor);
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Chip(
                                            label: Text(
                                              announcement['priority'],
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                            backgroundColor: priorityColor,
                                            padding: EdgeInsets.zero,
                                          ),
                                          Text(
                                            formattedDate,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        announcement['title'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        announcement['content'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[800],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: () {
                                            _showAnnouncementDetails(context, announcement, formattedDate, priorityColor);
                                          },
                                          child: const Text(
                                            'Read More',
                                            style: TextStyle(color: kPrimaryColor),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
  
  // Existing _showAnnouncementDetails method remains unchanged
  void _showAnnouncementDetails(BuildContext context, Map<String, dynamic> announcement, 
      String formattedDate, Color priorityColor) {
    // Your existing implementation...
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(announcement['title']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text(
                      announcement['priority'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: priorityColor,
                    padding: EdgeInsets.zero,
                  ),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                announcement['content'],
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close', style: TextStyle(color: kPrimaryColor)),
          ),
        ],
      ),
    );
  }
}