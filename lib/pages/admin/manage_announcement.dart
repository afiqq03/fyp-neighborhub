import 'package:flutter/material.dart';
import 'package:rukuntetangga/widgets/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; 

class ManageAnnouncementsScreen extends StatefulWidget {
  const ManageAnnouncementsScreen({super.key});

  @override
  State<ManageAnnouncementsScreen> createState() => _ManageAnnouncementsScreenState();
}

class _ManageAnnouncementsScreenState extends State<ManageAnnouncementsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedFilter = 'All';
  bool _isLoading = false;
  List<Map<String, dynamic>> _announcements = [];

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch announcements from Firestore
      final snapshot = await _firestore.collection('announcements').orderBy('date', descending: true).get();
      
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
    if (_selectedFilter == 'All') return _announcements;
    return _announcements.where((a) => a['priority'] == _selectedFilter).toList();
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
                  'Manage Announcements',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create and manage community announcements',
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedFilter == 'All',
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = 'All';
                    });
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: kPrimaryColor.withAlpha(26), 
                  labelStyle: TextStyle(
                    color: _selectedFilter == 'All' ? kPrimaryColor : Colors.black,
                  ),
                ),
                FilterChip(
                  label: const Text('High'),
                  selected: _selectedFilter == 'High',
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = 'High';
                    });
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: Colors.red.withAlpha(26),
                  labelStyle: TextStyle(
                    color: _selectedFilter == 'High' ? Colors.red : Colors.black,
                  ),
                ),
                FilterChip(
                  label: const Text('Medium'),
                  selected: _selectedFilter == 'Medium',
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = 'Medium';
                    });
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: Colors.orange.withAlpha(51),
                  labelStyle: TextStyle(
                    color: _selectedFilter == 'Medium' ? Colors.orange : Colors.black,
                  ),
                ),
                FilterChip(
                  label: const Text('Low'),
                  selected: _selectedFilter == 'Low',
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = 'Low';
                    });
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: kPrimaryColor.withAlpha(26), 
                  labelStyle: TextStyle(
                    color: _selectedFilter == 'Low' ? Colors.green : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          
          // Announcements list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredAnnouncements.isEmpty
                    ? const Center(child: Text('No announcements found'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredAnnouncements.length,
                        itemBuilder: (context, index) {
                          final announcement = filteredAnnouncements[index];
                          Color priorityColor;
                          switch (announcement['priority']) {
                            case 'High':
                              priorityColor = Colors.red;
                              break;
                            case 'Medium':
                              priorityColor = Colors.orange;
                              break;
                            default:
                              priorityColor = Colors.green;
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
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
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
                                            color: Colors.white,
                                            fontSize: 12,
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
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          _editAnnouncement(announcement);
                                        },
                                        child: const Text('Edit'),
                                      ),
                                      const SizedBox(width: 8),
                                      TextButton(
                                        onPressed: () {
                                          _deleteAnnouncement(announcement['id']);
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        child: const Text('Delete'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewAnnouncement,
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  
  void _createNewAnnouncement() {
    showDialog(
      context: context,
      builder: (context) => AnnouncementFormDialog(
        title: 'Create Announcement',
        onSave: (announcement) {
          // Add new announcement to the list and refresh
          setState(() {
            _announcements.insert(0, announcement);
          });
        },
      ),
    );
  }
  
  void _editAnnouncement(Map<String, dynamic> announcement) {
    showDialog(
      context: context,
      builder: (context) => AnnouncementFormDialog(
        title: 'Edit Announcement',
        announcement: announcement,
        onSave: (updatedAnnouncement) {
          // Update announcement in the list and refresh
          setState(() {
            final index = _announcements.indexWhere((a) => a['id'] == updatedAnnouncement['id']);
            if (index != -1) {
              _announcements[index] = updatedAnnouncement;
            }
          });
        },
      ),
    );
  }
  
  Future<void> _deleteAnnouncement(String id) async {
    // Confirm delete
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this announcement?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        // Delete from Firestore
        await _firestore.collection('announcements').doc(id).delete();
        
        // Update local state
        setState(() {
          _announcements.removeWhere((a) => a['id'] == id);
        });
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Announcement deleted successfully')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting announcement: $e')),
        );
      }
    }
  }
}

class AnnouncementFormDialog extends StatefulWidget {
  final String title;
  final Map<String, dynamic>? announcement;
  final Function(Map<String, dynamic>)? onSave;
  
  const AnnouncementFormDialog({
    super.key,
    required this.title,
    this.announcement,
    this.onSave,
  });

  @override
  State<AnnouncementFormDialog> createState() => _AnnouncementFormDialogState();
}

class _AnnouncementFormDialogState extends State<AnnouncementFormDialog> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _priority = 'Medium';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.announcement != null) {
      _titleController.text = widget.announcement!['title'];
      _contentController.text = widget.announcement!['content'];
      _priority = widget.announcement!['priority'];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter content';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _priority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: ['High', 'Medium', 'Low'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _priority = newValue!;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveAnnouncement,
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(widget.announcement == null ? 'Create' : 'Update'),
        ),
      ],
    );
  }

  Future<void> _saveAnnouncement() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        Map<String, dynamic> announcementData = {
          'title': _titleController.text.trim(),
          'content': _contentController.text.trim(),
          'priority': _priority,
          'date': FieldValue.serverTimestamp(), // Use server timestamp
        };

        Map<String, dynamic> resultAnnouncement;
        
        if (widget.announcement == null) {
          // Create new announcement
          DocumentReference docRef = await _firestore.collection('announcements').add(announcementData);
          // Get the document ID
          resultAnnouncement = {
            'id': docRef.id,
            ...announcementData,
            'date': Timestamp.now(), // For immediate display
          };
        } else {
          // Update existing announcement
          await _firestore
              .collection('announcements')
              .doc(widget.announcement!['id'])
              .update(announcementData);
          
          // Use the existing ID
          resultAnnouncement = {
            'id': widget.announcement!['id'],
            ...announcementData,
            'date': Timestamp.now(), // For immediate display
          };
        }

        if (!mounted) return;
        
        // Call the onSave callback with the result
        if (widget.onSave != null) {
          widget.onSave!(resultAnnouncement);
        }
        
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.announcement == null 
              ? 'Announcement created successfully' 
              : 'Announcement updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}