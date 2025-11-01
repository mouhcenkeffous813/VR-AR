class OpportunityModel {
  final String id;
  final String company;
  final String title;
  final String location;
  final String type; // Exchange Programs, Internships, Volunteering, Projects
  final List<String> tags;
  final String? image;
  final String? description;
  final String? logoColor;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OpportunityModel({
    required this.id,
    required this.company,
    required this.title,
    required this.location,
    required this.type,
    required this.tags,
    this.image,
    this.description,
    this.logoColor,
    this.createdAt,
    this.updatedAt,
  });

  // Convert from JSON (Supabase)
  factory OpportunityModel.fromJson(Map<String, dynamic> json) {
    return OpportunityModel(
      id: json['id'].toString(),
      company: json['company'] ?? '',
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      type: json['type'] ?? '',
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] is String
              ? json['tags'].split(',')
              : json['tags'])
          : [],
      image: json['image'],
      description: json['description'],
      logoColor: json['logo_color'],
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
      'company': company,
      'title': title,
      'location': location,
      'type': type,
      'tags': tags,
      'image': image,
      'description': description,
      'logo_color': logoColor,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Convert to Map for existing UI (backward compatibility)
  Map<String, dynamic> toMap() {
    return {
      'id': int.tryParse(id) ?? 0,
      'company': company,
      'title': title,
      'location': location,
      'type': type,
      'tags': tags,
      'image': image,
      'logoColor': logoColor != null
          ? _parseColor(logoColor!)
          : null,
    };
  }

  // Helper to parse color string
  int? _parseColor(String colorString) {
    if (colorString.startsWith('0xFF') || colorString.startsWith('#')) {
      return int.tryParse(
        colorString.replaceAll('0xFF', '').replaceAll('#', ''),
        radix: 16,
      );
    }
    return null;
  }
}

