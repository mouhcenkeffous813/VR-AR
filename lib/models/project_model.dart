class ProjectModel {
  final String id;
  final String title;
  final String description;
  final String collaborators; // Format: "3/5 Collaborators"
  final String? imagePath;
  final String? location;
  final String? duration;
  final String? startDate;
  final List<String>? skillsRequired;
  final String? createdBy; // user_id
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.collaborators,
    this.imagePath,
    this.location,
    this.duration,
    this.startDate,
    this.skillsRequired,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  // Convert from JSON (Supabase)
  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      collaborators: json['collaborators'] ?? '0/0 Collaborators',
      imagePath: json['image_path'],
      location: json['location'],
      duration: json['duration'],
      startDate: json['start_date'],
      skillsRequired: json['skills_required'] != null
          ? List<String>.from(json['skills_required'] is String
              ? json['skills_required'].split(',')
              : json['skills_required'])
          : null,
      createdBy: json['created_by'],
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
      'title': title,
      'description': description,
      'collaborators': collaborators,
      'image_path': imagePath,
      'location': location,
      'duration': duration,
      'start_date': startDate,
      'skills_required': skillsRequired?.join(','),
      'created_by': createdBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

