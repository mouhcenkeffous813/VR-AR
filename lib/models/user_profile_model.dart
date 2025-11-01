import 'dart:convert';

class UserProfileModel {
  final String id;
  final String email;
  final String? fullName;
  final String? username;
  final String? avatarUrl;
  final String? bio;
  final String? location;
  final String? portfolio;
  final Map<String, dynamic>? settings;
  final int points;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfileModel({
    required this.id,
    required this.email,
    this.fullName,
    this.username,
    this.avatarUrl,
    this.bio,
    this.location,
    this.portfolio,
    this.settings,
    this.points = 0,
    this.createdAt,
    this.updatedAt,
  });

  // Convert from JSON (Supabase)
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] ?? json['user_id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'],
      username: json['username'],
      avatarUrl: json['avatar_url'],
      bio: json['bio'],
      location: json['location'],
      portfolio: json['portfolio'],
      settings: json['settings'] != null 
          ? (json['settings'] is Map 
              ? Map<String, dynamic>.from(json['settings'])
              : json['settings'] is String
                  ? Map<String, dynamic>.from(jsonDecode(json['settings']))
                  : null)
          : null,
      points: json['points'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  // Convert to JSON (Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'username': username,
      'avatar_url': avatarUrl,
      'bio': bio,
      'location': location,
      'portfolio': portfolio,
      'settings': settings,
      'points': points,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Copy with method for updates
  UserProfileModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? username,
    String? avatarUrl,
    String? bio,
    String? location,
    String? portfolio,
    Map<String, dynamic>? settings,
    int? points,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      portfolio: portfolio ?? this.portfolio,
      settings: settings ?? this.settings,
      points: points ?? this.points,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
