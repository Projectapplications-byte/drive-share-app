import 'package:flutter/material.dart';

import '../main.dart';
import '../models/recent_file.dart';
import '../widgets/file_tile.dart';
import 'create_file_screen.dart';
import 'file_preview_screen.dart';
import 'login_screen.dart';
import 'recent_files_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<RecentFile>> _recentFiles;
  bool _isCreatingFile = false;

  @override
  void initState() {
    super.initState();
    _recentFiles = _loadRecentFiles();
  }

  Future<List<RecentFile>> _loadRecentFiles() {
    return Drive2ShareScope.of(context).recentFileStore.list(limit: 3);
  }

  void _refreshRecentFiles() {
    setState(() => _recentFiles = _loadRecentFiles());
  }

  Future<void> _openMyFiles() async {
    if (!mounted) return;
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const RecentFilesScreen()));
    if (mounted) _refreshRecentFiles();
  }

  Future<void> _createFile() async {
    setState(() => _isCreatingFile = true);
    try {
      final file = await Navigator.of(context).push<RecentFile>(
        MaterialPageRoute<RecentFile>(builder: (_) => const CreateFileScreen()),
      );
      if (!mounted || file == null) return;
      _refreshRecentFiles();
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => FilePreviewScreen(file: file)),
      );
      _refreshRecentFiles();
    } catch (error) {
      _showSnack(error.toString());
    } finally {
      if (mounted) setState(() => _isCreatingFile = false);
    }
  }

  Future<void> _signOut() async {
    await Drive2ShareScope.of(context).authService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = Drive2ShareScope.of(context);
    final config = dependencies.config.home;

    return Scaffold(
      appBar: AppBar(title: Text(dependencies.config.appName)),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _refreshRecentFiles(),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: <Widget>[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 28,
                        child: Text(dependencies.config.appName[0]),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Your file library',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Create, edit, and share files from this app',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: <Widget>[
                  _ActionButton(
                    actionId: 'browse',
                    icon: Icons.folder_open_outlined,
                    onTap: _openMyFiles,
                  ),
                  _ActionButton(
                    actionId: 'device',
                    icon: Icons.note_add_outlined,
                    isBusy: _isCreatingFile,
                    onTap: _createFile,
                  ),
                  _ActionButton(
                    actionId: 'recent',
                    icon: Icons.history_outlined,
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const RecentFilesScreen(),
                        ),
                      );
                      _refreshRecentFiles();
                    },
                  ),
                  _ActionButton(
                    actionId: 'sign_out',
                    icon: Icons.logout_outlined,
                    onTap: _signOut,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      config.recentSectionTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const RecentFilesScreen(),
                        ),
                      );
                      _refreshRecentFiles();
                    },
                    child: Text(config.viewAllText),
                  ),
                ],
              ),
              FutureBuilder<List<RecentFile>>(
                future: _recentFiles,
                builder: (context, snapshot) {
                  final files = snapshot.data ?? <RecentFile>[];
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (files.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(child: Text(config.emptyRecentText)),
                      ),
                    );
                  }
                  return Column(
                    children: files
                        .map(
                          (file) => RecentFileTile(
                            file: file,
                            onOpen: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => FilePreviewScreen(file: file),
                              ),
                            ),
                            onShare: () => _share(file),
                            onDelete: () => _deleteRecentFile(file),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _share(RecentFile file) async {
    try {
      await Drive2ShareScope.of(context).fileImportService.share(file);
    } catch (error) {
      _showSnack(error.toString());
    }
  }

  Future<void> _deleteRecentFile(RecentFile file) async {
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
      _refreshRecentFiles();
      _showSnack('Deleted "${file.name}".');
    } catch (error) {
      _showSnack('Unable to delete: $error');
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.actionId,
    required this.icon,
    required this.onTap,
    this.isBusy = false,
  });

  final String actionId;
  final IconData icon;
  final VoidCallback onTap;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final action = Drive2ShareScope.of(context).config.home.actions[actionId];
    if (action == null || !action.enabled) return const SizedBox.shrink();

    return FilledButton.tonalIcon(
      onPressed: isBusy ? null : onTap,
      icon: isBusy
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon),
      label: Text(action.text),
    );
  }
}
