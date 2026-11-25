
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:capstone_dacula/models/feedback_entry.dart';

class FeedbackRepository {
  FeedbackRepository._();

  static final FeedbackRepository instance = FeedbackRepository._();

  final CollectionReference<Map<String, dynamic>> _feedbackCollection =
      FirebaseFirestore.instance.collection('feedback');

  // Get all feedback and listen for database changes.
  Stream<List<FeedbackEntry>> watchAll() {
    return _feedbackCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        return FeedbackEntry(
          id: doc.id,
          activityId: data['activityId'] as String,
          rating: (data['rating'] as num).toInt(),
          comment: data['comment'] as String? ?? '',
          submittedAt: (data['submittedAt'] as Timestamp).toDate(),
          userId: data['userId'] as String?,
        );
      }).toList();
    });
  }

  // Get feedback for one activity.
  Stream<List<FeedbackEntry>> watchForActivity(String activityId) {
    return watchAll().map(
      (entries) =>
          entries.where((entry) => entry.activityId == activityId).toList(),
    );
  }

  // Create: Save feedback with the current anonymous user's ID.
  Future<void> add(FeedbackEntry entry) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not authenticated.');
    }

    await _feedbackCollection.add({
      'activityId': entry.activityId,
      'rating': entry.rating,
      'comment': entry.comment,
      'submittedAt': Timestamp.fromDate(entry.submittedAt),
      'userId': user.uid,
    });
  }

  // Update: Edit an existing feedback document.
  Future<void> update(FeedbackEntry entry) async {
    final id = entry.id;

    if (id == null || id.isEmpty) {
      throw Exception('Feedback document ID is missing.');
    }

    await _feedbackCollection.doc(id).update({
      'activityId': entry.activityId,
      'rating': entry.rating,
      'comment': entry.comment,
    });
  }

  // Delete: Remove an existing feedback document.
  Future<void> delete(FeedbackEntry entry) async {
    final id = entry.id;

    if (id == null || id.isEmpty) {
      throw Exception('Feedback document ID is missing.');
    }

    await _feedbackCollection.doc(id).delete();
  }
}
