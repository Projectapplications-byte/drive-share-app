import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:video_player/video_player.dart';

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
  VideoPlayerController? _videoController;
  Future<String>? _textFuture;

  @override
  void initState() {
    super.initState();
    _file = widget.file;
    final file = _file;
    if (MimeTypeUtils.isVideo(file.mimeType)) {
      _videoController = VideoPlayerController.file(File(file.localPath))
        ..initialize().then((_) {
          if (!mounted) return;
          setState(() {});
          _videoController?.setLooping(true);
          _videoController?.play();
        });
    } else if (MimeTypeUtils.isText(file.mimeType, file.name)) {
      _textFuture = _readTextPreview(File(file.localPath));
    }
  }

  Future<String> _readTextPreview(File file) async {
    final content = await file.readAsString();
    if (content.length <= 48000) return content;
    return '${content.substring(0, 48000)}\n\n--- Preview truncated ---';
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
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
            SizedBox(
              height: 340,
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: _PreviewContent(
                  file: file,
                  videoController: _videoController,
                  textFuture: _textFuture,
                ),
              ),
            ),
            const SizedBox(height: 16),
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
    setState(() {
      _file = updated;
      _textFuture = _readTextPreview(localFile);
    });
  }
}

class _PreviewContent extends StatelessWidget {
  const _PreviewContent({
    required this.file,
    required this.videoController,
    required this.textFuture,
  });

  final RecentFile file;
  final VideoPlayerController? videoController;
  final Future<String>? textFuture;

  @override
  Widget build(BuildContext context) {
    final localFile = File(file.localPath);
    if (!localFile.existsSync()) {
      return const _UnsupportedPreview(
        message: 'This imported file is no longer available.',
      );
    }

    if (MimeTypeUtils.isImage(file.mimeType)) {
      return InteractiveViewer(
        child: Center(child: Image.file(localFile, fit: BoxFit.contain)),
      );
    }

    if (MimeTypeUtils.isPdf(file.mimeType, file.name)) {
      return SfPdfViewer.file(localFile);
    }

    if (MimeTypeUtils.isVideo(file.mimeType)) {
      final controller = videoController;
      if (controller == null || !controller.value.isInitialized) {
        return const Center(child: CircularProgressIndicator());
      }
      return Stack(
        alignment: Alignment.center,
        children: <Widget>[
          AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          ),
          IconButton.filledTonal(
            onPressed: () {
              controller.value.isPlaying
                  ? controller.pause()
                  : controller.play();
            },
            icon: Icon(
              controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            ),
          ),
        ],
      );
    }

    if (MimeTypeUtils.isText(file.mimeType, file.name)) {
      return FutureBuilder<String>(
        future: textFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(14),
            child: SelectableText(
              snapshot.data ?? '',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
          );
        },
      );
    }

    return _UnsupportedPreview(
      message: 'Preview not available for this file type.',
      icon: MimeTypeUtils.iconFor(file.mimeType, file.name),
    );
  }
}

class _UnsupportedPreview extends StatelessWidget {
  const _UnsupportedPreview({
    required this.message,
    this.icon = Icons.insert_drive_file_outlined,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 58, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
