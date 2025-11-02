import 'package:flutter/material.dart';
import 'package:youth_center/utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:youth_center/services/database_service.dart';
import 'package:youth_center/models/event_model.dart';

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
  final DatabaseService _dbService = DatabaseService();
  List<EventModel> _events = [];
  Set<String> _enrolledEventIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final events = await _dbService.getEventsByCategoryName(
        widget.categoryName,
      );

      setState(() {
        _events = events;
        _isLoading = false;
      });

      // Load enrollment status after events are loaded
      if (widget.allowEnrollment) {
        _loadEnrollments();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading events: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _loadEnrollments() async {
    if (!widget.allowEnrollment || _events.isEmpty) return;

    try {
      // Load enrollment status for all events
      for (final event in _events) {
        final isEnrolled = await _dbService.isEnrolledInEvent(event.id);
        setState(() {
          if (isEnrolled) {
            _enrolledEventIds.add(event.id);
          } else {
            _enrolledEventIds.remove(event.id);
          }
        });
      }
    } catch (e) {
      print('Error loading enrollments: $e');
    }
  }

  Future<void> _toggleEnrollment(String eventId, String eventName) async {
    if (!widget.allowEnrollment) return;

    try {
      final isEnrolled = _enrolledEventIds.contains(eventId);

      // Update UI immediately for better UX
      setState(() {
        if (isEnrolled) {
          _enrolledEventIds.remove(eventId);
        } else {
          _enrolledEventIds.add(eventId);
        }
      });

      final newStatus = await _dbService.toggleEnrollment(eventId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus
                  ? 'Enrolled in $eventName'
                  : 'Unenrolled from $eventName',
            ),
            backgroundColor: newStatus ? AppColors.success : AppColors.warning,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Revert UI change on error
      setState(() {
        if (_enrolledEventIds.contains(eventId)) {
          _enrolledEventIds.remove(eventId);
        } else {
          _enrolledEventIds.add(eventId);
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

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }

  Widget _buildActivityCard(EventModel event) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final formattedDate = dateFormat.format(event.eventDate);
    final isEnrolled = _enrolledEventIds.contains(event.id);
    final color = _parseColor(event.color);

    IconData typeIcon;
    switch (event.type.toLowerCase()) {
      case 'workshop':
        typeIcon = Icons.build_rounded;
        break;
      case 'event':
        typeIcon = Icons.event_rounded;
        break;
      case 'lecture':
        typeIcon = Icons.school_rounded;
        break;
      default:
        typeIcon = Icons.calendar_today_rounded;
    }

    return Container(
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
          // Top stripe
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withOpacity(0.6)]),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with type and enrolled badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withOpacity(0.2),
                            color.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: color.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(typeIcon, size: 14, color: color),
                          const SizedBox(width: 6),
                          Text(
                            event.type,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isEnrolled) ...[
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF388E3C).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 14,
                              color: Color(0xFF388E3C),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Enrolled',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF388E3C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                // Title and description
                Text(
                  event.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  event.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                // Date and time row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF194CBF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: AppColors.textSecondary.withOpacity(0.8),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF194CBF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: AppColors.textSecondary.withOpacity(0.8),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            event.eventTime,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
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
          // Button section
          if (widget.allowEnrollment)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient:
                        isEnrolled
                            ? null
                            : LinearGradient(
                              colors: [color, color.withOpacity(0.8)],
                            ),
                    color: isEnrolled ? Colors.grey[100] : null,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow:
                        isEnrolled
                            ? null
                            : [
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => _toggleEnrollment(event.id, event.name),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isEnrolled
                              ? Icons.check_circle_rounded
                              : Icons.add_circle_outline_rounded,
                          color:
                              isEnrolled
                                  ? AppColors.textSecondary
                                  : Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isEnrolled ? 'Enrolled' : 'Enroll Now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                isEnrolled
                                    ? AppColors.textSecondary
                                    : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
      body: Column(
        children: [
          // Header with gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF194CBF), Color(0xFF61A1FF)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF194CBF),
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
                                'Upcoming activities and events',
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
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _events.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy_outlined,
                            size: 64,
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No upcoming events',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _events.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildActivityCard(_events[index]),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
