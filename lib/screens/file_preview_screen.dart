import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../main.dart';
import '../models/recent_file.dart';
import '../utils/format_utils.dart';
import '../utils/mime_type_utils.dart';
import 'text_editor_screen.dart';

class FilePreviewScreen extends StatefulWidget {
  const FilePreviewScreen({super.key, required this.file});

  final RecentFile file;

  @override
  State<FilePreviewScreen> createState() => _FilePreviewScreenState();
}

class _FilePreviewScreenState extends State<FilePreviewScreen> {
  late RecentFile _file;

  @override
  void initState() {
    super.initState();
    _file = widget.file;
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = Drive2ShareScope.of(context);
    final file = _file;
    return Scaffold(
      appBar: AppBar(title: Text(dependencies.config.screens.previewTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      file.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('Type: ${file.mimeType}'),
                    const SizedBox(height: 4),
                    Text('Size: ${FormatUtils.fileSize(file.sizeBytes)}'),
                    const SizedBox(height: 4),
                    Text(
                      'Last modified: ${FormatUtils.dateTimeFromMillis(file.modifiedAtMillis)}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (MimeTypeUtils.isText(file.mimeType, file.name)) ...<Widget>[
              FilledButton.icon(
                onPressed: () => _editTextFile(dependencies),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit'),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _share(dependencies, file),
                    icon: const Icon(Icons.ios_share_outlined),
                    label: Text(dependencies.config.sharing.shareButtonText),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => OpenFilex.open(file.localPath),
                    icon: const Icon(Icons.open_in_new_outlined),
                    label: Text(dependencies.config.sharing.openButtonText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _share(AppDependencies dependencies, RecentFile file) async {
    try {
      await dependencies.fileImportService.share(file);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _editTextFile(AppDependencies dependencies) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => TextEditorScreen(file: _file)),
    );
    if (saved != true || !mounted) return;

    final localFile = File(_file.localPath);
    final updated = _file.copyWith(
      sizeBytes: await localFile.length(),
      modifiedAtMillis: DateTime.now().millisecondsSinceEpoch,
    );
    await dependencies.recentFileStore.save(updated);
    await dependencies.fileImportService.syncRecentFile(updated);
    setState(() {
      _file = updated;
    });
  }
}
