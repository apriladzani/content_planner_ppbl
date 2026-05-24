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
    String type = item?.type ?? 'video';
    String status = item?.status ?? 'draft';
    DateTime? selectedDeadline = item?.deadline.isNotEmpty == true
        ? DateTime.tryParse(item!.deadline)
        : null;
    final formKey = GlobalKey<FormState>();
    final appState = Provider.of<AppState>(context, listen: false);

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
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final newContent = ContentItem(
                  id: item?.id ?? const Uuid().v4(),
                  title: titleController.text.trim(),
                  type: type,
                  status: status,
                  description: descriptionController.text.trim(),
                  deadline: deadlineController.text.trim(),
                );
                if (item == null) {
                  await appState.createContent(newContent);
                } else {
                  await appState.updateContent(newContent);
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
      final hasWorkspace = appState.workspaceId != null;
      return Column(
        children: [
          if (!hasWorkspace)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple),
              ),
              child: const Text(
                'Anda harus membuat atau bergabung ke workspace terlebih dahulu sebelum membuat content planner.',
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
          Expanded(
            child: appState.contents.isEmpty
                ? Center(
                    child: Text(
                      hasWorkspace
                          ? 'Belum ada content. Tambahkan content baru.'
                          : 'Belum ada content. Buat atau join workspace dulu.',
                    ),
                  )
                : ListView.builder(
                    itemCount: appState.contents.length,
                    itemBuilder: (context, index) {
                      final item = appState.contents[index];
                      return ContentCardWidget(
                        item: item,
                        onEdit: () => _showContentDialog(context, item: item),
                        onDelete: () => appState.deleteContent(item.id),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: hasWorkspace ? () => _showContentDialog(context) : null,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Content'),
            ),
          ),
        ],
      );
    });
  }
}
