import 'package:flutter/material.dart';
import 'package:rukuntetangga/widgets/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  List<Map<String, dynamic>> _users = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch users from Firestore
      final QuerySnapshot userSnapshot = await _firestore.collection('users').get();
      
      // Convert to list of users with document IDs
      List<Map<String, dynamic>> usersList = [];
      
      for (var doc in userSnapshot.docs) {
        final userData = doc.data() as Map<String, dynamic>;
        // Add the document ID to the user data
        userData['id'] = doc.id;
        
        // Set default values for missing fields
        userData['role'] = userData['role'] ?? 'User';
        userData['status'] = userData['status'] ?? 'Active';
        userData['createdAt'] = userData['createdAt'] != null 
            ? _formatTimestamp(userData['createdAt'])
            : DateTime.now().toString().split(' ')[0];
        
        usersList.add(userData);
      }
      
      // Sort by fullName
      usersList.sort((a, b) => (a['fullName'] ?? '').compareTo(b['fullName'] ?? ''));
      
      setState(() {
        _users = usersList;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: $e')),
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
  
  // Helper method to format timestamp
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate().toString().split(' ')[0];
    } else {
      return timestamp.toString();
    }
  }

  List<Map<String, dynamic>> get filteredUsers {
    List<Map<String, dynamic>> result = _users;
    
    // Apply search only (filters removed)
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((u) => 
        (u['fullName']?.toLowerCase() ?? '').contains(query) ||
        (u['email']?.toLowerCase() ?? '').contains(query) ||
        (u['username']?.toLowerCase() ?? '').contains(query)
      ).toList();
    }
    
    return result;
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
                  'Manage Users',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'View and manage community users',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          
          // Users list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredUsers.isEmpty
                    ? const Center(child: Text('No users found'))
                    : RefreshIndicator(
                        onRefresh: _loadUsers,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: kPrimaryColor.withAlpha(26),
                                          child: Text(
                                            (user['fullName'] ?? 'U').toString().isNotEmpty ? 
                                            (user['fullName'] as String).substring(0, 1) : 'U',
                                            style: const TextStyle(
                                              color: kPrimaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      user['fullName'] ?? 'Unnamed User',
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8, 
                                                      vertical: 4
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: user['status'] == 'Active'
                                                          ? Colors.green.withAlpha(26)
                                                          : Colors.red.withAlpha(26),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      user['status'] ?? 'Active',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: user['status'] == 'Active'
                                                            ? Colors.green
                                                            : Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (user['username'] != null && user['username'].toString().isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Icon(Icons.alternate_email, 
                                                      size: 16, 
                                                      color: Colors.grey[600]
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      user['username'],
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(Icons.email, 
                                                    size: 16, 
                                                    color: Colors.grey[600]
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    user['email'] ?? 'No Email',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (user['phone'] != null && user['phone'].toString().isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Icon(Icons.phone, 
                                                      size: 16, 
                                                      color: Colors.grey[600]
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      user['phone'],
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (user['address'] != null && user['address'].toString().isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.location_on, 
                                            size: 16, 
                                            color: Colors.grey[600]
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              user['address'],
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8, 
                                                vertical: 4
                                              ),
                                              decoration: BoxDecoration(
                                                color: user['role'] == 'Member'
                                                    ? Colors.purple.withAlpha(26)
                                                    : Colors.blue.withAlpha(26),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                user['role'] ?? 'User',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: user['role'] == 'Member'
                                                      ? Colors.purple
                                                      : Colors.blue,
                                                ),
                                              ),
                                            ),
                                            if (user['createdAt'] != null) ...[
                                              const SizedBox(width: 8),
                                              Text(
                                                'Since ${user['createdAt']}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit, size: 20),
                                              onPressed: () => _editUser(user),
                                              tooltip: 'Edit user',
                                              visualDensity: VisualDensity.compact,
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                user['status'] == 'Active' 
                                                    ? Icons.block 
                                                    : Icons.check_circle_outline,
                                                size: 20,
                                                color: user['status'] == 'Active'
                                                    ? Colors.red
                                                    : Colors.green,
                                              ),
                                              onPressed: () => _toggleUserStatus(user),
                                              tooltip: user['status'] == 'Active'
                                                  ? 'Deactivate user'
                                                  : 'Activate user',
                                              visualDensity: VisualDensity.compact,
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_forever,
                                                size: 20,
                                                color: Colors.red,
                                              ),
                                              onPressed: () => _deleteUser(user),
                                              tooltip: 'Delete user',
                                              visualDensity: VisualDensity.compact,
                                            ),
                                          ],
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewUser,
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
  
  // Method to delete a user
  void _deleteUser(Map<String, dynamic> user) async {
    // Ask for confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${user['fullName']}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        final String userId = user['id'];
        
        // Delete the user document from Firestore
        await _firestore.collection('users').doc(userId).delete();
        
        // Show success message
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Refresh user list
        _loadUsers();
      } catch (e) {
        // Show error message
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _addNewUser() {
    // Implement user creation dialog
    showDialog(
      context: context,
      builder: (context) => const UserFormDialog(
        title: 'Add New User',
      ),
    ).then((result) {
      if (result != null) {
        _loadUsers(); // Refresh user list after adding
      }
    });
  }
  
  void _editUser(Map<String, dynamic> user) {
    // Implement user editing dialog
    showDialog(
      context: context,
      builder: (context) => UserFormDialog(
        title: 'Edit User',
        user: user,
      ),
    ).then((result) {
      if (result != null) {
        _loadUsers(); // Refresh user list after editing
      }
    });
  }
  
  void _toggleUserStatus(Map<String, dynamic> user) async {
    // Toggle the status between Active and Inactive
    final newStatus = user['status'] == 'Active' ? 'Inactive' : 'Active';
    final action = user['status'] == 'Active' ? 'deactivate' : 'activate';
    
    // Ask for confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm ${action.capitalize()}'),
        content: Text('Are you sure you want to $action this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: user['status'] == 'Active' ? Colors.red : Colors.green,
            ),
            child: Text(action.capitalize()),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        // Update status in Firestore
        await _firestore.collection('users').doc(user['id']).update({
          'status': newStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // Show success message
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User ${action}d successfully')),
        );
        
        // Refresh user list
        _loadUsers();
      } catch (e) {
        // Show error message
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

// User form dialog
class UserFormDialog extends StatefulWidget {
  final String title;
  final Map<String, dynamic>? user;
  
  const UserFormDialog({
    super.key,
    required this.title,
    this.user,
  });

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  String _role = 'User';
  String _status = 'Active';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _fullNameController.text = widget.user!['fullName'] ?? '';
      _usernameController.text = widget.user!['username'] ?? '';
      _emailController.text = widget.user!['email'] ?? '';
      _phoneController.text = widget.user!['phone'] ?? '';
      _addressController.text = widget.user!['address'] ?? '';
      _role = widget.user!['role'] ?? 'User';
      _status = widget.user!['status'] ?? 'Active';
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
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
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter username';
                  }
                  if (value.contains(' ')) {
                    return 'Username cannot contain spaces';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: widget.user == null, // Only allow email editing on new users
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: const OutlineInputBorder(),
                  helperText: widget.user != null ? 'Email cannot be changed' : null,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone (optional)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
                      return 'Please enter a valid phone number';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Address (optional)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: ['User', 'Member'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _role = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: ['Active', 'Inactive'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _status = newValue!;
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
          onPressed: _isLoading ? null : _saveUser,
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
              : Text(widget.user == null ? 'Create' : 'Update'),
        ),
      ],
    );
  }

  Future<void> _saveUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final userData = {
          'fullName': _fullNameController.text.trim(),
          'username': _usernameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'role': _role,
          'status': _status,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (widget.user == null) {
          // Create a new user
          
          // First, check if email already exists
          final emailCheck = await _firestore
              .collection('users')
              .where('email', isEqualTo: _emailController.text.trim())
              .get();
          
          if (emailCheck.docs.isNotEmpty) {
            throw 'Email already exists';
          }
          
          // Create Firebase Auth user 
          // In a real app, you might want to send an email verification with temporary password
          // For now, we'll create a user with a default password
          final password = '123456'; // Default password - users should change this
          
          try {
            // Create auth user first
            final userCredential = await _auth.createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: password,
            );
            
            // Add email to user data
            userData['email'] = _emailController.text.trim();
            userData['createdAt'] = FieldValue.serverTimestamp();
            
            // Now create the user document in Firestore with the auth UID
            await _firestore.collection('users').doc(userCredential.user!.uid).set(userData);
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('User created successfully. Default password: $password'),
                backgroundColor: Colors.green,
              ),
            );
          } catch (authError) {
            throw 'Auth error: $authError';
          }
        } else {
          // Update existing user
          await _firestore.collection('users').doc(widget.user!['id']).update(userData);
        }

        if (!mounted) return;
        Navigator.of(context).pop(true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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

// Extension to capitalize first letter
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}