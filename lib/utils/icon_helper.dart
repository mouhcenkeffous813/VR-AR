import 'package:flutter/material.dart';

class IconHelper {
  /// Convert icon name string to IconData
  static IconData getIconFromName(String iconName) {
    switch (iconName) {
      // Clubs icons
      case 'code':
        return Icons.code;
      case 'palette_outlined':
        return Icons.palette_outlined;
      case 'music_note':
        return Icons.music_note;
      case 'sports_soccer':
        return Icons.sports_soccer;
      case 'menu_book':
        return Icons.menu_book;
      
      // Volunteering icons
      case 'local_hospital_outlined':
        return Icons.local_hospital_outlined;
      case 'school_outlined':
        return Icons.school_outlined;
      case 'eco_outlined':
        return Icons.eco_outlined;
      case 'volunteer_activism':
        return Icons.volunteer_activism;
      case 'food_bank_outlined':
        return Icons.food_bank_outlined;
      
      // Default
      default:
        return Icons.group;
    }
  }

  /// Convert color hex string to Color
  static Color getColorFromHex(String hexString) {
    try {
      final hexCode = hexString.replaceFirst('#', '0xFF');
      return Color(int.parse(hexCode));
    } catch (e) {
      return const Color(0xFF194CBF); // Default blue
    }
  }
}

