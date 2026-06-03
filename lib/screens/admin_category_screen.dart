import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/category_item.dart';
import '../providers/app_state.dart';

class AdminCategoryScreen extends StatelessWidget {
  const AdminCategoryScreen({super.key});

  Future<void> _showCategoryDialog(BuildContext context, {CategoryItem? item}) async {
    final nameController = TextEditingController(text: item?.name ?? '');
    final descriptionController = TextEditingController(text: item?.description ?? '');
    final formKey = GlobalKey<FormState>();
    final appState = Provider.of<AppState>(context, listen: false);
    final isEdit = item != null;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Ubah Kategori' : 'Buat Kategori Baru'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nama Kategori'),
                    validator: (value) => value == null || value.isEmpty ? 'Isi nama kategori' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Deskripsi'),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final category = CategoryItem(
                  id: item?.id ?? const Uuid().v4(),
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim(),
                );
                if (isEdit) {
                  await appState.updateCategory(category);
                } else {
                  await appState.createCategory(category);
                }
                if (context.mounted) Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEdit ? 'Kategori berhasil diubah' : 'Kategori berhasil dibuat'),
                  ),
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _deleteCategory(BuildContext context, String categoryId) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Kategori?'),
          content: const Text('Apakah Anda yakin ingin menghapus kategori ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                await Provider.of<AppState>(context, listen: false)
                    .deleteCategory(categoryId);
                if (context.mounted) Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kategori berhasil dihapus')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, appState, child) {
      return Scaffold(
        body: appState.categories.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.category,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada kategori',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: appState.categories.length,
                itemBuilder: (context, index) {
                  final category = appState.categories[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(Icons.label_outline),
                      title: Text(category.name),
                      subtitle: Text(category.description.isNotEmpty ? category.description : '-'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              appState.selectedCategory == category.id
                                  ? Icons.check_circle
                                  : Icons.check_circle_outline,
                              color: appState.selectedCategory == category.id ? Colors.green : null,
                            ),
                            tooltip: appState.selectedCategory == category.id ? 'Kategori terpilih' : 'Pilih kategori',
                            onPressed: () async {
                              await appState.setSelectedCategory(category.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Kategori "${category.name}" dipilih')),
                                );
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showCategoryDialog(context, item: category),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => _deleteCategory(context, category.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCategoryDialog(context),
          child: const Icon(Icons.add),
        ),
      );
    });
  }
}
