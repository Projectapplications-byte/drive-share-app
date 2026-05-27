import 'package:googleapis/drive/v3.dart' as drive;

import '../utils/mime_type_utils.dart';

class DriveFileItem {
  const DriveFileItem({
    required this.id,
    required this.name,
    required this.mimeType,
    required this.sizeBytes,
    required this.modifiedAt,
    required this.isGoogleWorkspaceFile,
    required this.isFolder,
    this.relativeFolderPath = const <String>[],
  });

  static const String folderMimeType = 'application/vnd.google-apps.folder';

  final String id;
  final String name;
  final String mimeType;
  final int sizeBytes;
  final DateTime? modifiedAt;
  final bool isGoogleWorkspaceFile;
  final bool isFolder;
  final List<String> relativeFolderPath;

  String get localMimeType =>
      isFolder ? folderMimeType : MimeTypeUtils.localMimeType(mimeType);

  DriveFileItem copyWith({List<String>? relativeFolderPath}) {
    return DriveFileItem(
      id: id,
      name: name,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
      modifiedAt: modifiedAt,
      isGoogleWorkspaceFile: isGoogleWorkspaceFile,
      isFolder: isFolder,
      relativeFolderPath: relativeFolderPath ?? this.relativeFolderPath,
    );
  }

  factory DriveFileItem.fromDriveFile(drive.File file) {
    final mimeType = file.mimeType ?? 'application/octet-stream';
    final isFolder = mimeType == folderMimeType;
    return DriveFileItem(
      id: file.id ?? '',
      name: file.name ?? 'Untitled',
      mimeType: mimeType,
      sizeBytes: int.tryParse(file.size ?? '') ?? 0,
      modifiedAt: file.modifiedTime,
      isGoogleWorkspaceFile:
          !isFolder && MimeTypeUtils.isGoogleWorkspace(mimeType),
      isFolder: isFolder,
    );
  }
}
