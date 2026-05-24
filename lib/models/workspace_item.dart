class WorkspaceItem {
  final String id;
  final String workspaceName;
  final String description;

  WorkspaceItem({
    required this.id,
    required this.workspaceName,
    required this.description,
  });

  factory WorkspaceItem.fromMap(Map<String, dynamic> map) {
    return WorkspaceItem(
      id: map['id'] as String,
      workspaceName: map['workspaceName'] as String,
      description: map['description'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workspaceName': workspaceName,
      'description': description,
    };
  }
}
