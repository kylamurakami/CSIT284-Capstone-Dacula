import 'package:flutter/material.dart';

import 'package:capstone_dacula/data/dummy_data.dart';
import 'package:capstone_dacula/models/activity.dart';
import 'package:capstone_dacula/screens/evaluation_form_screen.dart';
import 'package:capstone_dacula/services/feedback_repository.dart';
import 'package:capstone_dacula/widgets/activity_image.dart';
import 'package:capstone_dacula/widgets/star_rating.dart';

/// Event info + average rating + raw comments (the "no admin dashboard" view).
class ActivityDetailScreen extends StatelessWidget {
  const ActivityDetailScreen({super.key, required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final repo = FeedbackRepository.instance;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(activity.title, overflow: TextOverflow.ellipsis)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EvaluationFormScreen(activity: activity),
          ),
        ),
        icon: const Icon(Icons.rate_review_outlined),
        label: const Text('Rate this event'),
      ),
      body: ListenableBuilder(
        listenable: repo,
        builder: (context, _) {
          final average = repo.averageFor(activity.id);
          final entries = repo.forActivity(activity.id);

          return ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              ActivityImage(url: activity.imageUrl, height: 200),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final id in activity.categories)
                          Chip(
                            label: Text(_categoryTitle(id)),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(activity.description, style: text.bodyLarge),
                    const SizedBox(height: 8),
                    Text(
                      '${activity.venue} • ${activity.durationLabel} • '
                      '${activity.skillLevel.label}',
                      style: text.bodySmall,
                    ),
                    const Divider(height: 32),
                    Text('Average rating', style: text.titleMedium),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          entries.isEmpty ? '–' : average.toStringAsFixed(1),
                          style: text.displaySmall,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StarRating(rating: average, size: 24),
                            Text('${entries.length} response'
                                '${entries.length == 1 ? '' : 's'}'),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Text('Comments', style: text.titleMedium),
                  ],
                ),
              ),
              if (entries.every((e) => e.comment.isEmpty))
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('No comments yet.'),
                ),
              for (final e in entries.where((e) => e.comment.isNotEmpty))
                ListTile(
                  title: Text(e.comment),
                  subtitle: StarRating(rating: e.rating.toDouble(), size: 14),
                ),
            ],
          );
        },
      ),
    );
  }

  String _categoryTitle(String id) =>
      availableCategories.firstWhere((c) => c.id == id).title;
}