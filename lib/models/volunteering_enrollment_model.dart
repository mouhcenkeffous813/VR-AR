class VolunteeringEnrollmentModel {
  final String id;
  final String opportunityId;
  final String userId;
  final DateTime? enrolledAt;

  VolunteeringEnrollmentModel({
    required this.id,
    required this.opportunityId,
    required this.userId,
    this.enrolledAt,
  });

  // Convert from JSON (Supabase)
  factory VolunteeringEnrollmentModel.fromJson(Map<String, dynamic> json) {
    return VolunteeringEnrollmentModel(
      id: json['id'].toString(),
      opportunityId: json['opportunity_id'].toString(),
      userId: json['user_id'].toString(),
      enrolledAt: json['enrolled_at'] != null
          ? DateTime.parse(json['enrolled_at'])
          : null,
    );
  }

  // Convert to JSON (Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'opportunity_id': opportunityId,
      'user_id': userId,
      'enrolled_at': enrolledAt?.toIso8601String(),
    };
  }
}

