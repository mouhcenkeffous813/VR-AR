class QuestionModel {
  final String id;
  final String userId;
  final String name;
  final String category;
  final String question;
  final int replies;
  final DateTime createdAt;

  QuestionModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.question,
    required this.replies,
    required this.createdAt,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      name: json['name'] as String,
      category: json['category'] as String,
      question: json['question'] as String,
      replies: json['replies'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'category': category,
      'question': question,
      'replies': replies,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

