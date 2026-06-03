class CategoryItem {
  final String id;
  final String name;
  final String description;

  CategoryItem({
    required this.id,
    required this.name,
    required this.description,
  });

  factory CategoryItem.fromMap(Map<String, dynamic> map) {
    return CategoryItem(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}
