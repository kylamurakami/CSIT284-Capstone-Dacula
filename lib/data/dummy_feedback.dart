import 'package:capstone_dacula/models/feedback_entry.dart';

final List<FeedbackEntry> dummyFeedback = [
  FeedbackEntry(
    activityId: 'a1',
    rating: 5,
    comment: 'Well organized and super fun!',
    submittedAt: DateTime(2026, 11, 1),
  ),
  FeedbackEntry(
    activityId: 'a1',
    rating: 4,
    comment: 'Great games, but it started late.',
    submittedAt: DateTime(2026, 11, 1),
  ),
  FeedbackEntry(
    activityId: 'a2',
    rating: 5,
    comment: 'Learned a lot and the mentors were helpful.',
    submittedAt: DateTime(2026, 11, 3),
  ),
  FeedbackEntry(
    activityId: 'a3',
    rating: 4,
    comment: '',
    submittedAt: DateTime(2026, 11, 5),
  ),
];