class ContentItem {
  final String id;
  final String title;
  final String type;
  final String status;
  final String description;
  final String deadline;

  ContentItem({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.description,
    required this.deadline,
  });

  factory ContentItem.fromMap(Map<String, dynamic> map) {
    return ContentItem(
      id: map['id'] as String,
      title: map['title'] as String,
      type: map['type'] as String,
      status: map['status'] as String,
      description: map['description'] as String,
      deadline: map['deadline'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'status': status,
      'description': description,
      'deadline': deadline,
    };
  }
}
