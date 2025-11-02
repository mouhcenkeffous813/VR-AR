import 'package:flutter/material.dart';
import 'package:youth_center/utils/app_colors.dart';
import 'package:youth_center/services/database_service.dart';
import 'package:youth_center/models/project_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyProjectsPage extends StatefulWidget {
  const MyProjectsPage({super.key});

  @override
  State<MyProjectsPage> createState() => _MyProjectsPageState();
}

class _MyProjectsPageState extends State<MyProjectsPage> {
  final DatabaseService _dbService = DatabaseService();
  List<ProjectModel> _projects = [];
  bool _isLoading = true;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  List<ProjectModel> _getDefaultProjects() {
    return [
      ProjectModel(
        id: '1',
        title: 'Fintech App Redesign',
        description:
            'Revamping the user interface for a local mobile banking application.',
        collaborators: '4/4 Collaborators',
        createdBy: 'default',
      ),
      ProjectModel(
        id: '2',
        title: 'LocalArtisan Marketplace',
        description:
            'A platform connecting local Algerian artisans with a global audience.',
        collaborators: '8/8 Collaborators',
        createdBy: 'default',
      ),
      ProjectModel(
        id: '3',
        title: 'Eco-Tourism Platform',
        description:
            'Discover and book eco-friendly tours and stays across Algeria\'s national parks.',
        collaborators: '2/2 Collaborators',
        createdBy: 'default',
      ),
      ProjectModel(
        id: '4',
        title: 'Tassili EdTech Initiative',
        description:
            'Developing interactive learning modules for primary school students.',
        collaborators: '6/6 Collaborators',
        createdBy: 'default',
      ),
      ProjectModel(
        id: '5',
        title: 'Sahara Logistics',
        description:
            'An app to optimize and track last-mile delivery in southern Algeria.',
        collaborators: '5/5 Collaborators',
        createdBy: 'default',
      ),
    ];
  }

  Future<void> _loadProjects() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final userId = Supabase.instance.client.auth.currentUser?.id;

      // Get default projects
      final defaultProjects = _getDefaultProjects();

      if (userId == null) {
        // If not logged in, show only default projects
        setState(() {
          _projects = defaultProjects;
          _isLoading = false;
        });
        return;
      }

      // Get all projects and filter by current user
      final allProjects = await _dbService.getProjects();
      final myProjects =
          allProjects.where((p) => p.createdBy == userId).toList();

      // Combine default projects with user's database projects
      setState(() {
        _projects = [...defaultProjects, ...myProjects];
        _isLoading = false;
      });
    } catch (e) {
      // On error, show default projects
      setState(() {
        _projects = _getDefaultProjects();
        _isLoading = false;
      });
    }
  }

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
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _projects.isEmpty
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
                            const SizedBox(height: 8),
                            Text(
                              'Tap the + icon to create your first project',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
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

  Widget _buildProjectCard(ProjectModel project) {
    // Extract number of collaborators from string like "3/5 Collaborators"
    final collaboratorsMatch = RegExp(
      r'(\d+)/(\d+)',
    ).firstMatch(project.collaborators);
    final currentMembers =
        int.tryParse(collaboratorsMatch?.group(1) ?? '0') ?? 0;
    final maxMembers = int.tryParse(collaboratorsMatch?.group(2) ?? '1') ?? 1;
    final progress = (currentMembers / maxMembers).clamp(0.0, 1.0);

    // Get color based on progress
    final Color progressColor;
    if (progress >= 1.0) {
      progressColor = const Color(0xFF4CAF50); // Green for complete
    } else if (progress >= 0.7) {
      progressColor = const Color(0xFF61A1FF); // Blue for good progress
    } else {
      progressColor = const Color(0xFFFFA726); // Orange for low progress
    }

    // Default icon based on project title or use a general one
    IconData projectIcon = Icons.work_outline;
    Color iconColor = const Color(0xFF194CBF);

    if (project.title.toLowerCase().contains('fintech') ||
        project.title.toLowerCase().contains('bank')) {
      projectIcon = Icons.account_balance_rounded;
      iconColor = const Color(0xFF4CAF50);
    } else if (project.title.toLowerCase().contains('marketplace') ||
        project.title.toLowerCase().contains('store')) {
      projectIcon = Icons.store_rounded;
      iconColor = const Color(0xFFE91E63);
    } else if (project.title.toLowerCase().contains('tourism') ||
        project.title.toLowerCase().contains('eco')) {
      projectIcon = Icons.nature_rounded;
      iconColor = const Color(0xFF4CAF50);
    } else if (project.title.toLowerCase().contains('edtech') ||
        project.title.toLowerCase().contains('school')) {
      projectIcon = Icons.school_rounded;
      iconColor = const Color(0xFF9C27B0);
    } else if (project.title.toLowerCase().contains('logistics') ||
        project.title.toLowerCase().contains('shipping')) {
      projectIcon = Icons.local_shipping_rounded;
      iconColor = const Color(0xFFFF9800);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top colored stripe
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [iconColor, iconColor.withOpacity(0.6)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon with gradient
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [iconColor, iconColor.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(projectIcon, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        project.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Description
                      Text(
                        project.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),

                      // Progress Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.people_rounded,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$currentMembers/$maxMembers Members',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              // Status Tag
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  gradient:
                                      progress >= 1.0
                                          ? LinearGradient(
                                            colors: [
                                              const Color(0xFF4CAF50),
                                              const Color(0xFF66BB6A),
                                            ],
                                          )
                                          : null,
                                  color:
                                      progress >= 1.0
                                          ? null
                                          : progressColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: progressColor.withOpacity(0.4),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  progress >= 1.0 ? 'Complete' : 'In Progress',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: progressColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor: AppColors.grey100,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                progressColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${(progress * 100).toInt()}% Complete',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddProjectDialog(BuildContext context) {
    _titleController.clear();
    _descriptionController.clear();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Create New Project',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Suggestion Title',
                      hintText: 'Enter Suggestion title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter Suggestion description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final title = _titleController.text.trim();
                  final description = _descriptionController.text.trim();

                  if (title.isEmpty || description.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill in all fields'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  try {
                    // Create project in database
                    final project = ProjectModel(
                      id: '', // Will be generated by database
                      title: title,
                      description: description,
                      collaborators: '1/1 Collaborators',
                    );

                    await _dbService.createProject(project);

                    // Close dialog
                    if (mounted) {
                      Navigator.of(context).pop();
                    }

                    // Reload projects
                    await _loadProjects();

                    // Show success message
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Project created successfully!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error creating project: $e'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF194CBF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Create'),
              ),
            ],
          ),
    );
  }
}
