import 'package:flutter/material.dart';

import 'package:capstone_dacula/models/activity.dart';
import 'package:capstone_dacula/models/feedback_entry.dart';
import 'package:capstone_dacula/services/feedback_repository.dart';
import 'package:capstone_dacula/widgets/star_rating.dart';

/// The core screen: stars + comment -> submit. Anonymous (no ID collected).
class EvaluationFormScreen extends StatefulWidget {
  const EvaluationFormScreen({super.key, required this.activity});

  final Activity activity;

  @override
  State<EvaluationFormScreen> createState() => _EvaluationFormScreenState();
}

class _EvaluationFormScreenState extends State<EvaluationFormScreen> {
  final _commentController = TextEditingController();
  int _rating = 0;
  bool _showRatingError = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_rating == 0) {
      setState(() => _showRatingError = true);
      return;
    }
    FeedbackRepository.instance.add(
      FeedbackEntry(
        activityId: widget.activity.id,
        rating: _rating,
        comment: _commentController.text.trim(),
        submittedAt: DateTime.now(),
      ),
    );
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      const SnackBar(content: Text('Thanks! Your feedback was submitted.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Evaluation Form')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(widget.activity.title, style: text.titleLarge),
          const SizedBox(height: 4),
          Text('Your response is anonymous.', style: text.bodySmall),
          const SizedBox(height: 24),
          Text('How would you rate this event?', style: text.titleMedium),
          const SizedBox(height: 8),
          Center(
            child: StarRating(
              rating: _rating.toDouble(),
              size: 40,
              onChanged: (value) => setState(() {
                _rating = value;
                _showRatingError = false;
              }),
            ),
          ),
          if (_showRatingError)
            Center(
              child: Text(
                'Please select a rating.',
                style: TextStyle(color: scheme.error),
              ),
            ),
          const SizedBox(height: 24),
          TextField(
            controller: _commentController,
            maxLines: 5,
            maxLength: 300,
            decoration: const InputDecoration(
              labelText: 'Comments (optional)',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _submit, child: const Text('Submit')),
        ],
      ),
    );
  }
}