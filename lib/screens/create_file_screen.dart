import 'package:flutter/material.dart';

import '../main.dart';

class CreateFileScreen extends StatefulWidget {
  const CreateFileScreen({super.key});

  @override
  State<CreateFileScreen> createState() => _CreateFileScreenState();
}

class _CreateFileScreenState extends State<CreateFileScreen> {
  final TextEditingController _nameController = TextEditingController(
    text: 'untitled.txt',
  );
  final TextEditingController _contentController = TextEditingController();
  bool _isSaving = false;

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showSnack('Enter a file name.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final file = await Drive2ShareScope.of(context).fileImportService
          .createTextFile(fileName: name, content: _contentController.text);
      if (!mounted) return;
      Navigator.of(context).pop(file);
    } catch (error) {
      _showSnack('Unable to create file: $error');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create file'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Save',
            onPressed: _isSaving ? null : _save,
            icon: _isSaving
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'File name',
                  prefixIcon: Icon(Icons.insert_drive_file_outlined),
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  expands: true,
                  maxLines: null,
                  minLines: null,
                  keyboardType: TextInputType.multiline,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.note_add_outlined),
                  label: const Text('Create file'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
