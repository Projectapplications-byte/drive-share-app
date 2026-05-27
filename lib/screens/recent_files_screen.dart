import 'package:flutter/material.dart';

import '../main.dart';
import '../models/recent_file.dart';
import '../widgets/file_tile.dart';
import 'create_file_screen.dart';
import 'file_preview_screen.dart';

class RecentFilesScreen extends StatefulWidget {
  const RecentFilesScreen({super.key});

  @override
  State<RecentFilesScreen> createState() => _RecentFilesScreenState();
}

class _RecentFilesScreenState extends State<RecentFilesScreen> {
  late Future<List<RecentFile>> _filesFuture;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _filesFuture = Drive2ShareScope.of(context).recentFileStore.list();
  }

  Future<void> _refresh() async {
    setState(
      () => _filesFuture = Drive2ShareScope.of(context).recentFileStore.list(),
    );
    await _filesFuture;
  }

  Future<void> _createFile() async {
    setState(() => _isCreating = true);
    try {
      final file = await Navigator.of(context).push<RecentFile>(
        MaterialPageRoute<RecentFile>(builder: (_) => const CreateFileScreen()),
      );
      if (!mounted || file == null) return;
      await _refresh();
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => FilePreviewScreen(file: file)),
      );
      await _refresh();
    } catch (error) {
      _showSnack(error.toString());
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  Future<void> _share(RecentFile file) async {
    try {
      await Drive2ShareScope.of(context).fileImportService.share(file);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _delete(RecentFile file) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete recent file?'),
          content: Text(
            'Remove "${file.name}" from recent files and delete the imported local copy?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (shouldDelete != true || !mounted) return;

    try {
      await Drive2ShareScope.of(
        context,
      ).fileImportService.deleteRecentFile(file);
      await _refresh();
      _showSnack('Deleted "${file.name}".');
    } catch (error) {
      _showSnack('Unable to delete: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = Drive2ShareScope.of(context).config.screens;
    return Scaffold(
      appBar: AppBar(title: Text(config.recentTitle)),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        tooltip: 'Create file',
        onPressed: _isCreating ? null : _createFile,
        child: _isCreating
            ? const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.note_add_outlined),
      ),
      body: SafeArea(
        child: FutureBuilder<List<RecentFile>>(
          future: _filesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final files = snapshot.data ?? <RecentFile>[];
            if (files.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(config.recentEmptyText),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: files.length,
                itemBuilder: (context, index) {
                  final file = files[index];
                  return RecentFileTile(
                    file: file,
                    onOpen: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => FilePreviewScreen(file: file),
                      ),
                    ),
                    onShare: () => _share(file),
                    onDelete: () => _delete(file),
                  );
                },
              ),
            );
          },
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
