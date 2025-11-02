import 'package:flutter/material.dart';
import 'package:youth_center/utils/app_colors.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  final List<Map<String, dynamic>> _achievements = [
    {
      'id': 1,
      'title': 'First Project',
      'description': 'Completed 1 project',
      'icon': Icons.star,
      'iconColor': Colors.amber,
      'unlocked': true,
    },
    {
      'id': 2,
      'title': 'Team Player',
      'description': 'Joined 5 teams',
      'icon': Icons.people,
      'iconColor': const Color(0xFF194CBF),
      'unlocked': true,
    },
    {
      'id': 3,
      'title': 'Top Contributor',
      'description': '50+ feedbacks',
      'icon': Icons.chat_bubble_outline,
      'iconColor': Colors.orange,
      'unlocked': true,
    },
    {
      'id': 4,
      'title': 'Innovator',
      'description': 'Lead a project',
      'icon': Icons.rocket_launch,
      'iconColor': const Color(0xFF194CBF),
      'unlocked': true,
    },
    {
      'id': 5,
      'title': 'Project Pro',
      'description': 'Completed 10 projects',
      'icon': Icons.verified,
      'iconColor': const Color(0xFF194CBF),
      'unlocked': true,
    },
    {
      'id': 6,
      'title': 'Community Pillar',
      'description': 'Joined 1 year ago',
      'icon': Icons.emoji_events,
      'iconColor': const Color(0xFF194CBF),
      'unlocked': true,
    },
    {
      'id': 7,
      'title': 'Mission Completed',
      'description': 'Completed a mission',
      'icon': Icons.flag,
      'iconColor': const Color(0xFF194CBF),
      'unlocked': true,
    },
    {
      'id': 8,
      'title': 'Workshop Attend',
      'description': 'Attended a workshop',
      'icon': Icons.school,
      'iconColor': const Color(0xFF194CBF),
      'unlocked': true,
    },
    {
      'id': 9,
      'title': 'Competition Joined',
      'description': 'Joined a competition',
      'icon': Icons.emoji_events_outlined,
      'iconColor': const Color(0xFF194CBF),
      'unlocked': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF194CBF),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Spacer(),
                  const Text(
                    'My Achievements',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.bolt, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Badges',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Achievements Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 20,
                            childAspectRatio: 0.82,
                          ),
                      itemCount: _achievements.length,
                      itemBuilder: (context, index) {
                        return _buildAchievementBadge(_achievements[index]);
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementBadge(Map<String, dynamic> achievement) {
    final isUnlocked = achievement['unlocked'] == true;
    final iconColor = achievement['iconColor'] as Color;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isUnlocked
                ? iconColor.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isUnlocked
              ? iconColor.withOpacity(0.3)
              : AppColors.grey300.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Badge Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: isUnlocked
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        iconColor,
                        iconColor.withOpacity(0.7),
                      ],
                    )
                  : null,
              color: isUnlocked ? null : AppColors.grey100,
              shape: BoxShape.circle,
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color: iconColor.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              achievement['icon'],
              color: isUnlocked ? Colors.white : AppColors.textDisabled,
              size: 32,
            ),
          ),
          const SizedBox(height: 10),

          // Title
          Flexible(
            child: Text(
              achievement['title'],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isUnlocked
                    ? AppColors.textPrimary
                    : AppColors.textDisabled,
                letterSpacing: 0.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),

          // Description
          Flexible(
            child: Text(
              achievement['description'],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: isUnlocked
                    ? AppColors.textSecondary
                    : AppColors.textDisabled,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
