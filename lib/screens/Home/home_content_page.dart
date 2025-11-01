import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youth_center/utils/app_colors.dart';
import 'package:youth_center/screens/auth/services/auth_service.dart';
import 'package:youth_center/screens/categories/category_detail_page.dart';
import 'package:youth_center/models/category_model.dart';
import 'package:youth_center/screens/career/career_campus_page.dart';
import 'package:youth_center/screens/clubs/clubs_hub_page.dart';
import 'package:youth_center/screens/volunteering/volunteering_page.dart';
import 'package:youth_center/screens/projects/project_detail_page.dart';
import 'package:youth_center/screens/ideas_expo/ideas_expo_page.dart';
import 'package:youth_center/services/database_service.dart';
import 'package:youth_center/models/project_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeContentPage extends StatefulWidget {
  const HomeContentPage({super.key});

  @override
  State<HomeContentPage> createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage> {
  final TextEditingController _searchController = TextEditingController();
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;
  List<ProjectModel> _projects = [];
  bool _isLoadingProjects = true;
  List<CategoryModel> _categories = [];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    _loadProjects();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final dbCategories = await _dbService.getCategories();

      // If database has categories, use them; otherwise use default
      setState(() {
        _categories =
            dbCategories.isNotEmpty ? dbCategories : CategoryData.categories;
      });
    } catch (e) {
      // Fallback to default categories on error
      setState(() {
        _categories = CategoryData.categories;
      });
    }
  }

  Future<void> _loadProjects() async {
    try {
      setState(() {
        _isLoadingProjects = true;
      });
      final dbProjects = await _dbService.getProjects();

      final defaultProjects = _getDefaultProjects();
      // Remove Ideas Expo from default if it exists
      final otherProjects =
          defaultProjects.where((p) => p.id != 'ideas_expo').toList();

      // Check if user is logged in
      final isLoggedIn = Supabase.instance.client.auth.currentUser != null;

      // Only include Ideas Expo if user is logged in
      List<ProjectModel> finalProjects = [];
      if (isLoggedIn) {
        final ideasExpoProject = ProjectModel(
          id: 'ideas_expo',
          title: 'Ideas Expo',
          description:
              'Share your business ideas, get feedback, and connect with innovators.',
          collaborators: 'Active Community',
          imagePath: 'images/pic4.jpeg',
        );
        finalProjects = [ideasExpoProject, ...otherProjects, ...dbProjects];
      } else {
        finalProjects = [...otherProjects, ...dbProjects];
      }

      setState(() {
        _projects = finalProjects;
        _isLoadingProjects = false;
      });
    } catch (e) {
      // On error, show default projects
      final defaultProjects = _getDefaultProjects();
      final otherProjects =
          defaultProjects.where((p) => p.id != 'ideas_expo').toList();

      // Check if user is logged in
      final isLoggedIn = Supabase.instance.client.auth.currentUser != null;

      // Only include Ideas Expo if user is logged in
      List<ProjectModel> finalProjects = [];
      if (isLoggedIn) {
        final ideasExpoProject = ProjectModel(
          id: 'ideas_expo',
          title: 'Ideas Expo',
          description:
              'Share your business ideas, get feedback, and connect with innovators.',
          collaborators: 'Active Community',
          imagePath: 'images/pic4.jpeg',
        );
        finalProjects = [ideasExpoProject, ...otherProjects];
      } else {
        finalProjects = otherProjects;
      }

      setState(() {
        _projects = finalProjects;
        _isLoadingProjects = false;
      });
    }
  }

  List<ProjectModel> _getDefaultProjects() {
    return [
      ProjectModel(
        id: 'ideas_expo',
        title: 'Ideas Expo',
        description:
            'Share your business ideas, get feedback, and connect with innovators.',
        collaborators: 'Active Community',
        imagePath: 'images/pic4.jpeg',
      ),
      ProjectModel(
        id: '1',
        title: 'Djezzy Hachthon',
        description:
            'An app to connect local tutors with students for free educational support.',
        collaborators: '3/5 Collaborators',
        imagePath: 'images/pic1.jpeg',
      ),
      ProjectModel(
        id: '2',
        title: 'Hachthon Youth digital innovation',
        description:
            'Organizing young tech enthusiasts to collaborate on innovative projects.',
        collaborators: '8/10 Collaborators',
        imagePath: 'images/pic2.jpeg',
      ),
      ProjectModel(
        id: '3',
        title: 'Innovation Hub',
        description:
            'Community-led environmental project to promote sustainability.',
        collaborators: '5/7 Collaborators',
        imagePath: 'images/pic3.jpeg',
      ),
      ProjectModel(
        id: '5',
        title: 'Gaming Experience',
        description:
            'Join the ultimate gaming adventure with exciting rewards and challenges.',
        collaborators: '10/10 Collaborators',
        imagePath: 'images/monceff.jpeg',
      ),
    ];
  }

  void _startAutoScroll() {
    _scrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.position.pixels;
        final cardWidth = 280.0 + 20.0; // card width + margin

        if (currentScroll >= maxScroll - cardWidth) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          _scrollController.animateTo(
            currentScroll + cardWidth,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  String _getUserName() {
    final email = _authService.getCurrentUserEmail();
    if (email != null) {
      return email.split('@')[0]; // Get username from email
    }
    return 'User';
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required String title,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    CategoryDetailPage(categoryName: title, categoryIcon: icon),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.grey300, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey300.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: iconColor),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard({
    required String title,
    required String description,
    required String collaborators,
    String? imagePath,
    String? projectId,
  }) {
    return GestureDetector(
      onTap: () {
        // Special routing for Ideas Expo
        if (projectId == 'ideas_expo') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const IdeasExpoPage()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ProjectDetailPage(
                    title: title,
                    description: description,
                    collaborators: collaborators,
                    imagePath: imagePath,
                  ),
            ),
          );
        }
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              imagePath != null
                  ? Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback if image fails to load
                      return Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors:
                                projectId == 'ideas_expo'
                                    ? [
                                      AppColors.primaryLight,
                                      AppColors.primary,
                                    ]
                                    : [
                                      AppColors.primaryLight,
                                      AppColors.primary,
                                    ],
                          ),
                        ),
                        child:
                            projectId == 'ideas_expo'
                                ? const Icon(
                                  Icons.lightbulb,
                                  size: 60,
                                  color: Colors.white,
                                )
                                : const Icon(
                                  Icons.image,
                                  size: 60,
                                  color: Colors.white,
                                ),
                      );
                    },
                  )
                  : Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primaryLight, AppColors.primary],
                      ),
                    ),
                    child: const Icon(
                      Icons.image,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
              // Special badge and title for Ideas Expo
              if (projectId == 'ideas_expo') ...[
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lightbulb, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'New',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Large title overlay for Ideas Expo
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 6,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ] else
                // Default title overlay for other projects
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        hoverColor: AppColors.primary.withOpacity(0.1),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      width: 280,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header Section
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 40,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.account_circle,
                        size: 60,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _getUserName(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Youth Center',
                        style: TextStyle(
                          color: Color.fromARGB(179, 15, 71, 238),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                _buildDrawerItem(
                  icon: Icons.school_rounded,
                  title: 'Career Campus',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CareerCampusPage(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.group_rounded,
                  title: 'Clubs Hub',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ClubsHubPage(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.favorite_rounded,
                  title: 'Volunteering',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VolunteeringPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.borderDefault,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Title
                const Text(
                  'Add a new suggestion',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                // Title field
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Project Title',
                    hintText: 'Enter project title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.borderDefault,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.borderFocused,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Description field
                TextFormField(
                  controller: _contentController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter project description',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.borderDefault,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.borderFocused,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Create Project button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final title = _titleController.text.trim();
                      final description = _contentController.text.trim();

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
                        // Create suggestion in database
                        await _dbService.createSuggestion(
                          title: title,
                          description: description,
                        );

                        // Clear fields after creating
                        _titleController.clear();
                        _contentController.clear();

                        // Close bottom sheet
                        if (mounted) {
                          Navigator.pop(context);
                        }

                        // Show success message
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Suggestion submitted successfully!',
                              ),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error submitting suggestion: $e'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
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
                      'Send suggestion',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _buildDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Builder(
          builder:
              (context) => Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.menu,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
        ),
        title: const Text(
          'Youth Center',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.notifications,
                color: AppColors.primary,
                size: 24,
              ),
              onPressed: () {
                // TODO: Navigate to notifications
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar with Gradient Shadow
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for projects or skills...',
                  prefixIcon: Container(
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 200,
              child:
                  _isLoadingProjects
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        itemCount: _projects.length,
                        itemBuilder: (context, index) {
                          final project = _projects[index];
                          // Debug: verify Ideas Expo is in the list
                          if (project.id == 'ideas_expo') {
                            debugPrint(
                              'Ideas Expo card found at index: $index',
                            );
                          }
                          return _buildProjectCard(
                            title: project.title,
                            description: project.description,
                            collaborators: project.collaborators,
                            imagePath: project.imagePath,
                            projectId: project.id,
                          );
                        },
                      ),
            ),
            const SizedBox(height: 40),
            // Explore Categories Section
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.grid_view_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Explore Categories',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.8,
              children:
                  _categories
                      .map(
                        (category) => _buildCategoryCard(
                          icon: category.icon,
                          title: category.name,
                          iconColor: category.iconColor,
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          heroTag: "home_fab",
          onPressed: _showBottomSheet,
          backgroundColor: AppColors.primary,
          elevation: 0,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Suggestion',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
