import 'package:flutter/material.dart';
import 'package:youth_center/utils/app_colors.dart';
import 'package:youth_center/screens/auth/services/auth_service.dart';
import 'package:youth_center/screens/categories/category_detail_page.dart';
import 'package:youth_center/models/category_model.dart';

class HomeContentPage extends StatefulWidget {
  const HomeContentPage({super.key});

  @override
  State<HomeContentPage> createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage> {
  final TextEditingController _searchController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
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
            builder: (context) => CategoryDetailPage(
              categoryName: title,
              categoryIcon: icon,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderDefault, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: iconColor),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
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
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder or actual image
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: imagePath != null
                ? ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(
                    Icons.image,
                    size: 60,
                    color: AppColors.textSecondary,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.people,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      collaborators,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.textPrimary),
          onPressed: () {
            // TODO: Open drawer if needed
          },
        ),
        title: const Text(
          'Youth Center',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: AppColors.textPrimary),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Message
            Text(
              'Welcome back, ${_getUserName()}!',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            // Search Bar
            TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for projects or skills...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderDefault),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.borderFocused,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Trending Projects Section
            const Text(
              'Trending Projects',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 320,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildProjectCard(
                    title: 'Community Learning App',
                    description:
                        'An app to connect local tutors with students for free educational support.',
                    collaborators: '3/5 Collaborators',
                  ),
                  _buildProjectCard(
                    title: 'Algiers Tech Hub',
                    description:
                        'Organizing young tech enthusiasts to collaborate on innovative projects.',
                    collaborators: '8/10 Collaborators',
                  ),
                  _buildProjectCard(
                    title: 'Green Initiative',
                    description:
                        'Community-led environmental project to promote sustainability.',
                    collaborators: '5/7 Collaborators',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Explore Categories Section
            const Text(
              'Explore Categories',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              children: CategoryData.categories
                  .map((category) => _buildCategoryCard(
                        icon: category.icon,
                        title: category.name,
                        iconColor: category.iconColor,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement create project functionality
        },
        backgroundColor: AppColors.error,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
