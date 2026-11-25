
import 'package:capstone_dacula/models/activity.dart';
import 'package:capstone_dacula/models/activity_category.dart';

const List<ActivityCategory> availableCategories = [
  ActivityCategory(id: 'academic', title: 'Academic'),
  ActivityCategory(id: 'sports', title: 'Sports'),
  ActivityCategory(id: 'social', title: 'Social'),
  ActivityCategory(id: 'technology', title: 'Technology'),
];

const List<Activity> dummyActivities = [
  Activity(
    id: 'a1',
    title: 'Campus Sports Festival',
    venue: 'University Gymnasium',
    durationLabel: '1 day',
    imageUrl: 'https://picsum.photos/800/400?random=1',
    categories: ['sports', 'social'],
    description: 'A campus event featuring sports competitions and activities.',
    skillLevel: ActivitySkillLevel.beginner,
  ),
  Activity(
    id: 'a2',
    title: 'Technology Workshop',
    venue: 'IT Building',
    durationLabel: '3 hours',
    imageUrl: 'https://picsum.photos/800/400?random=2',
    categories: ['academic', 'technology'],
    description: 'A learning workshop where students explore technology topics.',
    skillLevel: ActivitySkillLevel.intermediate,
  ),
  Activity(
    id: 'a3',
    title: 'Student Gathering',
    venue: 'University Activity Center',
    durationLabel: '4 hours',
    imageUrl: 'https://picsum.photos/800/400?random=3',
    categories: ['social'],
    description: 'A gathering where students can connect and participate in activities.',
    skillLevel: ActivitySkillLevel.beginner,
  ),
];
