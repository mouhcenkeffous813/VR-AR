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
import 'package:youth_center/screens/projects/vr_detail_page.dart';
import 'package:youth_center/screens/ideas_expo/ideas_expo_page.dart';
import 'package:youth_center/services/database_service.dart';
import 'package:youth_center/models/project_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum NotificationType { enrollment, system, reminder }

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}

class HomeContentPage extends StatefulWidget {
  const HomeContentPage({super.key});

  @override
  State<HomeContentPage> createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage> {
  final TextEditingController _searchController = TextEditingController();
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();
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
    _loadCategoriesStatic();
  }

  void _loadCategoriesStatic() {
    setState(() {
      _categories = CategoryData.categories;
    });
  }

  Future<void> _loadProjects() async {
    try {
      setState(() {
        _isLoadingProjects = true;
      });
      final dbProjects = await _dbService.getProjects();

      final defaultProjects = _getDefaultProjects();
      // Remove Digital Expo from default if it exists
      final otherProjects =
          defaultProjects.where((p) => p.id != 'ideas_expo').toList();

      // Check if user is logged in
      final isLoggedIn = Supabase.instance.client.auth.currentUser != null;

      // Only include Digital Expo if user is logged in
      List<ProjectModel> finalProjects = [];
      if (isLoggedIn) {
        final ideasExpoProject = ProjectModel(
          id: 'ideas_expo',
          title: 'Digital Expo',
          description:
              'Share your business ideas, get feedback, and connect with innovators.',
          collaborators: 'Active Community',
          imagePath: 'images/pic4.jpeg',
        );
        // Find Virtual Space and put it first, then Digital Expo, then others
        final virtualSpace = otherProjects.firstWhere(
          (p) => p.id == '1' || p.title.toLowerCase().contains('virtual space'),
          orElse: () => otherProjects.first,
        );
        final otherProjectsWithoutVirtual =
            otherProjects
                .where(
                  (p) =>
                      p.id != '1' &&
                      !p.title.toLowerCase().contains('virtual space'),
                )
                .toList();
        finalProjects = [
          virtualSpace,
          ideasExpoProject,
          ...otherProjectsWithoutVirtual,
          ...dbProjects,
        ];
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

      // Only include Digital Expo if user is logged in
      List<ProjectModel> finalProjects = [];
      if (isLoggedIn) {
        final ideasExpoProject = ProjectModel(
          id: 'ideas_expo',
          title: 'Digital Expo',
          description:
              'Share your business ideas, get feedback, and connect with innovators.',
          collaborators: 'Active Community',
          imagePath: 'images/pic4.jpeg',
        );
        // Find Virtual Space and put it first, then Digital Expo, then others
        final virtualSpace = otherProjects.firstWhere(
          (p) => p.id == '1' || p.title.toLowerCase().contains('virtual space'),
          orElse: () => otherProjects.first,
        );
        final otherProjectsWithoutVirtual =
            otherProjects
                .where(
                  (p) =>
                      p.id != '1' &&
                      !p.title.toLowerCase().contains('virtual space'),
                )
                .toList();
        finalProjects = [
          virtualSpace,
          ideasExpoProject,
          ...otherProjectsWithoutVirtual,
        ];
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
        id: '1',
        title: 'Virtual Space',
        description: 'Explore the virtual space with immersive experiences.',
        collaborators: '5/7 Collaborators',
        imagePath: 'images/vr.jpeg',
      ),
      ProjectModel(
        id: 'ideas_expo',
        title: 'Digital Expo',
        description:
            'Share your business ideas, get feedback, and connect with innovators.',
        collaborators: 'Active Community',
        imagePath: 'images/pic4.jpeg',
      ),
      ProjectModel(
        id: '4',
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
        title: 'Djezzy Hachthon',
        description:
            'An app to connect local tutors with students for free educational support.',
        collaborators: '3/5 Collaborators',
        imagePath: 'images/pic1.jpeg',
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
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF6093D), Color(0xFF2C2225)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF6093D).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, size: 32, color: Colors.white),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: 0.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard({
    required String imagePath,
    required String title,
    String? time,
    String? location,
  }) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200,
              cacheWidth: 560,
              cacheHeight: 400,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) return child;
                return frame == null
                    ? Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.grey[200]),
                      child: const Center(child: CircularProgressIndicator()),
                    )
                    : child;
              },
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Error loading image: $imagePath - $error');
                return Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFF6093D),
                        const Color(0xFF2C2225),
                      ],
                    ),
                  ),
                  child: const Icon(Icons.image, size: 60, color: Colors.white),
                );
              },
            ),
            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
              ),
            ),
            // Content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
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
                    if (time != null || location != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (time != null) ...[
                            const Icon(
                              Icons.access_time_rounded,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              time,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (location != null) const SizedBox(width: 16),
                          ],
                          if (location != null) ...[
                            const Icon(
                              Icons.location_on_rounded,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                location,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
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
        // Special routing for Digital Expo
        if (projectId == 'ideas_expo') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const IdeasExpoPage()),
          );
        } else if (projectId == '4' ||
            title.toLowerCase().contains('virtual space')) {
          // Special routing for Virtual Space VR project
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VRDetailPage()),
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
                        colors: [Color(0xFFF6093D), Color(0xFF2C2225)],
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
              // Special badge and title for Digital Expo
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
                // Large title overlay for Digital Expo
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
                colors: [Color(0xFFF6093D), Color(0xFF2C2225)],
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
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'images/djeey.png',
                            fit: BoxFit.contain,
                          ),
                        ),
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
                        'Ennoveria',
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
          'Ennoveria',
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
                // Notification icon - no action
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
                          // Debug: verify Digital Expo is in the list
                          if (project.id == 'ideas_expo') {
                            debugPrint(
                              'Digital Expo card found at index: $index',
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
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF6093D), Color(0xFF2C2225)],
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
            // Horizontal scrolling categories
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return _buildCategoryCard(
                    icon: category.icon,
                    title: category.name,
                    iconColor: category.iconColor,
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
            // Upcoming Events Section
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF6093D), Color(0xFF2C2225)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.event_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Upcoming Events',
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
            // Horizontal scrolling events
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                itemCount: 3,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildEventCard(
                      imagePath: 'images/port.jpg',
                      title: 'Mechanics & Medicine AR',
                      time: '10:00 AM',
                      location: 'Main Hall',
                    );
                  } else if (index == 1) {
                    return _buildEventCard(
                      imagePath: 'images/bld.jpeg',
                      title: 'Advanced 3D',
                      time: '2:00 PM',
                      location: 'Lab 2',
                    );
                  } else {
                    return _buildEventCard(
                      imagePath: 'images/bg.jpeg',
                      title: 'How to fix bug',
                      time: '4:00 PM',
                      location: 'Workshop Room',
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
