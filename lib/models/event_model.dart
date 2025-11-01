class EventModel {
  final String id;
  final String categoryId;
  final String type;
  final String name;
  final String description;
  final DateTime eventDate;
  final String eventTime;
  final String color;

  EventModel({
    required this.id,
    required this.categoryId,
    required this.type,
    required this.name,
    required this.description,
    required this.eventDate,
    required this.eventTime,
    required this.color,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'].toString(),
      categoryId: json['category_id'].toString(),
      type: json['type'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      eventDate: DateTime.parse(json['event_date'] as String),
      eventTime: json['event_time'] as String,
      color: json['color'] as String? ?? '#194CBF',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'type': type,
      'name': name,
      'description': description,
      'event_date': eventDate.toIso8601String().split('T')[0],
      'event_time': eventTime,
      'color': color,
    };
  }
}

