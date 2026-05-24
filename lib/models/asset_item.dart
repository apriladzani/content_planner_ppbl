class AssetItem {
  final String id;
  final String assetName;
  final String type;
  final String file;

  AssetItem({
    required this.id,
    required this.assetName,
    required this.type,
    required this.file,
  });

  factory AssetItem.fromMap(Map<String, dynamic> map) {
    return AssetItem(
      id: map['id'] as String,
      assetName: map['assetName'] as String,
      type: map['type'] as String,
      file: map['file'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'assetName': assetName,
      'type': type,
      'file': file,
    };
  }
}
