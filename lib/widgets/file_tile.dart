import 'package:flutter/material.dart';

import '../models/drive_file_item.dart';
import '../models/recent_file.dart';
import '../utils/format_utils.dart';
import '../utils/mime_type_utils.dart';

class DriveFileTile extends StatelessWidget {
  const DriveFileTile({
    super.key,
    required this.file,
    required this.onTap,
    required this.isBusy,
    this.onImport,
  });

  final DriveFileItem file;
  final VoidCallback onTap;
  final bool isBusy;
  final VoidCallback? onImport;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        enabled: !isBusy,
        leading: _FileIcon(mimeType: file.localMimeType, fileName: file.name),
        title: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(_subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: isBusy
            ? const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : IconButton(
                tooltip: file.isFolder ? 'Import folder' : 'Import',
                onPressed: onImport ?? onTap,
                icon: const Icon(Icons.file_download_outlined),
              ),
        onTap: isBusy ? null : onTap,
      ),
    );
  }

  String get _subtitle {
    if (file.isFolder) {
      return 'Folder • Tap to open\nModified ${FormatUtils.dateTime(file.modifiedAt)}';
    }
    return '${file.localMimeType} • ${FormatUtils.fileSize(file.sizeBytes)}\nModified ${FormatUtils.dateTime(file.modifiedAt)}';
  }
}

class RecentFileTile extends StatelessWidget {
  const RecentFileTile({
    super.key,
    required this.file,
    required this.onOpen,
    required this.onShare,
    this.onDelete,
  });

  final RecentFile file;
  final VoidCallback onOpen;
  final VoidCallback onShare;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: _FileIcon(mimeType: file.mimeType, fileName: file.name),
        title: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${file.mimeType} • ${FormatUtils.fileSize(file.sizeBytes)}\nImported ${FormatUtils.dateTimeFromMillis(file.importedAtMillis)}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              tooltip: 'Share',
              onPressed: onShare,
              icon: const Icon(Icons.ios_share_outlined),
            ),
            if (onDelete != null)
              IconButton(
                tooltip: 'Delete',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
          ],
        ),
        onTap: onOpen,
      ),
    );
  }
}

class _FileIcon extends StatelessWidget {
  const _FileIcon({required this.mimeType, required this.fileName});

  final String mimeType;
  final String fileName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        MimeTypeUtils.iconFor(mimeType, fileName),
        color: colorScheme.primary,
      ),
    );
  }
}
