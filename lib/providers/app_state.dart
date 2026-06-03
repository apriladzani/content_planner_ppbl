import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/asset_item.dart';
import '../models/category_item.dart';
import '../models/content_item.dart';
import '../models/user_item.dart';
import '../models/workspace_item.dart';
import '../services/db_service.dart';
import '../services/pref_service.dart';


class AppState extends ChangeNotifier {
  final Uuid _uuid = const Uuid();

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  bool isInitializing = true;

  bool isLogin = false;
  String role = 'user';

  String? userId;
  String? workspaceId;
  UserItem? currentUser;

  List<ContentItem> contents = [];
  List<AssetItem> assets = [];
  List<CategoryItem> categories = [];
  List<WorkspaceItem> workspaces = [];
  List<UserItem> users = [];

  Future<void> initialize() async {
    await PrefService.init();
    await DBService.initDb();
    await loadAll();
    isLogin = PrefService.isLogin;
    userId = PrefService.userId;
    role = PrefService.role ?? 'user';
    workspaceId = PrefService.workspaceId;
    currentUser = users.where((u) => u.id == userId).isNotEmpty
        ? users.where((u) => u.id == userId).first
        : null;
    isInitializing = false;
    notifyListeners();
  }

  Future<void> loadAll() async {
    contents = await DBService.fetchContents();
    assets = await DBService.fetchAssets();
    categories = await DBService.fetchCategories();
    workspaces = await DBService.fetchWorkspaces();
    users = await DBService.fetchUsers();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    await loadAll();
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPassword = password;

    final matches = users
        .where((user) => user.email.trim().toLowerCase() == normalizedEmail)
        .toList();
    if (matches.isEmpty) return false;

    final user = matches.first;
    final passwordHash = _hashPassword(normalizedPassword);
    if (user.passwordHash != passwordHash) return false;

    userId = user.id;
    role = user.role;
    currentUser = user;
    isLogin = true;
    await PrefService.saveLogin(userId!, role);
    notifyListeners();
    return true;
  }

  Future<bool> register(String name, String email, String role, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    final exists = users.any(
      (user) => user.email.trim().toLowerCase() == normalizedEmail,
    );
    if (exists) {
      return false;
    }

    final user = UserItem(
      id: _uuid.v4(),
      name: name.trim(),
      email: normalizedEmail,
      role: role,
      passwordHash: _hashPassword(password),
    );
    await DBService.insertUser(user);
    await loadAll();
    return await login(normalizedEmail, password);
  }


  Future<void> logout() async {
    isLogin = false;
    userId = null;
    role = 'user';
    currentUser = null;
    workspaceId = null;
    await PrefService.logout();
    notifyListeners();
  }

  Future<void> createContent(ContentItem item) async {
    await DBService.insertContent(item);
    await loadAll();
  }

  Future<void> updateContent(ContentItem item) async {
    await DBService.updateContent(item);
    await loadAll();
  }

  Future<void> deleteContent(String id) async {
    await DBService.deleteContent(id);
    await loadAll();
  }

  Future<void> createAsset(AssetItem item) async {
    await DBService.insertAsset(item);
    await loadAll();
  }

  Future<void> updateAsset(AssetItem item) async {
    await DBService.updateAsset(item);
    await loadAll();
  }

  Future<void> deleteAsset(String id) async {
    await DBService.deleteAsset(id);
    await loadAll();
  }

  Future<void> createCategory(CategoryItem item) async {
    await DBService.insertCategory(item);
    await loadAll();
  }

  Future<void> updateCategory(CategoryItem item) async {
    await DBService.updateCategory(item);
    await loadAll();
  }

  Future<void> deleteCategory(String id) async {
    await DBService.deleteCategory(id);
    await loadAll();
  }

  Future<void> createWorkspace(WorkspaceItem item) async {
    await DBService.insertWorkspace(item);
    workspaceId = item.id;
    await PrefService.setWorkspaceId(item.id);
    await loadAll();
  }

  Future<void> updateWorkspace(WorkspaceItem item) async {
    await DBService.updateWorkspace(item);
    if (workspaceId == item.id) {
      workspaceId = item.id;
      await PrefService.setWorkspaceId(item.id);
    }
    await loadAll();
  }

  Future<void> deleteWorkspace(String id) async {
    if (workspaceId == id) {
      workspaceId = null;
      await PrefService.setWorkspaceId(null);
    }
    await DBService.deleteWorkspace(id);
    await loadAll();
  }

  Future<bool> joinWorkspace(String id) async {
    final exists = workspaces.any((workspace) => workspace.id == id);
    if (!exists) return false;
    workspaceId = id;
    await PrefService.setWorkspaceId(id);
    notifyListeners();
    return true;
  }

  Future<bool> createUser(UserItem item) async {
    final duplicate = users.any(
      (user) => user.email.trim().toLowerCase() == item.email.trim().toLowerCase(),
    );
    if (duplicate) return false;
    await DBService.insertUser(item);
    await loadAll();
    return true;
  }

  Future<void> updateUser(UserItem item) async {
    await DBService.updateUser(item);
    if (item.id == userId) {
      currentUser = item;
      role = item.role;
      await PrefService.saveLogin(item.id, item.role);
    }
    await loadAll();
  }

  Future<void> deleteUser(String id) async {
    await DBService.deleteUser(id);
    if (id == userId) {
      await logout();
      return;
    }
    await loadAll();
  }

  int get totalContent => contents.length;
  int get totalAsset => assets.length;
  int get totalCategories => categories.length;
  int get totalUsers => users.length;
  int get totalWorkspaces => workspaces.length;

  int countContentByStatus(String status) {
    return contents.where((content) => content.status == status).length;
  }

  String getCategoryName(String categoryId) {
    final category = categories.firstWhere(
      (item) => item.id == categoryId,
      orElse: () => CategoryItem(id: '', name: '-', description: ''),
    );
    return category.name.isNotEmpty ? category.name : '-';
  }

  WorkspaceItem? get currentWorkspace {
    return workspaces.firstWhere(
      (workspace) => workspace.id == workspaceId,
      orElse: () => WorkspaceItem(id: '', workspaceName: '', description: ''),
    );
  }
}
