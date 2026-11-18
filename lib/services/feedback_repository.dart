import 'package:flutter/foundation.dart';

import 'package:capstone_dacula/data/dummy_feedback.dart';
import 'package:capstone_dacula/models/feedback_entry.dart';

/// In-memory store of feedback. Screens listen to it and rebuild on changes.
class FeedbackRepository extends ChangeNotifier {
  FeedbackRepository._() {
    _entries.addAll(dummyFeedback);
  }

  static final FeedbackRepository instance = FeedbackRepository._();

  final List<FeedbackEntry> _entries = [];

  List<FeedbackEntry> forActivity(String activityId) =>
      _entries.where((e) => e.activityId == activityId).toList();

  int countFor(String activityId) => forActivity(activityId).length;

  double averageFor(String activityId) {
    final list = forActivity(activityId);
    if (list.isEmpty) return 0;
    final total = list.fold<int>(0, (sum, e) => sum + e.rating);
    return total / list.length;
  }

  void add(FeedbackEntry entry) {
    _entries.add(entry);
    notifyListeners();
  }
}