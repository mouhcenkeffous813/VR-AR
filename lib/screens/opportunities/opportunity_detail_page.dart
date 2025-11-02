import 'package:flutter/material.dart';
import 'package:youth_center/utils/app_colors.dart';

class OpportunityDetailPage extends StatelessWidget {
  final Map<String, dynamic> opportunity;

  const OpportunityDetailPage({super.key, required this.opportunity});

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Internships':
        return const Color(0xFF1976D2);
      case 'Exchange Programs':
        return const Color(0xFF7B1FA2);
      case 'Volunteering':
        return const Color(0xFF388E3C);
      case 'Projects':
        return const Color(0xFFF57C00);
      default:
        return const Color(0xFF194CBF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(opportunity['type'] ?? '');
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Custom App Bar with gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              constraints: const BoxConstraints(
                maxHeight: 250,
                minHeight: 220,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    typeColor,
                    typeColor.withOpacity(0.7),
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Saved to bookmarks'),
                                    backgroundColor: Color(0xFF194CBF),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.bookmark_border_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Company Logo
                      Container(
                        constraints: const BoxConstraints(
                          maxWidth: 85,
                          maxHeight: 85,
                        ),
                        width: 85,
                        height: 85,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          image: opportunity['image'] != null
                              ? DecorationImage(
                                  image: AssetImage(opportunity['image']),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: opportunity['image'] == null
                            ? Center(
                                child: Text(
                                  opportunity['company']
                                      .toString()
                                      .substring(0, 2)
                                      .toUpperCase(),
                                  style: TextStyle(
                                    color: typeColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 26,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          Positioned.fill(
            top: 220,
            child: DraggableScrollableSheet(
              initialChildSize: 0.68,
              minChildSize: 0.68,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 120),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      // Company and Title Section
                      Center(
                        child: Container(
                          width: 50,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          opportunity['company'] ?? '',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: typeColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          opportunity['title'] ?? '',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              opportunity['location'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Tags
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children:
                            (opportunity['tags'] as List<dynamic>?)
                                ?.map(
                                  (tag) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          typeColor.withOpacity(0.15),
                                          typeColor.withOpacity(0.08),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: typeColor.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      tag.toString(),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: typeColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                )
                                .toList() ??
                            [],
                      ),

                      const SizedBox(height: 20),

                      // About the Role Section
                      _buildSectionCard(
                        icon: Icons.info_outline_rounded,
                        title: 'About the Role',
                        child: Text(
                          _getRoleDescription(opportunity['type'] ?? ''),
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        color: typeColor,
                      ),

                      const SizedBox(height: 14),

                      // Key Responsibilities Section
                      _buildSectionCard(
                        icon: Icons.checklist_rounded,
                        title: 'Key Responsibilities',
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            4,
                            (index) => Padding(
                              padding: EdgeInsets.only(
                                bottom: index < 3 ? 12 : 0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 5, right: 12),
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: typeColor.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.check_rounded,
                                      size: 12,
                                      color: typeColor,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      _getResponsibility(index, opportunity),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.5,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        color: typeColor,
                      ),

                      const SizedBox(height: 14),

                      // Requirements Section
                      _buildSectionCard(
                        icon: Icons.verified_user_rounded,
                        title: 'Requirements',
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            3,
                            (index) => Padding(
                              padding: EdgeInsets.only(
                                bottom: index < 2 ? 12 : 0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 5, right: 12),
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: typeColor.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.star_rounded,
                                      size: 12,
                                      color: typeColor,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      _getRequirement(index, opportunity),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.5,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        color: typeColor,
                      ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Apply Button (Fixed at bottom)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        typeColor,
                        typeColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: typeColor.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      _showApplyDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send_rounded, color: Colors.white, size: 22),
                        SizedBox(width: 12),
                        Text(
                          'Apply Now',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
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
    final typeColor = _getTypeColor(opportunity['type'] ?? '');
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.work_outline_rounded,
                  color: typeColor,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Apply for this Opportunity',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Your application will be submitted. Make sure your profile is complete and up to date.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1.5,
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            typeColor,
                            typeColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: typeColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Application submitted for ${opportunity['title']}!',
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Submit',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
