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

      final events = await _dbService.getEventsByCategoryName(widget.categoryName);
      
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
            content: Text(newStatus 
                ? 'Enrolled in $eventName' 
                : 'Unenrolled from $eventName'),
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
        typeIcon = Icons.build_outlined;
        break;
      case 'event':
        typeIcon = Icons.event_outlined;
        break;
      case 'lecture':
        typeIcon = Icons.school_outlined;
        break;
      default:
        typeIcon = Icons.calendar_today_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnrolled ? color : AppColors.borderDefault,
          width: isEnrolled ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  event.type,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              if (isEnrolled) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 14, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text(
                        'Enrolled',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(typeIcon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                event.eventTime,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (widget.allowEnrollment) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _toggleEnrollment(event.id, event.name),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEnrolled 
                      ? AppColors.grey300 
                      : color,
                  foregroundColor: isEnrolled 
                      ? AppColors.textPrimary 
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isEnrolled ? 'Enrolled' : 'Enroll',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
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
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.categoryIcon,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            widget.categoryName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Activities Section
                    const Text(
                      'Upcoming Activities',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Events List
                    if (_events.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 64,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No upcoming events',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._events.map((event) => _buildActivityCard(event)),
                  ],
                ),
              ),
      ),
    );
  }
}
