
import 'package:flutter/material.dart';

import 'package:capstone_dacula/data/dummy_data.dart';
import 'package:capstone_dacula/models/activity.dart';
import 'package:capstone_dacula/models/feedback_entry.dart';
import 'package:capstone_dacula/screens/activity_detail_screen.dart';
import 'package:capstone_dacula/services/feedback_repository.dart';
import 'package:capstone_dacula/widgets/activity_image.dart';
import 'package:capstone_dacula/widgets/star_rating.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = FeedbackRepository.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Rate an Event')),
      body: StreamBuilder<List<FeedbackEntry>>(
        stream: repo.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Unable to load feedback.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final entries = snapshot.data ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: dummyActivities.length,
            itemBuilder: (context, i) {
              final activity = dummyActivities[i];
              final activityEntries = entries
                  .where((entry) => entry.activityId == activity.id)
                  .toList();

              final count = activityEntries.length;
              final average = count == 0
                  ? 0.0
                  : activityEntries.fold<int>(
                        0,
                        (sum, entry) => sum + entry.rating,
                      ) /
                      count;

              return _ActivityCard(
                activity: activity,
                average: average,
                count: count,
              );
            },
          );
        },
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.activity,
    required this.average,
    required this.count,
  });

  final Activity activity;
  final double average;
  final int count;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ActivityDetailScreen(activity: activity),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ActivityImage(url: activity.imageUrl),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(activity.title, style: text.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    '${activity.venue} • ${activity.durationLabel}',
                    style: text.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      StarRating(rating: average, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        count == 0
                            ? 'No ratings yet'
                            : '${average.toStringAsFixed(1)} ($count)',
                        style: text.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
