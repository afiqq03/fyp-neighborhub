import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user role
  Future<String> getUserRole() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return 'user';

      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return userData['role'] ?? 'user'; // Default to user if role not set
      }
      return 'user';
    } catch (e) {
      print('Error getting user role: $e');
      return 'user';
    }
  }

  // Check if user is member
  Future<bool> isMember() async {
    final role = await getUserRole();
    return role == 'member';
  }

  // Check if user can edit announcements
  Future<bool> canEditAnnouncements() async {
    final role = await getUserRole();
    return role == 'member'; // Only member can edit announcements
  }

  // Check if user can manage users
  Future<bool> canManageUsers() async {
    final role = await getUserRole();
    return role == 'member'; // Only member can manage users (view only)
  }

  // Check if user can edit timetable
  Future<bool> canEditTimetable() async {
    final role = await getUserRole();
    return role == 'member'; // Only member can edit timetable (view only)
  }

  // Check if user can manage emergencies
  Future<bool> canManageEmergencies() async {
    final role = await getUserRole();
    return role == 'member'; // Only member can manage emergencies
  }

  // Check if user can view a specific page
  Future<bool> canViewPage(String pageName) async {
    final role = await getUserRole();
    
    switch (pageName) {
      case 'announcements':
        return true; // Both can view
      case 'users':
        return true; // Both can view, but only member can edit
      case 'timetable':
        return true; // Both can view, but only member can edit
      case 'emergencies':
        return true; // Both can view and manage
      default:
        return true; // Default to allowing view access
    }
  }
} 