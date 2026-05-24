class UserItem {
  final String id;
  final String name;
  final String email;
  final String role;

  UserItem({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserItem.fromMap(Map<String, dynamic> map) {
    return UserItem(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      role: map['role'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }
}
