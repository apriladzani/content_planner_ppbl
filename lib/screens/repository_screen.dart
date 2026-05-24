import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/asset_item.dart';
import '../providers/app_state.dart';
import '../widgets/asset_card_widget.dart';

class RepositoryScreen extends StatelessWidget {
  const RepositoryScreen({super.key});

  Future<void> _showAssetDialog(BuildContext context, {AssetItem? item}) async {
    final nameController = TextEditingController(text: item?.assetName ?? '');
    final fileController = TextEditingController(text: item?.file ?? '');
    String type = item?.type ?? 'image';
    final formKey = GlobalKey<FormState>();
    final appState = Provider.of<AppState>(context, listen: false);

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(item == null ? 'Tambah Asset' : 'Ubah Asset'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Asset Name'),
                    validator: (value) => value == null || value.isEmpty ? 'Isi nama asset' : null,
                  ),
                  TextFormField(
                    controller: fileController,
                    decoration: const InputDecoration(labelText: 'File Path / URL'),
                    validator: (value) => value == null || value.isEmpty ? 'Isi path atau url' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: type,
                    items: const [
                      DropdownMenuItem(value: 'image', child: Text('Image')),
                      DropdownMenuItem(value: 'video', child: Text('Video')),
                      DropdownMenuItem(value: 'link', child: Text('Link')),
                    ],
                    onChanged: (value) {
                      if (value != null) type = value;
                    },
                    decoration: const InputDecoration(labelText: 'Type'),
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
                final newAsset = AssetItem(
                  id: item?.id ?? const Uuid().v4(),
                  assetName: nameController.text.trim(),
                  type: type,
                  file: fileController.text.trim(),
                );
                if (item == null) {
                  await appState.createAsset(newAsset);
                } else {
                  await appState.updateAsset(newAsset);
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
      return Column(
        children: [
          Expanded(
            child: appState.assets.isEmpty
                ? const Center(child: Text('Belum ada asset. Tambahkan repository baru.'))
                : ListView.builder(
                    itemCount: appState.assets.length,
                    itemBuilder: (context, index) {
                      final item = appState.assets[index];
                      return AssetCardWidget(
                        item: item,
                        onEdit: () => _showAssetDialog(context, item: item),
                        onDelete: () => appState.deleteAsset(item.id),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () => _showAssetDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Asset'),
            ),
          ),
        ],
      );
    });
  }
}
