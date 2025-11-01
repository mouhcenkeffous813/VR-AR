import 'package:flutter/material.dart';
import 'package:youth_center/utils/app_colors.dart';

class OpportunityDetailPage extends StatelessWidget {
  final Map<String, dynamic> opportunity;

  const OpportunityDetailPage({super.key, required this.opportunity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      // Bookmark functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Saved to bookmarks')),
                      );
                    },
                    icon: const Icon(
                      Icons.bookmark_border,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo and Company
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color:
                                opportunity['logoColor'] ?? AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                            image:
                                opportunity['image'] != null
                                    ? DecorationImage(
                                      image: AssetImage(opportunity['image']),
                                      fit: BoxFit.cover,
                                    )
                                    : null,
                          ),
                          child:
                              opportunity['image'] == null
                                  ? Center(
                                    child: Text(
                                      opportunity['company']
                                          .toString()
                                          .substring(0, 2)
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                      ),
                                    ),
                                  )
                                  : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                opportunity['company'] ?? '',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    opportunity['location'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Job Title
                    Text(
                      opportunity['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Tags
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          (opportunity['tags'] as List<dynamic>?)
                              ?.map(
                                (tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight.withOpacity(
                                      0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    tag.toString(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )
                              .toList() ??
                          [],
                    ),

                    const SizedBox(height: 32),

                    // About the Role Section
                    const Text(
                      'About the Role',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getRoleDescription(opportunity['type'] ?? ''),
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Responsibilities Section
                    const Text(
                      'Key Responsibilities',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(
                      4,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 8, right: 12),
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                _getResponsibility(index, opportunity),
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.6,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Requirements Section
                    const Text(
                      'Requirements',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(
                      3,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 8, right: 12),
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                _getRequirement(index, opportunity),
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.6,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Apply Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _showApplyDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Apply Now',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRoleDescription(String type) {
    switch (type) {
      case 'Internships':
        return 'Join our team as an intern and gain valuable hands-on experience in a real-world professional environment. This internship opportunity will help you develop essential skills and build your career foundation.';
      case 'Volunteering':
        return 'Make a meaningful impact by volunteering with us. This is a great opportunity to give back to the community while developing new skills and expanding your network.';
      case 'Projects':
        return 'Collaborate with our team on exciting projects that will challenge you and help you grow. This project-based opportunity is perfect for building your portfolio and gaining practical experience.';
      case 'Exchange Programs':
        return 'Join our exchange program to experience new cultures, learn from international perspectives, and expand your academic and professional horizons.';
      default:
        return 'This is an excellent opportunity to grow professionally and make a meaningful contribution to our organization.';
    }
  }

  String _getResponsibility(int index, Map<String, dynamic> opportunity) {
    final type = opportunity['type'] ?? '';
    final responsibilities = [
      'Collaborate with team members to achieve project goals',
      'Complete assigned tasks with attention to detail and quality',
      'Participate in meetings and contribute innovative ideas',
      'Maintain professional communication with stakeholders',
    ];

    if (type == 'Internships') {
      return [
        'Assist senior team members with daily tasks and projects',
        'Learn and apply industry best practices',
        'Participate in training sessions and workshops',
        'Complete assigned projects within deadlines',
      ][index];
    } else if (type == 'Volunteering') {
      return [
        'Support community initiatives and events',
        'Engage with community members and stakeholders',
        'Help organize and coordinate activities',
        'Document and report on volunteer activities',
      ][index];
    }
    return responsibilities[index % responsibilities.length];
  }

  String _getRequirement(int index, Map<String, dynamic> opportunity) {
    final requirements = [
      'Strong communication and teamwork skills',
      'Ability to work independently and manage time effectively',
      'Willingness to learn and adapt to new challenges',
    ];
    return requirements[index % requirements.length];
  }

  void _showApplyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Apply for this opportunity'),
            content: const Text(
              'Your application will be submitted. Make sure your profile is complete and up to date.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Application submitted for ${opportunity['title']}!',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Submit Application'),
              ),
            ],
          ),
    );
  }
}
