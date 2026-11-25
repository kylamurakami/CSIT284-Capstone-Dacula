


class Activity {
  const Activity({
    required this.id,
    required this.title,
    required this.venue,
    required this.durationLabel,
    required this.imageUrl,
    required this.categories,
    required this.description,
    required this.skillLevel,
  });

  final String id;
  final String title;
  final String venue;
  final String durationLabel;
  final String imageUrl;
  final List<String> categories;
  final String description;
  final ActivitySkillLevel skillLevel;
}

enum ActivitySkillLevel {
  beginner('Beginner'),
  intermediate('Intermediate'),
  advanced('Advanced');

  const ActivitySkillLevel(this.label);

  final String label;
}
