
class FeedbackEntry {
  const FeedbackEntry({
    required this.activityId,
    required this.rating,
    this.comment = '',
    required this.submittedAt,
  });

  final String activityId;
  final int rating;
  final String comment;
  final DateTime submittedAt;
}
