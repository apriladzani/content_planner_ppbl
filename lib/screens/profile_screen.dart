import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/user_item.dart';
import '../providers/app_state.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});


  Future<void> _showUserDialog(BuildContext context, {UserItem? item}) async {
    final nameController = TextEditingController(text: item?.name ?? '');
    final emailController = TextEditingController(text: item?.email ?? '');
    final currentRole = item?.role ?? 'user';
    final isAdminEditing = Provider.of<AppState>(context, listen: false).role == 'admin';
    String role = currentRole;
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
                  if (item != null && isAdminEditing)
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
                  // Password admin panel tidak disediakan di UI saat ini.
                  // Gunakan kosong agar tidak memaksa perubahan UI besar.
                  passwordHash: item?.passwordHash ?? '',
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
                      onPressed: appState.currentUser == null
                          ? null
                          : () {
                              final user = appState.currentUser!;
                              _showUserDialog(
                                context,
                                item: user,
                              );
                            },
                      child: const Text('Edit Profil'),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () async {
                        await appState.logout();
                        if (!context.mounted) return;
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      },
                      child: const Text('Logout'),
                    ),

                  ],
                ),
              ),
            ),
            // Workspace dan manajemen user dihapus dari halaman profile agar admin hanya fokus pada edit profil diri sendiri.

          ],
        ),
      );
    });
  }
}
