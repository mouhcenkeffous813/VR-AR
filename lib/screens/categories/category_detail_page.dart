import 'package:flutter/material.dart';
import 'package:youth_center/utils/app_colors.dart';
import 'package:intl/intl.dart';

class CategoryDetailPage extends StatelessWidget {
  final String categoryName;
  final IconData categoryIcon;
  final bool allowEnrollment;

  const CategoryDetailPage({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
    this.allowEnrollment = true,
  });

  List<Map<String, dynamic>> _getActivities() {
    // Generate activities based on category name
    final activities = <Map<String, dynamic>>[];

    switch (categoryName) {
      case 'Sport Activities':
        activities.addAll([
          {
            'type': 'Event',
            'title': 'Basketball Tournament',
            'description': 'Join the annual youth basketball championship',
            'date': DateTime.now().add(const Duration(days: 5)),
            'time': '10:00',
            'color': AppColors.primary,
          },
          {
            'type': 'Workshop',
            'title': 'Fitness Training Session',
            'description':
                'Learn proper exercise techniques and workout routines',
            'date': DateTime.now().add(const Duration(days: 3)),
            'time': '17:00',
            'color': AppColors.success,
          },
          {
            'type': 'Event',
            'title': 'Soccer Match',
            'description': 'Friendly match between teams',
            'date': DateTime.now().add(const Duration(days: 8)),
            'time': '16:00',
            'color': AppColors.warning,
          },
          {
            'type': 'Lecture',
            'title': 'Sports Nutrition Seminar',
            'description': 'Learn about proper nutrition for athletes',
            'date': DateTime.now().add(const Duration(days: 12)),
            'time': '14:00',
            'color': AppColors.info,
          },
        ]);
        break;
      case 'Digital Design Lab':
        activities.addAll([
          {
            'type': 'Workshop',
            'title': 'UI/UX Design Basics',
            'description':
                'Introduction to user interface and experience design',
            'date': DateTime.now().add(const Duration(days: 4)),
            'time': '13:00',
            'color': AppColors.secondary,
          },
          {
            'type': 'Workshop',
            'title': 'Photoshop Masterclass',
            'description':
                'Advanced photo editing and graphic design techniques',
            'date': DateTime.now().add(const Duration(days: 7)),
            'time': '10:00',
            'color': AppColors.primary,
          },
          {
            'type': 'Event',
            'title': 'Design Portfolio Review',
            'description': 'Get feedback on your design portfolio from experts',
            'date': DateTime.now().add(const Duration(days: 11)),
            'time': '15:00',
            'color': AppColors.success,
          },
          {
            'type': 'Lecture',
            'title': 'Typography Fundamentals',
            'description': 'Understanding fonts and typography in design',
            'date': DateTime.now().add(const Duration(days: 6)),
            'time': '14:00',
            'color': AppColors.warning,
          },
        ]);
        break;
      case 'Robotics Garage':
        activities.addAll([
          {
            'type': 'Workshop',
            'title': 'Arduino Programming',
            'description': 'Learn to program Arduino microcontrollers',
            'date': DateTime.now().add(const Duration(days: 5)),
            'time': '10:00',
            'color': AppColors.primary,
          },
          {
            'type': 'Event',
            'title': 'Robot Building Competition',
            'description': 'Build and compete with your own robot',
            'date': DateTime.now().add(const Duration(days: 10)),
            'time': '09:00',
            'color': AppColors.success,
          },
          {
            'type': 'Workshop',
            'title': '3D Printing Basics',
            'description': 'Introduction to 3D printing and modeling',
            'date': DateTime.now().add(const Duration(days: 3)),
            'time': '14:00',
            'color': AppColors.secondary,
          },
          {
            'type': 'Lecture',
            'title': 'AI in Robotics',
            'description': 'Understanding artificial intelligence in robotics',
            'date': DateTime.now().add(const Duration(days: 9)),
            'time': '11:00',
            'color': AppColors.info,
          },
        ]);
        break;
      case 'Dev Room':
        activities.addAll([
          {
            'type': 'Workshop',
            'title': 'Flutter Development Bootcamp',
            'description': 'Learn mobile app development with Flutter',
            'date': DateTime.now().add(const Duration(days: 4)),
            'time': '09:00',
            'color': AppColors.primary,
          },
          {
            'type': 'Workshop',
            'title': 'Web Development with React',
            'description': 'Build modern web applications',
            'date': DateTime.now().add(const Duration(days: 7)),
            'time': '13:00',
            'color': AppColors.secondary,
          },
          {
            'type': 'Event',
            'title': 'Hackathon Challenge',
            'description': '24-hour coding competition',
            'date': DateTime.now().add(const Duration(days: 14)),
            'time': '08:00',
            'color': AppColors.success,
          },
          {
            'type': 'Lecture',
            'title': 'Git & Version Control',
            'description': 'Master version control with Git and GitHub',
            'date': DateTime.now().add(const Duration(days: 6)),
            'time': '15:00',
            'color': AppColors.warning,
          },
        ]);
        break;
      case 'Innovation Space':
        activities.addAll([
          {
            'type': 'Workshop',
            'title': 'Design Thinking Workshop',
            'description': 'Learn creative problem-solving methodologies',
            'date': DateTime.now().add(const Duration(days: 5)),
            'time': '10:00',
            'color': AppColors.primary,
          },
          {
            'type': 'Event',
            'title': 'Innovation Pitch Day',
            'description': 'Present your innovative ideas to a panel',
            'date': DateTime.now().add(const Duration(days: 12)),
            'time': '14:00',
            'color': AppColors.success,
          },
          {
            'type': 'Lecture',
            'title': 'Entrepreneurship Fundamentals',
            'description': 'Introduction to starting your own business',
            'date': DateTime.now().add(const Duration(days: 8)),
            'time': '11:00',
            'color': AppColors.secondary,
          },
          {
            'type': 'Workshop',
            'title': 'Prototyping Workshop',
            'description': 'Build prototypes for your ideas',
            'date': DateTime.now().add(const Duration(days: 3)),
            'time': '13:00',
            'color': AppColors.warning,
          },
        ]);
        break;
      case 'Startup Corner':
        activities.addAll([
          {
            'type': 'Event',
            'title': 'Startup Networking Event',
            'description': 'Connect with entrepreneurs and investors',
            'date': DateTime.now().add(const Duration(days: 6)),
            'time': '18:00',
            'color': AppColors.primary,
          },
          {
            'type': 'Lecture',
            'title': 'Business Model Canvas',
            'description': 'Learn to design your business model',
            'date': DateTime.now().add(const Duration(days: 4)),
            'time': '14:00',
            'color': AppColors.secondary,
          },
          {
            'type': 'Workshop',
            'title': 'Marketing for Startups',
            'description': 'Effective marketing strategies for new businesses',
            'date': DateTime.now().add(const Duration(days: 9)),
            'time': '10:00',
            'color': AppColors.success,
          },
          {
            'type': 'Event',
            'title': 'Investor Pitch Practice',
            'description': 'Practice your pitch in front of mentors',
            'date': DateTime.now().add(const Duration(days: 11)),
            'time': '15:00',
            'color': AppColors.warning,
          },
        ]);
        break;
      case 'Library':
        activities.addAll([
          {
            'type': 'Event',
            'title': 'Book Reading Session',
            'description': 'Group reading and discussion of selected books',
            'date': DateTime.now().add(const Duration(days: 5)),
            'time': '16:00',
            'color': AppColors.primary,
          },
          {
            'type': 'Workshop',
            'title': 'Research Skills Workshop',
            'description': 'Learn effective research and citation methods',
            'date': DateTime.now().add(const Duration(days: 7)),
            'time': '13:00',
            'color': AppColors.secondary,
          },
          {
            'type': 'Lecture',
            'title': 'Academic Writing Seminar',
            'description': 'Improve your academic and professional writing',
            'date': DateTime.now().add(const Duration(days: 4)),
            'time': '11:00',
            'color': AppColors.success,
          },
          {
            'type': 'Event',
            'title': 'Author Meet & Greet',
            'description': 'Meet local authors and discuss their works',
            'date': DateTime.now().add(const Duration(days: 10)),
            'time': '15:00',
            'color': AppColors.warning,
          },
        ]);
        break;
      case 'Creative Media':
        activities.addAll([
          {
            'type': 'Workshop',
            'title': 'Video Editing Masterclass',
            'description': 'Learn professional video editing techniques',
            'date': DateTime.now().add(const Duration(days: 6)),
            'time': '10:00',
            'color': AppColors.primary,
          },
          {
            'type': 'Workshop',
            'title': 'Photography Basics',
            'description': 'Introduction to photography and composition',
            'date': DateTime.now().add(const Duration(days: 3)),
            'time': '14:00',
            'color': AppColors.secondary,
          },
          {
            'type': 'Event',
            'title': 'Short Film Festival',
            'description': 'Showcase and watch short films by youth creators',
            'date': DateTime.now().add(const Duration(days: 13)),
            'time': '18:00',
            'color': AppColors.success,
          },
          {
            'type': 'Lecture',
            'title': 'Digital Storytelling',
            'description': 'Learn to tell compelling stories through media',
            'date': DateTime.now().add(const Duration(days: 8)),
            'time': '13:00',
            'color': AppColors.warning,
          },
        ]);
        break;
      default:
        activities.addAll([
          {
            'type': 'Workshop',
            'title': 'Introduction Workshop',
            'description': 'Learn the basics of this category',
            'date': DateTime.now().add(const Duration(days: 5)),
            'time': '10:00',
            'color': AppColors.primary,
          },
          {
            'type': 'Event',
            'title': 'Community Event',
            'description': 'Join us for an exciting community event',
            'date': DateTime.now().add(const Duration(days: 7)),
            'time': '14:00',
            'color': AppColors.success,
          },
          {
            'type': 'Lecture',
            'title': 'Expert Talk',
            'description': 'Learn from industry experts',
            'date': DateTime.now().add(const Duration(days: 10)),
            'time': '11:00',
            'color': AppColors.secondary,
          },
        ]);
    }

    return activities;
  }

  Widget _buildActivityCard({
    required String type,
    required String title,
    required String description,
    required DateTime date,
    required String time,
    required Color color,
    required bool allowEnrollment,
  }) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final formattedDate = dateFormat.format(date);

    IconData typeIcon;
    switch (type.toLowerCase()) {
      case 'workshop':
        typeIcon = Icons.build_outlined;
        break;
      case 'event':
        typeIcon = Icons.event_outlined;
        break;
      case 'lecture':
        typeIcon = Icons.school_outlined;
        break;
      default:
        typeIcon = Icons.calendar_today_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDefault, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(typeIcon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (allowEnrollment) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Builder(
                builder:
                    (context) => ElevatedButton(
                      onPressed: () {
                        // TODO: Handle enrollment (e.g., save to Firebase)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Enrolled in $title'),
                            backgroundColor: AppColors.success,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Enroll',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activities = _getActivities();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          categoryName,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      categoryIcon,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      categoryName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Activities Section
              const Text(
                'Upcoming Activities',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              // Activities List
              ...activities.map(
                (activity) => _buildActivityCard(
                  type: activity['type'] as String,
                  title: activity['title'] as String,
                  description: activity['description'] as String,
                  date: activity['date'] as DateTime,
                  time: activity['time'] as String,
                  color: activity['color'] as Color,
                  allowEnrollment: allowEnrollment,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
