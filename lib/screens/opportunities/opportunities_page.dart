import 'package:flutter/material.dart';
import 'package:youth_center/utils/app_colors.dart';

class OpportunitiesPage extends StatefulWidget {
  const OpportunitiesPage({super.key});

  @override
  State<OpportunitiesPage> createState() => _OpportunitiesPageState();
}

class _OpportunitiesPageState extends State<OpportunitiesPage> {
  int _selectedCategory = 0;
  final TextEditingController _searchController = TextEditingController();
  final List<int> _bookmarkedItems = [];

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
    },
    {
      'id': 3,
      'company': 'Djezzy',
      'title': 'Frontend Developer Project',
      'location': 'Remote',
      'type': 'Projects',
      'tags': ['Collaboration', 'React', 'Portfolio'],
      'logoColor': const Color(0xFF1B5E20),
    },
 
    {
      'id': 5,
      'company': 'Algerie telecom',
      'title': 'Backend Developer Project',
      'location': 'Constantine, Algeria',
      'type': 'Projects',
      'tags': ['Remote', 'Node.js', 'Portfolio'],
      'logoColor': const Color(0xFF7B1FA2),
    },
  ];

  void _toggleBookmark(int id) {
    setState(() {
      if (_bookmarkedItems.contains(id)) {
        _bookmarkedItems.remove(id);
      } else {
        _bookmarkedItems.add(id);
      }
    });
  }

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with title and notification
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Explore Opportunities',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notifications')),
                      );
                    },
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.textPrimary,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for internships, projects...',
                    hintStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),

            // Categories
            SizedBox(
              height: 56,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? AppColors.primary
                                  : AppColors.grey100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            _categories[index],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color:
                                  isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Opportunities list
            Expanded(
              child:
                  _filteredOpportunities.isEmpty
                      ? const Center(
                        child: Text(
                          'No opportunities found',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredOpportunities.length,
                        itemBuilder: (context, index) {
                          final opportunity = _filteredOpportunities[index];
                          final isBookmarked = _bookmarkedItems.contains(
                            opportunity['id'],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Add new opportunity')));
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildOpportunityCard(
    Map<String, dynamic> opportunity,
    bool isBookmarked,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          // Logo placeholder
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: opportunity['logoColor'],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                opportunity['company'].substring(0, 2).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  opportunity['company'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  opportunity['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  opportunity['location'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      (opportunity['tags'] as List<dynamic>)
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                tag.toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),

          // Bookmark icon
          IconButton(
            onPressed: () => _toggleBookmark(opportunity['id']),
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
