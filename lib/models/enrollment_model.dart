class EnrollmentModel {
  final String id;
  final String userId;
  final String eventId;
  final DateTime enrolledAt;

  EnrollmentModel({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.enrolledAt,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      eventId: json['event_id'].toString(),
      enrolledAt: DateTime.parse(json['enrolled_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'event_id': eventId,
      'enrolled_at': enrolledAt.toIso8601String(),
    };
  }
}

