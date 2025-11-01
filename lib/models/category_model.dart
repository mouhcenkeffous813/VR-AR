import 'package:flutter/material.dart';
import 'package:youth_center/utils/app_colors.dart';

class CategoryModel {
  final String name;
  final IconData icon;
  final Color iconColor;

  const CategoryModel({
    required this.name,
    required this.icon,
    this.iconColor = AppColors.primary,
  });
}

class CategoryData {
  static const List<CategoryModel> categories = [
    CategoryModel(
      name: 'Sport Activities',
      icon: Icons.sports_soccer,
    ),
    CategoryModel(
      name: 'Digital Design Lab',
      icon: Icons.design_services,
    ),
    CategoryModel(
      name: 'Robotics Garage',
      icon: Icons.memory,
    ),
    CategoryModel(
      name: 'Dev Room',
      icon: Icons.code,
    ),
    CategoryModel(
      name: 'Innovation Space',
      icon: Icons.lightbulb,
    ),
    CategoryModel(
      name: 'Startup Corner',
      icon: Icons.business,
    ),
    CategoryModel(
      name: 'Library',
      icon: Icons.library_books,
    ),
    CategoryModel(
      name: 'Creative Media',
      icon: Icons.videocam,
    ),
  ];
}

