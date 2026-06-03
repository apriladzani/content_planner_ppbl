import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import '../models/asset_item.dart';
import '../models/category_item.dart';
import '../models/content_item.dart';
import '../models/user_item.dart';
import 'database_factory.dart';

class DBService {
  static Database? _database;
  static final StoreRef<String, Map<String, dynamic>> _contentStore = stringMapStoreFactory.store('contents');
  static final StoreRef<String, Map<String, dynamic>> _assetStore = stringMapStoreFactory.store('assets');
  static final StoreRef<String, Map<String, dynamic>> _categoryStore = stringMapStoreFactory.store('categories');
  static final StoreRef<String, Map<String, dynamic>> _workspaceStore = stringMapStoreFactory.store('workspaces');
  static final StoreRef<String, Map<String, dynamic>> _userStore = stringMapStoreFactory.store('users');

  static Future<Database> get database async {
    if (_database != null) return _database!;
    await initDb();
    return _database!;
  }

  static Future<void> initDb() async {
    if (_database != null) return;
    final dbPath = kIsWeb
        ? 'content_planner.db'
        : p.join((await getApplicationDocumentsDirectory()).path, 'content_planner.db');
    _database = await databaseFactory.openDatabase(dbPath);
  }

  static Future<List<ContentItem>> fetchContents() async {
    final db = await database;
    final finder = Finder(sortOrders: [SortOrder('title')]);
    final records = await _contentStore.find(db, finder: finder);
    return records.map((snapshot) {
      final data = Map<String, dynamic>.from(snapshot.value);
      data['id'] = snapshot.key;
      return ContentItem.fromMap(data);
    }).toList();
  }

  static Future<void> insertContent(ContentItem item) async {
    final db = await database;
    await _contentStore.record(item.id).put(db, item.toMap());
  }

  static Future<void> updateContent(ContentItem item) async {
    final db = await database;
    await _contentStore.record(item.id).update(db, item.toMap());
  }

  static Future<void> deleteContent(String id) async {
    final db = await database;
    await _contentStore.record(id).delete(db);
  }

  static Future<List<AssetItem>> fetchAssets() async {
    final db = await database;
    final finder = Finder(sortOrders: [SortOrder('assetName')]);
    final records = await _assetStore.find(db, finder: finder);
    return records.map((snapshot) {
      final data = Map<String, dynamic>.from(snapshot.value);
      data['id'] = snapshot.key;
      return AssetItem.fromMap(data);
    }).toList();
  }

  static Future<void> insertAsset(AssetItem item) async {
    final db = await database;
    await _assetStore.record(item.id).put(db, item.toMap());
  }

  static Future<void> updateAsset(AssetItem item) async {
    final db = await database;
    await _assetStore.record(item.id).update(db, item.toMap());
  }

  static Future<void> deleteAsset(String id) async {
    final db = await database;
    await _assetStore.record(id).delete(db);
  }

  static Future<List<CategoryItem>> fetchCategories() async {
    final db = await database;
    final finder = Finder(sortOrders: [SortOrder('name')]);
    final records = await _categoryStore.find(db, finder: finder);
    return records.map((snapshot) {
      final data = Map<String, dynamic>.from(snapshot.value);
      data['id'] = snapshot.key;
      return CategoryItem.fromMap(data);
    }).toList();
  }

  static Future<void> insertCategory(CategoryItem item) async {
    final db = await database;
    await _categoryStore.record(item.id).put(db, item.toMap());
  }

  static Future<void> updateCategory(CategoryItem item) async {
    final db = await database;
    await _categoryStore.record(item.id).update(db, item.toMap());
  }

  static Future<void> deleteCategory(String id) async {
    final db = await database;
    await _categoryStore.record(id).delete(db);
  }

  static Future<List<UserItem>> fetchUsers() async {
    final db = await database;
    final finder = Finder(sortOrders: [SortOrder('name')]);
    final records = await _userStore.find(db, finder: finder);
    return records.map((snapshot) {
      final data = Map<String, dynamic>.from(snapshot.value);
      data['id'] = snapshot.key;
      return UserItem.fromMap(data);
    }).toList();
  }

  static Future<void> insertUser(UserItem item) async {
    final db = await database;
    await _userStore.record(item.id).put(db, item.toMap());
  }

  static Future<void> updateUser(UserItem item) async {
    final db = await database;
    await _userStore.record(item.id).update(db, item.toMap());
  }

  static Future<void> deleteUser(String id) async {
    final db = await database;
    await _userStore.record(id).delete(db);
  }
}
