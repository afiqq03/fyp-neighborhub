import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger('UserService');
  
  // Lazy loaded initialization
  UserService() {
    // Initialize anything specific to user service if needed
  }
  
  // Get basic user info
  Future<Map<String, dynamic>?> getCurrentUserInfo() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;
      
      return doc.data();
    } catch (e) {
      _logger.warning('Error getting user info', e);
      return null;
    }
  }
  
  // Get count of active users
  Future<int> getActiveUsersCount() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('status', isEqualTo: 'Active')
          .count()
          .get();
      
      return snapshot.count ?? 0;
    } catch (e) {
      _logger.warning('Error getting active users count', e);
      return 0;
    }
  }
}