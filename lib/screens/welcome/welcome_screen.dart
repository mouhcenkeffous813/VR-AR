import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youth_center/utils/app_colors.dart';
import 'package:youth_center/models/category_model.dart';
import 'package:youth_center/models/project_model.dart';
import 'package:youth_center/screens/categories/category_detail_page.dart';
import 'package:youth_center/screens/opportunities/opportunities_page.dart';
import 'package:youth_center/screens/map/map_page.dart';
import 'package:youth_center/screens/auth/pages/login.dart';
import 'package:youth_center/screens/projects/project_detail_page.dart';
import 'package:youth_center/services/database_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const WelcomeContentPage(),
    const OpportunitiesPage(),
    const MapPage(),
    const LoginScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _buildDrawer(),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF194CBF),
        unselectedItemColor: AppColors.textSecondary,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Opportunities',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Login'),
        ],
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
                      const Icon(Icons.group, size: 60, color: Colors.white),
                      const SizedBox(height: 12),
                      const Text(
                        'Guest',
                        style: TextStyle(
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
                  context,
                  icon: Icons.home_rounded,
                  title: 'Home',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _currentIndex = 0;
                    });
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.info_outline_rounded,
                  title: 'About',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.contact_support_rounded,
                  title: 'Contact',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.event_rounded,
                  title: 'Events',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.people_rounded,
                  title: 'Community',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
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
}

class WelcomeContentPage extends StatefulWidget {
  const WelcomeContentPage({super.key});

  @override
  State<WelcomeContentPage> createState() => _WelcomeContentPageState();
}

class _WelcomeContentPageState extends State<WelcomeContentPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final DatabaseService _dbService = DatabaseService();
  Timer? _scrollTimer;
  List<ProjectModel> _projects = [];
  bool _isLoadingProjects = true;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      setState(() {
        _isLoadingProjects = true;
      });
      final dbProjects = await _dbService.getProjects();

      final defaultProjects = _getDefaultProjects();
      // Remove Ideas Expo from default - welcome screen is for non-logged users
      final otherProjects =
          defaultProjects.where((p) => p.id != 'ideas_expo').toList();

      // Welcome screen is for non-logged users, so exclude Ideas Expo
      final finalProjects = [...otherProjects, ...dbProjects];

      setState(() {
        _projects = finalProjects;
        _isLoadingProjects = false;
      });
    } catch (e) {
      // On error, show default projects (without Ideas Expo for non-logged users)
      final defaultProjects = _getDefaultProjects();
      final otherProjects =
          defaultProjects.where((p) => p.id != 'ideas_expo').toList();

      setState(() {
        _projects = otherProjects;
        _isLoadingProjects = false;
      });
    }
  }

  List<ProjectModel> _getDefaultProjects() {
    return [
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
        id: '4',
        title: 'Innovation Hub',
        description:
            'A platform for creative minds to collaborate and innovate.',
        collaborators: '7/10 Collaborators',
        imagePath: 'images/pic4.jpeg',
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
                (context) => CategoryDetailPage(
                  categoryName: title,
                  categoryIcon: icon,
                  allowEnrollment: false, // No enrollment before login
                ),
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
  }) {
    return GestureDetector(
      onTap: () {
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
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                // TODO: Navigate to notifications or show login prompt
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
                          return _buildProjectCard(
                            title: project.title,
                            description: project.description,
                            collaborators: project.collaborators,
                            imagePath: project.imagePath,
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
                  CategoryData.categories
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
    );
  }
}
