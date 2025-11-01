class ClubMembershipModel {
  final String id;
  final String clubId;
  final String userId;
  final DateTime? joinedAt;

  ClubMembershipModel({
    required this.id,
    required this.clubId,
    required this.userId,
    this.joinedAt,
  });

  // Convert from JSON (Supabase)
  factory ClubMembershipModel.fromJson(Map<String, dynamic> json) {
    return ClubMembershipModel(
      id: json['id'].toString(),
      clubId: json['club_id'].toString(),
      userId: json['user_id'].toString(),
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'])
          : null,
    );
  }

  // Convert to JSON (Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'club_id': clubId,
      'user_id': userId,
      'joined_at': joinedAt?.toIso8601String(),
    };
  }
}

