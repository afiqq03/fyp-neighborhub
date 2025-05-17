import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:rukuntetangga/widgets/constants.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminTimetablePage extends StatefulWidget {
  const AdminTimetablePage({super.key});

  @override
  State<AdminTimetablePage> createState() => _AdminTimetablePageState();
}

class _AdminTimetablePageState extends State<AdminTimetablePage> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  
  // Member assignments data
  final Map<String, List<MemberAssignment>> _assignments = {};
  late List<MemberAssignment> _selectedAssignments;
  
  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _selectedAssignments = []; // Initialize with empty list
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final QuerySnapshot assignmentsSnapshot = await _firestore
          .collection('member_assignments')
          .get();

      // Clear existing assignments
      _assignments.clear();
      
      for (var doc in assignmentsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final date = (data['date'] as Timestamp).toDate();
        final dateStr = DateFormat('yyyy-MM-dd').format(date);
        
        if (_assignments[dateStr] == null) {
          _assignments[dateStr] = [];
        }
        
        _assignments[dateStr]!.add(MemberAssignment(
          id: doc.id,
          memberId: data['memberId'],
          memberName: data['memberName'],
      date: date,
          notes: data['notes'] ?? '',
        ));
      }
      
      setState(() {
        _selectedAssignments = _getAssignmentsForDay(_selectedDay);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading assignments: $e')),
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
  
  List<MemberAssignment> _getAssignmentsForDay(DateTime day) {
    final dateStr = DateFormat('yyyy-MM-dd').format(day);
    return _assignments[dateStr] ?? [];
  }

  Future<void> _assignMember() async {
    // Show member selection dialog
    final selectedMember = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const MemberSelectionDialog(),
    );
    
    if (!mounted) return;
    
    if (selectedMember != null) {
      // Show assignment details dialog
      final notes = await showDialog<String>(
        context: context,
        builder: (context) => AssignmentDetailsDialog(
          memberName: selectedMember['fullName'],
          date: _selectedDay,
        ),
      );
      
      if (!mounted) return;
      
      if (notes != null) {
        try {
          // Create new assignment in Firestore
          await _firestore.collection('member_assignments').add({
            'memberId': selectedMember['id'],
            'memberName': selectedMember['fullName'],
            'date': Timestamp.fromDate(_selectedDay),
            'notes': notes,
            'createdAt': FieldValue.serverTimestamp(),
          });
          
          // Refresh assignments
          _loadAssignments();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Member assigned successfully')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error assigning member: $e')),
            );
          }
        }
      }
    }
  }

  Future<void> _removeAssignment(MemberAssignment assignment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Assignment'),
        content: Text('Are you sure you want to remove ${assignment.memberName}\'s assignment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        await _firestore.collection('member_assignments').doc(assignment.id).delete();
        _loadAssignments();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Assignment removed successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error removing assignment: $e')),
          );
        }
      }
    }
  }

  void _showAssignmentDetails(MemberAssignment assignment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: kPrimaryColor.withOpacity(0.1),
                    child: Text(
                      assignment.memberName[0].toUpperCase(),
                      style: const TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assignment Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Assigned by Admin',
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _detailItem(Icons.calendar_today, 'Date', 
                  DateFormat('EEEE, MMMM d, yyyy').format(assignment.date)),
              const SizedBox(height: 16),
              if (assignment.notes.isNotEmpty) ...[
                _detailItem(Icons.note, 'Notes', assignment.notes),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailItem(IconData icon, String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.grey[600],
          size: 18,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
                  'Member Assignments',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Assign members to specific dates',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          
          // Calendar
        Card(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TableCalendar(
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: _getAssignmentsForDay,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                    _selectedAssignments = _getAssignmentsForDay(selectedDay);
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                markerDecoration: const BoxDecoration(
                  color: kPrimaryColor,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: kPrimaryColor,
                  shape: BoxShape.circle,
                ),
                outsideDaysVisible: false,
              ),
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: true,
                formatButtonDecoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                formatButtonTextStyle: TextStyle(color: kPrimaryColor),
                titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        
        // Date header
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      DateFormat('MMMM d, yyyy').format(_selectedDay),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                      '${_selectedAssignments.length} Assignments',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
                IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: _assignMember,
                  tooltip: 'Assign member',
                ),
            ],
          ),
        ),
        
          // Assignments list
        Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _selectedAssignments.isEmpty
              ? Center(
                  child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                              Icons.calendar_today,
                              size: 48,
                              color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                              'No assignments for this date',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: _assignMember,
                              icon: const Icon(Icons.person_add),
                              label: const Text('Assign a member'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _selectedAssignments.length,
                  itemBuilder: (context, index) {
                          final assignment = _selectedAssignments[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
                            ),
        child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
                                backgroundColor: kPrimaryColor.withOpacity(0.1),
                                child: Text(
                                  assignment.memberName[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: kPrimaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
            ),
          ),
          title: Text(
                                assignment.memberName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
                              subtitle: assignment.notes.isNotEmpty
                                  ? Text(
                                      assignment.notes,
                                      style: TextStyle(
                    color: Colors.grey[600],
                  ),
                                    )
                                  : null,
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                color: Colors.red,
                                onPressed: () => _removeAssignment(assignment),
                              ),
                              onTap: () => _showAssignmentDetails(assignment),
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

class MemberAssignment {
  final String id;
  final String memberId;
  final String memberName;
  final DateTime date;
  final String notes;

  MemberAssignment({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.date,
    required this.notes,
  });
}

class MemberSelectionDialog extends StatefulWidget {
  const MemberSelectionDialog({super.key});

  @override
  State<MemberSelectionDialog> createState() => _MemberSelectionDialogState();
}

class _MemberSelectionDialogState extends State<MemberSelectionDialog> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<Map<String, dynamic>> _members = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    try {
      final QuerySnapshot membersSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Member')
          .get();

      setState(() {
        _members = membersSnapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                })
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading members: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> get filteredMembers {
    if (_searchQuery.isEmpty) {
      return _members;
    }
    final query = _searchQuery.toLowerCase();
    return _members.where((member) {
      final name = (member['fullName'] ?? '').toLowerCase();
      final email = (member['email'] ?? '').toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Member'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search members...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Flexible(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredMembers.isEmpty
                      ? const Center(child: Text('No members found'))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredMembers.length,
                          itemBuilder: (context, index) {
                            final member = filteredMembers[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: kPrimaryColor.withOpacity(0.1),
                                child: Text(
                                  (member['fullName'] ?? 'U')[0].toUpperCase(),
                            style: const TextStyle(
                                    color: kPrimaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                              ),
                              title: Text(member['fullName'] ?? 'Unnamed'),
                              subtitle: Text(member['email'] ?? ''),
                              onTap: () => Navigator.of(context).pop(member),
                            );
                          },
                            ),
                          ),
                        ],
                      ),
                    ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class AssignmentDetailsDialog extends StatefulWidget {
  final String memberName;
  final DateTime date;

  const AssignmentDetailsDialog({
    super.key,
    required this.memberName,
    required this.date,
  });

  @override
  State<AssignmentDetailsDialog> createState() => _AssignmentDetailsDialogState();
}

class _AssignmentDetailsDialogState extends State<AssignmentDetailsDialog> {
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Assignment Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
            'Assigning ${widget.memberName}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Date: ${DateFormat('MMMM d, yyyy').format(widget.date)}',
                style: TextStyle(
                  color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              border: OutlineInputBorder(),
              hintText: 'Add any additional details about this assignment',
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_notesController.text.trim()),
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Assign'),
        ),
      ],
    );
  }
}