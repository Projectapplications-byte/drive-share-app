import 'dart:io';

import 'package:flutter/material.dart';

import '../models/recent_file.dart';

class TextEditorScreen extends StatefulWidget {
  const TextEditorScreen({super.key, required this.file});

  final RecentFile file;

  @override
  State<TextEditorScreen> createState() => _TextEditorScreenState();
}

class _TextEditorScreenState extends State<TextEditorScreen> {
  late final TextEditingController _controller;
  late Future<String> _contentFuture;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _contentFuture = _load();
  }

  Future<String> _load() async {
    final content = await File(widget.file.localPath).readAsString();
    _controller.text = content;
    return content;
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await File(widget.file.localPath).writeAsString(_controller.text);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to save: $error')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.file.name),
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
        child: FutureBuilder<String>(
          future: _contentFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Unable to open text file: ${snapshot.error}'),
                ),
              );
            }
            return TextField(
              controller: _controller,
              expands: true,
              maxLines: null,
              minLines: null,
              keyboardType: TextInputType.multiline,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            );
          },
        ),
      ),
    );
  }
}
