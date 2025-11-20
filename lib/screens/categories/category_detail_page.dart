import 'package:flutter/material.dart';
import 'package:youth_center/utils/app_colors.dart';
import 'package:youth_center/screens/projects/vr_room_experience_page.dart';

class CategoryRoom {
  final String name;
  final int participants;
  final IconData icon;
  final Color color;

  const CategoryRoom({
    required this.name,
    required this.participants,
    required this.icon,
    required this.color,
  });
}

class CategoryDetailPage extends StatefulWidget {
  final String categoryName;
  final IconData categoryIcon;
  final bool allowEnrollment;

  const CategoryDetailPage({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
    this.allowEnrollment = true,
  });

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  List<CategoryRoom> _rooms = [];

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  void _loadRooms() {
    // Define rooms for each category
    final categoryName = widget.categoryName.toLowerCase();
    
    if (categoryName.contains('medicine')) {
      _rooms = [
        const CategoryRoom(
          name: 'Anatomy Lab',
          participants: 28,
          icon: Icons.medical_services,
          color: Color(0xFFE91E63),
        ),
        const CategoryRoom(
          name: 'Surgery Room',
          participants: 15,
          icon: Icons.healing,
          color: Color(0xFFF44336),
        ),
        const CategoryRoom(
          name: 'Pharmacy Lab',
          participants: 22,
          icon: Icons.medication,
          color: Color(0xFF9C27B0),
        ),
        const CategoryRoom(
          name: 'Research Center',
          participants: 18,
          icon: Icons.science,
          color: Color(0xFF3F51B5),
        ),
      ];
    } else if (categoryName.contains('chemistry')) {
      _rooms = [
        const CategoryRoom(
          name: 'Organic Chemistry Lab',
          participants: 24,
          icon: Icons.science,
          color: Color(0xFF4CAF50),
        ),
        const CategoryRoom(
          name: 'Inorganic Lab',
          participants: 19,
          icon: Icons.biotech,
          color: Color(0xFF00BCD4),
        ),
        const CategoryRoom(
          name: 'Analytical Lab',
          participants: 16,
          icon: Icons.analytics,
          color: Color(0xFF009688),
        ),
        const CategoryRoom(
          name: 'Physical Chemistry',
          participants: 21,
          icon: Icons.explore,
          color: Color(0xFF795548),
        ),
      ];
    } else if (categoryName.contains('engineering')) {
      _rooms = [
        const CategoryRoom(
          name: 'Mechanical Engineering',
          participants: 32,
          icon: Icons.engineering,
          color: Color(0xFFFF9800),
        ),
        const CategoryRoom(
          name: 'Electrical Lab',
          participants: 27,
          icon: Icons.electrical_services,
          color: Color(0xFFFFC107),
        ),
        const CategoryRoom(
          name: 'Civil Engineering',
          participants: 25,
          icon: Icons.construction,
          color: Color(0xFF607D8B),
        ),
        const CategoryRoom(
          name: 'Software Lab',
          participants: 35,
          icon: Icons.computer,
          color: Color(0xFF2196F3),
        ),
      ];
    } else if (categoryName.contains('mechanics')) {
      _rooms = [
        const CategoryRoom(
          name: 'Auto Mechanics',
          participants: 20,
          icon: Icons.build,
          color: Color(0xFFFF5722),
        ),
        const CategoryRoom(
          name: 'Industrial Mechanics',
          participants: 18,
          icon: Icons.precision_manufacturing,
          color: Color(0xFFFF9800),
        ),
        const CategoryRoom(
          name: 'Aerospace Lab',
          participants: 14,
          icon: Icons.flight,
          color: Color(0xFF2196F3),
        ),
        const CategoryRoom(
          name: 'Robotics Workshop',
          participants: 23,
          icon: Icons.smart_toy,
          color: Color(0xFF9C27B0),
        ),
      ];
    } else if (categoryName.contains('geometry')) {
      _rooms = [
        const CategoryRoom(
          name: '2D Geometry',
          participants: 26,
          icon: Icons.crop_free,
          color: Color(0xFF00BCD4),
        ),
        const CategoryRoom(
          name: '3D Modeling',
          participants: 29,
          icon: Icons.view_in_ar,
          color: Color(0xFF03A9F4),
        ),
        const CategoryRoom(
          name: 'Analytical Geometry',
          participants: 17,
          icon: Icons.functions,
          color: Color(0xFF0288D1),
        ),
        const CategoryRoom(
          name: 'Spatial Design',
          participants: 24,
          icon: Icons.shape_line,
          color: Color(0xFF01579B),
        ),
      ];
    } else if (categoryName.contains('architecture')) {
      _rooms = [
        const CategoryRoom(
          name: 'Design Studio',
          participants: 31,
          icon: Icons.architecture,
          color: Color(0xFF795548),
        ),
        const CategoryRoom(
          name: 'Urban Planning',
          participants: 19,
          icon: Icons.location_city,
          color: Color(0xFF5D4037),
        ),
        const CategoryRoom(
          name: 'Interior Design',
          participants: 28,
          icon: Icons.home,
          color: Color(0xFF6D4C41),
        ),
        const CategoryRoom(
          name: '3D Visualization',
          participants: 22,
          icon: Icons.view_in_ar,
          color: Color(0xFF4E342E),
        ),
      ];
    } else {
      // Default rooms
      _rooms = [
        const CategoryRoom(
          name: 'General Room 1',
          participants: 20,
          icon: Icons.meeting_room,
          color: Color(0xFF9C27B0),
        ),
        const CategoryRoom(
          name: 'General Room 2',
          participants: 15,
          icon: Icons.meeting_room,
          color: Color(0xFF4CAF50),
        ),
      ];
    }
    
    setState(() {});
  }

  Widget _buildRoomCard({
    required String roomName,
    required int participants,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          // Room info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roomName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.people_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$participants people joined',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Join button
          Container(
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VRRoomExperiencePage(
                      roomName: roomName,
                      participants: participants,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text(
                'Join',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
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
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF6093D).withOpacity(0.2),
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
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF6093D), Color(0xFF2C2225)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header with gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF6093D), Color(0xFF2C2225)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFF6093D),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.categoryIcon,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.categoryName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Explore interactive rooms',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Content
          Expanded(
            child: _rooms.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _buildSectionCard(
                      icon: Icons.door_sliding_rounded,
                      title: '${widget.categoryName} Rooms',
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: _rooms.map((room) {
                          return _buildRoomCard(
                            roomName: room.name,
                            participants: room.participants,
                            icon: room.icon,
                            color: room.color,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
