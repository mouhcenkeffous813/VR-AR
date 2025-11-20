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
      case 'medical_services':
        iconData = Icons.medical_services;
        break;
      case 'science':
        iconData = Icons.science;
        break;
      case 'engineering':
        iconData = Icons.engineering;
        break;
      case 'build':
        iconData = Icons.build;
        break;
      case 'crop_free':
        iconData = Icons.crop_free;
        break;
      case 'architecture':
        iconData = Icons.architecture;
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
    if (icon == Icons.medical_services) iconName = 'medical_services';
    else if (icon == Icons.science) iconName = 'science';
    else if (icon == Icons.engineering) iconName = 'engineering';
    else if (icon == Icons.build) iconName = 'build';
    else if (icon == Icons.crop_free) iconName = 'crop_free';
    else if (icon == Icons.architecture) iconName = 'architecture';

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
      name: 'Medicine',
      icon: Icons.medical_services,
    ),
    CategoryModel(
      name: 'Chemistry',
      icon: Icons.science,
    ),
    CategoryModel(
      name: 'Engineering',
      icon: Icons.engineering,
    ),
    CategoryModel(
      name: 'Mechanics',
      icon: Icons.build,
    ),
    CategoryModel(
      name: 'Geometry',
      icon: Icons.crop_free,
    ),
    CategoryModel(
      name: 'Architecture',
      icon: Icons.architecture,
    ),
  ];
}
