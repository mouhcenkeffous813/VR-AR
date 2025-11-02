import 'package:flutter/material.dart';
import 'package:youth_center/utils/app_colors.dart';
import 'package:youth_center/screens/opportunities/opportunity_detail_page.dart';
import 'package:youth_center/services/database_service.dart';

class OpportunitiesPage extends StatefulWidget {
  const OpportunitiesPage({super.key});

  @override
  State<OpportunitiesPage> createState() => _OpportunitiesPageState();
}

class _OpportunitiesPageState extends State<OpportunitiesPage> {
  int _selectedCategory = 0;
  final TextEditingController _searchController = TextEditingController();
  final DatabaseService _dbService = DatabaseService();
  final List<String> _bookmarkedItems = [];

  final List<String> _categories = [
    'All',
    'Exchange Programs',
    'Internships',
    'Volunteering',
    'Projects',
  ];

  final List<Map<String, dynamic>> _opportunities = [
    {
      'id': 1,
      'company': 'Yassir',
      'title': 'Marketing Intern',
      'location': 'Algiers, Algeria',
      'type': 'Internships',
      'tags': ['Remote', 'Part-time', 'Paid'],
      'logoColor': const Color(0xFF1B5E20),
      'image': 'images/yassir.jpeg',
    },
    {
      'id': 2,
      'company': 'The University of Tokyo',
      'title': 'Master in Computer Science',
      'location': 'Japan, Tokyo',
      'type': 'Exchange Programs',
      'tags': ['On-site', 'Full-time', 'Paid'],
      'logoColor': const Color(0xFF1976D2),
    },
    {
      'id': 4,
      'company': 'Ooredoo',
      'title': 'Community Manager Volunteer',
      'location': 'Oran, Algeria',
      'type': 'Volunteering',
      'tags': ['On-site', 'Volunteering'],
      'logoColor': AppColors.grey300,
      'image': 'images/ooredo.jpeg',
    },
    {
      'id': 3,
      'company': 'Djezzy',
      'title': 'Frontend Developer Project',
      'location': 'Remote',
      'type': 'Projects',
      'tags': ['Collaboration', 'React', 'Portfolio'],
      'logoColor': const Color(0xFF1B5E20),
      'image': 'images/djezzy.jpeg',
    },

    {
      'id': 5,
      'company': 'Algerie telecom',
      'title': 'Backend Developer Project',
      'location': 'Constantine, Algeria',
      'type': 'Projects',
      'tags': ['Remote', 'Node.js', 'Portfolio'],
      'logoColor': const Color(0xFF7B1FA2),
      'image': 'images/algerietelc.jpeg',
    },
  ];


  List<Map<String, dynamic>> get _filteredOpportunities {
    if (_selectedCategory == 0) {
      // Return all opportunities when "All" is selected
      return List.from(_opportunities);
    }
    // Filter by category type
    return _opportunities
        .where((opp) => opp['type'] == _categories[_selectedCategory])
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    try {
      final bookmarks = await _dbService.getUserBookmarks();
      setState(() {
        _bookmarkedItems.clear();
        _bookmarkedItems.addAll(bookmarks);
      });
    } catch (e) {
      // Silently handle errors - bookmarks are optional
    }
  }

  Future<void> _toggleBookmark(String id) async {
    try {
      // Update local state first for immediate feedback
      final wasBookmarked = _bookmarkedItems.contains(id);
      setState(() {
        if (wasBookmarked) {
          _bookmarkedItems.remove(id);
        } else {
          _bookmarkedItems.add(id);
        }
      });

      // Then save to database
      await _dbService.toggleBookmark(id);
      
      // Reload bookmarks to sync with database
      await _loadBookmarks();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(wasBookmarked ? 'Bookmark removed' : 'Bookmarked!'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Revert local state on error
      setState(() {
        if (_bookmarkedItems.contains(id)) {
          _bookmarkedItems.remove(id);
        } else {
          _bookmarkedItems.add(id);
        }
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _getCategoryIcon(int index) {
    switch (index) {
      case 0:
        return Icons.apps_rounded;
      case 1:
        return Icons.language_rounded;
      case 2:
        return Icons.work_rounded;
      case 3:
        return Icons.favorite_rounded;
      case 4:
        return Icons.folder_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with gradient background
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF194CBF),
                    Color(0xFF61A1FF),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF194CBF).withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Explore\nOpportunities',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Notifications'),
                                    backgroundColor: Color(0xFF194CBF),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.notifications_outlined,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Search bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search internships, projects...',
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary.withOpacity(0.6),
                              fontSize: 15,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: Color(0xFF194CBF),
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded),
                                    color: AppColors.textSecondary,
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Categories
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedCategory == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = index;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF194CBF),
                                      Color(0xFF61A1FF),
                                    ],
                                  )
                                : null,
                            color: isSelected ? null : AppColors.grey100,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : Colors.grey[300]!,
                              width: 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF194CBF)
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getCategoryIcon(index),
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _categories[index],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Opportunities list
            Expanded(
              child: _filteredOpportunities.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 64,
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No opportunities found',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search or filters',
                            style: TextStyle(
                              color: AppColors.textSecondary.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _filteredOpportunities.length,
                      itemBuilder: (context, index) {
                        final opportunity = _filteredOpportunities[index];
                        final isBookmarked = _bookmarkedItems.contains(
                          opportunity['id'].toString(),
                        );
                        return _buildOpportunityCard(
                          opportunity,
                          isBookmarked,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF194CBF),
              Color(0xFF61A1FF),
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF194CBF).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          heroTag: "opportunities_fab",
          onPressed: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(
              const SnackBar(
                content: Text('Add new opportunity'),
                backgroundColor: Color(0xFF194CBF),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildOpportunityCard(
    Map<String, dynamic> opportunity,
    bool isBookmarked,
  ) {
    final typeColor = _getTypeColor(opportunity['type']);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => OpportunityDetailPage(opportunity: opportunity),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
            // Top section with gradient stripe
            Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    typeColor,
                    typeColor.withOpacity(0.6),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo with better styling
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: opportunity['logoColor'],
                      borderRadius: BorderRadius.circular(16),
                      image:
                          opportunity['image'] != null
                              ? DecorationImage(
                                image: AssetImage(opportunity['image']),
                                fit: BoxFit.cover,
                              )
                              : null,
                      boxShadow: [
                        BoxShadow(
                          color: (opportunity['logoColor'] as Color)
                              .withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child:
                        opportunity['image'] == null
                            ? Center(
                              child: Text(
                                opportunity['company']
                                    .substring(0, 2)
                                    .toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            )
                            : null,
                  ),
                  const SizedBox(width: 16),

                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    opportunity['company'],
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    opportunity['title'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_rounded,
                                        size: 16,
                                        color: AppColors.textSecondary
                                            .withOpacity(0.7),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        opportunity['location'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Bookmark icon
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () =>
                                    _toggleBookmark(opportunity['id'].toString()),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isBookmarked
                                        ? const Color(0xFF194CBF)
                                            .withOpacity(0.1)
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isBookmarked
                                        ? Icons.bookmark_rounded
                                        : Icons.bookmark_border_rounded,
                                    color: isBookmarked
                                        ? const Color(0xFF194CBF)
                                        : AppColors.textSecondary,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              (opportunity['tags'] as List<dynamic>)
                                  .map(
                                    (tag) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFF194CBF)
                                                .withOpacity(0.1),
                                            const Color(0xFF61A1FF)
                                                .withOpacity(0.1),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFF194CBF)
                                              .withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        tag.toString(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF194CBF),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
}
