import 'package:flutter/material.dart';
import 'package:youth_center/utils/app_colors.dart';
import 'package:youth_center/services/database_service.dart';
import 'package:youth_center/models/volunteering_opportunity_model.dart';
import 'package:youth_center/utils/icon_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VolunteeringPage extends StatefulWidget {
  const VolunteeringPage({super.key});

  @override
  State<VolunteeringPage> createState() => _VolunteeringPageState();
}

class _VolunteeringPageState extends State<VolunteeringPage> {
  final DatabaseService _dbService = DatabaseService();
  List<VolunteeringOpportunityModel> _opportunities = [];
  Set<String> _enrolledOpportunityIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOpportunities();
  }

  Future<void> _loadOpportunities() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final opportunities = await _dbService.getVolunteeringOpportunities();
      final userId = Supabase.instance.client.auth.currentUser?.id;
      
      Set<String> enrolledIds = {};
      if (userId != null) {
        final enrollments = await _dbService.getUserVolunteeringEnrollments();
        enrolledIds = enrollments.map((e) => e.opportunityId).toSet();
      }

      setState(() {
        _opportunities = opportunities;
        _enrolledOpportunityIds = enrolledIds;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        // Show error message with better formatting
        final errorMsg = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMsg,
              style: const TextStyle(fontSize: 14),
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  Future<void> _toggleEnrollment(VolunteeringOpportunityModel opportunity) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to join volunteering opportunities'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    try {
      final isEnrolled = _enrolledOpportunityIds.contains(opportunity.id);
      await _dbService.toggleVolunteeringEnrollment(opportunity.id);
      
      setState(() {
        if (isEnrolled) {
          _enrolledOpportunityIds.remove(opportunity.id);
        } else {
          _enrolledOpportunityIds.add(opportunity.id);
        }
      });

      // Reload opportunities to update enrolled count
      await _loadOpportunities();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEnrolled 
              ? 'Unenrolled from ${opportunity.title} successfully' 
              : 'Enrolled in ${opportunity.title} successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
        title: const Text(
          'Volunteering',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.success, AppColors.successLight],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.favorite,
                    size: 60,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Volunteering',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Make a difference in your community',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Content Section
            const Text(
              'Volunteer Opportunities',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _opportunities.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            'No volunteering opportunities available',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        children: _opportunities.asMap().entries.map((entry) {
                          final index = entry.key;
                          final opportunity = entry.value;
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index < _opportunities.length - 1 ? 12 : 0,
                            ),
                            child: _buildOpportunityCard(opportunity),
                          );
                        }).toList(),
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpportunityCard(VolunteeringOpportunityModel opportunity) {
    final isEnrolled = _enrolledOpportunityIds.contains(opportunity.id);
    final icon = IconHelper.getIconFromName(opportunity.iconName);
    final color = IconHelper.getColorFromHex(opportunity.color);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnrolled ? color : AppColors.borderDefault,
          width: isEnrolled ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  opportunity.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  opportunity.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        opportunity.location,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${opportunity.enrolledCount} enrolled',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _toggleEnrollment(opportunity),
            style: ElevatedButton.styleFrom(
              backgroundColor: isEnrolled ? AppColors.error : AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(isEnrolled ? 'Leave' : 'Join'),
          ),
        ],
      ),
    );
  }
}

