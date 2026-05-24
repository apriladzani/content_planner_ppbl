import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/user_item.dart';
import '../models/workspace_item.dart';
import '../providers/app_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _showWorkspaceDialog(BuildContext context, {WorkspaceItem? item}) async {
    final nameController = TextEditingController(text: item?.workspaceName ?? '');
    final descriptionController = TextEditingController(text: item?.description ?? '');
    final formKey = GlobalKey<FormState>();
    final appState = Provider.of<AppState>(context, listen: false);
    final isEdit = item != null;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Ubah Workspace' : 'Tambah Workspace'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Workspace Name'),
                    validator: (value) => value == null || value.isEmpty ? 'Isi nama workspace' : null,
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 2,
                    validator: (value) => value == null || value.isEmpty ? 'Isi description' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final workspace = WorkspaceItem(
                  id: item?.id ?? const Uuid().v4(),
                  workspaceName: nameController.text.trim(),
                  description: descriptionController.text.trim(),
                );
                if (isEdit) {
                  await appState.updateWorkspace(workspace);
                } else {
                  await appState.createWorkspace(workspace);
                }
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showUserDialog(BuildContext context, {UserItem? item}) async {
    final nameController = TextEditingController(text: item?.name ?? '');
    final emailController = TextEditingController(text: item?.email ?? '');
    String role = item?.role ?? 'user';
    final formKey = GlobalKey<FormState>();
    final appState = Provider.of<AppState>(context, listen: false);

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(item == null ? 'Tambah User' : 'Ubah User'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nama'),
                    validator: (value) => value == null || value.isEmpty ? 'Isi nama' : null,
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) => value == null || value.isEmpty ? 'Isi email' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: role,
                    items: const [
                      DropdownMenuItem(value: 'user', child: Text('User')),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    ],
                    onChanged: (value) {
                      if (value != null) role = value;
                    },
                    decoration: const InputDecoration(labelText: 'Role'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final user = UserItem(
                  id: item?.id ?? const Uuid().v4(),
                  name: nameController.text.trim(),
                  email: emailController.text.trim().toLowerCase(),
                  role: role,
                );
                if (item == null) {
                  await appState.createUser(user);
                } else {
                  await appState.updateUser(user);
                }
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, appState, child) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Nama: ${appState.currentUser?.name ?? '-'}'),
                    Text('Email: ${appState.currentUser?.email ?? '-'}'),
                    Text('Role: ${appState.role}'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: appState.logout,
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Workspace', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Workspace aktif: ${appState.workspaceId ?? 'Tidak ada'}'),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Join dengan Workspace ID',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (value) async {
                        final success = await appState.joinWorkspace(value.trim());
                        if (!success) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Workspace ID tidak ditemukan')));
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _showWorkspaceDialog(context),
                      child: const Text('Buat Workspace Baru'),
                    ),
                    const SizedBox(height: 12),
                    ...appState.workspaces.map((workspace) {
                      return ListTile(
                        title: Text(workspace.workspaceName),
                        subtitle: Text(workspace.description),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.deepPurple),
                              onPressed: () => _showWorkspaceDialog(context, item: workspace),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => appState.deleteWorkspace(workspace.id),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (appState.role == 'admin')
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Manajemen User', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _showUserDialog(context),
                        child: const Text('Tambah User'),
                      ),
                      const SizedBox(height: 12),
                      ...appState.users.map((user) {
                        return ListTile(
                          title: Text(user.name),
                          subtitle: Text('${user.email} • ${user.role}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showUserDialog(context, item: user),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => appState.deleteUser(user.id),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
