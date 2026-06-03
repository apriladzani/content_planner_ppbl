import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/content_item.dart';
import '../providers/app_state.dart';
import '../widgets/content_card_widget.dart';

class ContentScreen extends StatelessWidget {
  const ContentScreen({super.key});

  Future<void> _showContentDialog(BuildContext context, {ContentItem? item}) async {
    final titleController = TextEditingController(text: item?.title ?? '');
    final descriptionController = TextEditingController(text: item?.description ?? '');
    final deadlineController = TextEditingController(text: item?.deadline ?? '');
    final appState = Provider.of<AppState>(context, listen: false);
    final categories = appState.categories;
    String categoryId = item?.categoryId ?? (categories.isNotEmpty ? categories.first.id : '');
    String type = item?.type ?? 'video';
    String status = item?.status ?? 'draft';
    DateTime? selectedDeadline = item?.deadline.isNotEmpty == true
        ? DateTime.tryParse(item!.deadline)
        : null;
    final formKey = GlobalKey<FormState>();
    final hasCategories = categories.isNotEmpty;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(item == null ? 'Tambah Content' : 'Ubah Content'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) => value == null || value.isEmpty ? 'Isi title' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: deadlineController,
                    decoration: const InputDecoration(labelText: 'Deadline (YYYY-MM-DD)'),
                    readOnly: true,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDeadline ?? DateTime.now(),
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                      );
                      if (picked != null) {
                        selectedDeadline = picked;
                        deadlineController.text = picked.toIso8601String().split('T').first;
                      }
                    },
                    validator: (value) => value == null || value.isEmpty ? 'Pilih deadline' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    validator: (value) => value == null || value.isEmpty ? 'Isi description' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: type,
                    items: const [
                      DropdownMenuItem(value: 'video', child: Text('Video')),
                      DropdownMenuItem(value: 'image', child: Text('Image')),
                      DropdownMenuItem(value: 'article', child: Text('Article')),
                    ],
                    onChanged: (value) {
                      if (value != null) type = value;
                    },
                    decoration: const InputDecoration(labelText: 'Type'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: status,
                    items: const [
                      DropdownMenuItem(value: 'draft', child: Text('Draft')),
                      DropdownMenuItem(value: 'publish', child: Text('Publish')),
                      DropdownMenuItem(value: 'scheduled', child: Text('Scheduled')),
                    ],
                    onChanged: (value) {
                      if (value != null) status = value;
                    },
                    decoration: const InputDecoration(labelText: 'Status'),
                  ),
                  const SizedBox(height: 12),
                  if (!hasCategories)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Belum ada kategori. Tambahkan kategori terlebih dahulu melalui menu admin.',
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  DropdownButtonFormField<String>(
                    value: hasCategories ? (categoryId.isNotEmpty ? categoryId : categories.first.id) : null,
                    items: categories
                        .map((category) => DropdownMenuItem(
                              value: category.id,
                              child: Text(category.name),
                            ))
                        .toList(),
                    onChanged: hasCategories
                        ? (value) {
                            if (value != null) categoryId = value;
                          }
                        : null,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    validator: (value) {
                      if (!hasCategories) return null;
                      return value == null || value.isEmpty ? 'Pilih kategori' : null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: hasCategories
                  ? () async {
                      if (!formKey.currentState!.validate()) return;
                      final newContent = ContentItem(
                        id: item?.id ?? const Uuid().v4(),
                        title: titleController.text.trim(),
                        type: type,
                        status: status,
                        description: descriptionController.text.trim(),
                        deadline: deadlineController.text.trim(),
                        categoryId: categoryId,
                      );
                      if (item == null) {
                        await appState.createContent(newContent);
                      } else {
                        await appState.updateContent(newContent);
                      }
                      Navigator.pop(context);
                    }
                  : null,
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
      return Column(
        children: [
          Expanded(
            child: appState.contents.isEmpty
                ? const Center(
                    child: Text('Belum ada content. Tambahkan content baru.'),
                  )
                : ListView.builder(
                    itemCount: appState.contents.length,
                    itemBuilder: (context, index) {
                      final item = appState.contents[index];
                      return ContentCardWidget(
                        item: item,
                        categoryName: appState.getCategoryName(item.categoryId),
                        onEdit: () => _showContentDialog(context, item: item),
                        onDelete: () => appState.deleteContent(item.id),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () => _showContentDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Content'),
            ),
          ),
        ],
      );
    });
  }
}
