import 'package:flutter/material.dart';
import 'package:youth_center/utils/app_colors.dart';

class OpportunitiesPage extends StatelessWidget {
  const OpportunitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Opportunities',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'Opportunities Page',
          style: TextStyle(fontSize: 20, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
