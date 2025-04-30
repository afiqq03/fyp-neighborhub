import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart';

class NotificationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger('NotificationService');
  
  NotificationService() {
    // Initialize notification-specific features when needed
  }
  
  // Get number of unread notifications
  Future<int> getUnreadCount() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return 0;
      
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .count()
          .get();
      
      return snapshot.count ?? 0;
    } catch (e) {
      _logger.warning('Error getting notification count', e);
      return 0;
    }
  }
  
  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;
      
      // Get unread notifications
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .get();
      
      // Create a batch write to update them all efficiently
      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'read': true});
      }
      
      // Commit the batch
      await batch.commit();
      _logger.info('Marked ${snapshot.docs.length} notifications as read');
    } catch (e) {
      _logger.warning('Error marking notifications as read', e);
    }
  }
}