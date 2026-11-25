
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:capstone_dacula/data/dummy_data.dart';
import 'package:capstone_dacula/models/activity.dart';
import 'package:capstone_dacula/models/feedback_entry.dart';
import 'package:capstone_dacula/screens/evaluation_form_screen.dart';
import 'package:capstone_dacula/services/feedback_repository.dart';
import 'package:capstone_dacula/widgets/activity_image.dart';
import 'package:capstone_dacula/widgets/star_rating.dart';

class ActivityDetailScreen extends StatelessWidget {
  const ActivityDetailScreen({super.key, required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final repo = FeedbackRepository.instance;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(activity.title, overflow: TextOverflow.ellipsis),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EvaluationFormScreen(activity: activity),
          ),
        ),
        icon: const Icon(Icons.rate_review_outlined),
        label: const Text('Rate this event'),
      ),
      body: StreamBuilder<List<FeedbackEntry>>(
        stream: repo.watchForActivity(activity.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Unable to load feedback.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final entries = snapshot.data ?? [];

          final total = entries.fold<int>(
            0,
            (sum, entry) => sum + entry.rating,
          );

          final average =
              entries.isEmpty ? 0.0 : total / entries.length;

          return ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              ActivityImage(
                url: activity.imageUrl,
                height: 200,
              ),
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
                    Text(
                      activity.description,
                      style: text.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${activity.venue} • ${activity.durationLabel} • '
                      '${activity.skillLevel.label}',
                      style: text.bodySmall,
                    ),
                    const Divider(height: 32),
                    Text(
                      'Average rating',
                      style: text.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          entries.isEmpty
                              ? '–'
                              : average.toStringAsFixed(1),
                          style: text.displaySmall,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StarRating(
                              rating: average,
                              size: 24,
                            ),
                            Text(
                              '${entries.length} response'
                              '${entries.length == 1 ? '' : 's'}',
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Text(
                      'Comments',
                      style: text.titleMedium,
                    ),
                  ],
                ),
              ),
              if (entries.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('No feedback yet.'),
                ),
              for (final entry in entries)
                _FeedbackTile(
                  entry: entry,
                  onEdit: () => _editFeedback(context, entry),
                  onDelete: () => _deleteFeedback(context, entry),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _editFeedback(
    BuildContext context,
    FeedbackEntry entry,
  ) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (_) => _EditFeedbackDialog(entry: entry),
    );

    if (!context.mounted) return;

    if (updated == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feedback updated.'),
        ),
      );
    }
  }

  Future<void> _deleteFeedback(
    BuildContext context,
    FeedbackEntry entry,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete feedback?'),
        content: const Text(
          'Are you sure you want to delete this feedback?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await FeedbackRepository.instance.delete(entry);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feedback deleted.'),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to delete feedback.'),
        ),
      );
    }
  }

  String _categoryTitle(String id) =>
      availableCategories.firstWhere((c) => c.id == id).title;
}

// Separate stateful dialog to manage the text controller safely.
class _EditFeedbackDialog extends StatefulWidget {
  const _EditFeedbackDialog({required this.entry});

  final FeedbackEntry entry;

  @override
  State<_EditFeedbackDialog> createState() =>
      _EditFeedbackDialogState();
}

class _EditFeedbackDialogState extends State<_EditFeedbackDialog> {
  late final TextEditingController _commentController;
  late int _rating;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _commentController = TextEditingController(
      text: widget.entry.comment,
    );

    _rating = widget.entry.rating;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      await FeedbackRepository.instance.update(
        FeedbackEntry(
          id: widget.entry.id,
          activityId: widget.entry.activityId,
          rating: _rating,
          comment: _commentController.text.trim(),
          submittedAt: widget.entry.submittedAt,
          userId: widget.entry.userId,
        ),
      );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to update feedback.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit your feedback'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StarRating(
              rating: _rating.toDouble(),
              size: 36,
              onChanged: (value) {
                setState(() => _rating = value);
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _commentController,
              maxLines: 4,
              maxLength: 300,
              decoration: const InputDecoration(
                labelText: 'Comments (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}

class _FeedbackTile extends StatelessWidget {
  const _FeedbackTile({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  final FeedbackEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    final isOwner =
        currentUserId != null && entry.userId == currentUserId;

    return ListTile(
      title: Text(
        entry.comment.isEmpty
            ? 'No comment provided.'
            : entry.comment,
      ),
      subtitle: StarRating(
        rating: entry.rating.toDouble(),
        size: 14,
      ),
      trailing: isOwner
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Edit feedback',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'Delete feedback',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            )
          : null,
    );
  }
}
