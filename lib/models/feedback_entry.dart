
class FeedbackEntry {
  const FeedbackEntry({
    this.id,
    required this.activityId,
    required this.rating,
    this.comment = '',
    required this.submittedAt,
    this.userId,
  });

  final String? id;
  final String activityId;
  final int rating;
  final String comment;
  final DateTime submittedAt;
  final String? userId;
}
