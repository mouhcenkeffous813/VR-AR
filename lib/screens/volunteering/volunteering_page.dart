import 'package:flutter/material.dart';
import 'package:youth_center/utils/app_colors.dart';

class VolunteeringPage extends StatelessWidget {
  const VolunteeringPage({super.key});

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
            _buildOpportunityCard(
              icon: Icons.local_hospital_outlined,
              title: 'Healthcare Support',
              description: 'Assist in community health programs and clinics',
              location: 'Various locations',
              color: AppColors.error,
            ),
            const SizedBox(height: 12),
            _buildOpportunityCard(
              icon: Icons.school_outlined,
              title: 'Education Tutoring',
              description: 'Help students with homework and learning support',
              location: 'Youth Center',
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            _buildOpportunityCard(
              icon: Icons.eco_outlined,
              title: 'Environmental Cleanup',
              description: 'Participate in beach and park cleaning initiatives',
              location: 'Public spaces',
              color: AppColors.success,
            ),
            const SizedBox(height: 12),
            _buildOpportunityCard(
              icon: Icons.volunteer_activism,
              title: 'Elderly Care',
              description: 'Visit and assist elderly members of the community',
              location: 'Care centers',
              color: AppColors.secondary,
            ),
            const SizedBox(height: 12),
            _buildOpportunityCard(
              icon: Icons.food_bank_outlined,
              title: 'Food Distribution',
              description: 'Help organize and distribute food to those in need',
              location: 'Community centers',
              color: AppColors.warning,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpportunityCard({
    required IconData icon,
    required String title,
    required String description,
    required String location,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDefault, width: 1),
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
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
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
                    Text(
                      location,
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
          const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

