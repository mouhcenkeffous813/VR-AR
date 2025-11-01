class SuggestionModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime createdAt;

  SuggestionModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  factory SuggestionModel.fromJson(Map<String, dynamic> json) {
    return SuggestionModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

