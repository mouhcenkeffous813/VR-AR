import 'package:flutter/material.dart';
import 'package:youth_center/utils/app_colors.dart';

class CategoryModel {
  final String? id;
  final String name;
  final IconData icon;
  final Color iconColor;

  const CategoryModel({
    this.id,
    required this.name,
    required this.icon,
    this.iconColor = AppColors.primary,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    // Map icon_name to IconData
    IconData iconData = Icons.category;
    final iconName = json['icon_name'] as String? ?? 'category';
    
    switch (iconName) {
      case 'sports_soccer':
        iconData = Icons.sports_soccer;
        break;
      case 'design_services':
        iconData = Icons.design_services;
        break;
      case 'memory':
        iconData = Icons.memory;
        break;
      case 'code':
        iconData = Icons.code;
        break;
      case 'lightbulb':
        iconData = Icons.lightbulb;
        break;
      case 'business':
        iconData = Icons.business;
        break;
      case 'library_books':
        iconData = Icons.library_books;
        break;
      case 'videocam':
        iconData = Icons.videocam;
        break;
      default:
        iconData = Icons.category;
    }

    // Parse color from hex string
    Color color = AppColors.primary;
    try {
      final colorStr = json['icon_color'] as String? ?? '#194CBF';
      color = Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
    } catch (e) {
      color = AppColors.primary;
    }

    return CategoryModel(
      id: json['id']?.toString(),
      name: json['name'] as String,
      icon: iconData,
      iconColor: color,
    );
  }

  Map<String, dynamic> toJson() {
    // Map IconData to icon_name
    String iconName = 'category';
    if (icon == Icons.sports_soccer) iconName = 'sports_soccer';
    else if (icon == Icons.design_services) iconName = 'design_services';
    else if (icon == Icons.memory) iconName = 'memory';
    else if (icon == Icons.code) iconName = 'code';
    else if (icon == Icons.lightbulb) iconName = 'lightbulb';
    else if (icon == Icons.business) iconName = 'business';
    else if (icon == Icons.library_books) iconName = 'library_books';
    else if (icon == Icons.videocam) iconName = 'videocam';

    return {
      'id': id,
      'name': name,
      'icon_name': iconName,
      'icon_color': '#${iconColor.value.toRadixString(16).substring(2)}',
    };
  }
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
