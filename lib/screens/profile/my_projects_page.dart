import 'package:flutter/material.dart';
import 'package:youth_center/utils/app_colors.dart';

class MyProjectsPage extends StatefulWidget {
  const MyProjectsPage({super.key});

  @override
  State<MyProjectsPage> createState() => _MyProjectsPageState();
}

class _MyProjectsPageState extends State<MyProjectsPage> {
  final List<Map<String, dynamic>> _projects = [
    {
      'id': 1,
      'title': 'Fintech App Redesign',
      'description':
          'Revamping the user interface for a local mobile banking application.',
      'teamMembers': 4,
      'status': 'In Progress',
      'statusColor': const Color(0xFF194CBF),
      'icon': Icons.account_balance,
    },
    {
      'id': 2,
      'title': 'LocalArtisan Marketplace',
      'description':
          'A platform connecting local Algerian artisans with a global audience.',
      'teamMembers': 8,
      'status': 'Completed',
      'statusColor': const Color(0xFF194CBF),
      'icon': Icons.store,
    },
    {
      'id': 3,
      'title': 'Eco-Tourism Platform',
      'description':
          'Discover and book eco-friendly tours and stays across Algeria\'s national parks.',
      'teamMembers': 2,
      'status': 'Seeking Roles',
      'statusColor': AppColors.warning,
      'icon': Icons.nature,
    },
    {
      'id': 4,
      'title': 'Tassili EdTech Initiative',
      'description':
          'Developing interactive learning modules for primary school students.',
      'teamMembers': 6,
      'status': 'In Progress',
      'statusColor': const Color(0xFF194CBF),
      'icon': Icons.school,
    },
    {
      'id': 5,
      'title': 'Sahara Logistics',
      'description':
          'An app to optimize and track last-mile delivery in southern Algeria.',
      'teamMembers': 5,
      'status': 'Archived',
      'statusColor': AppColors.textSecondary,
      'icon': Icons.local_shipping,
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
                    'My Projects',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        _showAddProjectDialog(context);
                      },
                      icon: const Icon(
                        Icons.add,
                        color: Color(0xFF194CBF),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Projects List
            Expanded(
              child:
                  _projects.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_outlined,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No projects yet',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _projects.length,
                        itemBuilder: (context, index) {
                          return _buildProjectCard(_projects[index]);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF61A1FF).withOpacity(0.2),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              project['icon'],
              color: const Color(0xFF194CBF),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  project['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  project['description'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),

                // Team Members and Status
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${project['teamMembers']} Team Members',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    // Status Tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (project['statusColor'] as Color).withOpacity(
                          0.1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: project['statusColor'] as Color,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        project['status'],
                        style: TextStyle(
                          fontSize: 12,
                          color: project['statusColor'] as Color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddProjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add New Project'),
            content: const Text(
              'Feature coming soon! You will be able to add new projects here.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
