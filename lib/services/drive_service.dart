import 'dart:io';

import 'package:_discoveryapis_commons/_discoveryapis_commons.dart' as commons;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/app_config.dart';
import '../models/drive_file_item.dart';
import '../models/drive_folder.dart';
import '../utils/mime_type_utils.dart';
import 'auth_service.dart';

class DriveService {
  const DriveService(this._authService);

  final AuthService _authService;

  Future<DriveFolder?> findFolder(DriveFolderConfig config) async {
    final client = await _authService.authClient();
    try {
      final api = drive.DriveApi(client);
      final response = await api.files.list(
        q: [
          'trashed = false',
          "mimeType = 'application/vnd.google-apps.folder'",
          "name = ${_queryLiteral(config.name)}",
          "${_queryLiteral(config.parentId)} in parents",
        ].join(' and '),
        orderBy: 'modifiedTime desc',
        pageSize: 1,
        spaces: 'drive',
        $fields: 'files(id,name)',
      );
      final folders =
          response.files?.where((file) => file.id != null).toList() ??
          <drive.File>[];
      final folder = folders.isEmpty ? null : folders.first;
      return folder == null ? null : DriveFolder.fromDriveFile(folder);
    } finally {
      client.close();
    }
  }

  Future<DriveFolder> createFolder(DriveFolderConfig config) async {
    final client = await _authService.authClient();
    try {
      final api = drive.DriveApi(client);
      final created = await api.files.create(
        drive.File()
          ..name = config.name
          ..mimeType = 'application/vnd.google-apps.folder'
          ..parents = <String>[config.parentId],
        $fields: 'id,name',
      );
      if (created.id == null) {
        throw StateError('Google Drive did not return the new folder ID.');
      }
      return DriveFolder.fromDriveFile(created);
    } finally {
      client.close();
    }
  }

  Future<void> trashFolder(String folderId) async {
    final client = await _authService.authClient();
    try {
      final api = drive.DriveApi(client);
      await api.files.update(
        drive.File()..trashed = true,
        folderId,
        $fields: 'id,trashed',
      );
    } finally {
      client.close();
    }
  }

  Future<List<DriveFileItem>> listItemsInFolder(String folderId) async {
    final client = await _authService.authClient();
    try {
      final api = drive.DriveApi(client);
      return _listItems(api, folderId);
    } finally {
      client.close();
    }
  }

  Future<List<DriveFileItem>> listFilesRecursively(DriveFileItem folder) async {
    if (!folder.isFolder) {
      return <DriveFileItem>[folder];
    }

    final client = await _authService.authClient();
    try {
      final api = drive.DriveApi(client);
      final files = <DriveFileItem>[];
      await _collectFiles(
        api,
        folderId: folder.id,
        folderPath: <String>[folder.name],
        output: files,
      );
      return files;
    } finally {
      client.close();
    }
  }

  Future<File> downloadFile(DriveFileItem file) async {
    if (file.isFolder) {
      throw StateError('Folders must be imported recursively.');
    }

    final client = await _authService.authClient();
    try {
      final api = drive.DriveApi(client);
      final importDir = await _importsDirectory(file.relativeFolderPath);
      final destination = _uniqueFile(
        importDir,
        _safeFileName(file.name, MimeTypeUtils.extensionFor(file.mimeType)),
      );

      final commons.Media? media;
      if (file.isGoogleWorkspaceFile) {
        media = await api.files.export(
          file.id,
          MimeTypeUtils.exportMimeType(file.mimeType),
          downloadOptions: commons.DownloadOptions.fullMedia,
        );
      } else {
        media =
            await api.files.get(
                  file.id,
                  downloadOptions: commons.DownloadOptions.fullMedia,
                )
                as commons.Media;
      }

      if (media == null) {
        throw StateError('No downloadable content returned.');
      }

      final sink = destination.openWrite();
      await media.stream.pipe(sink);
      return destination;
    } finally {
      client.close();
    }
  }

  Future<List<DriveFileItem>> _listItems(
    drive.DriveApi api,
    String folderId,
  ) async {
    final items = <DriveFileItem>[];
    String? pageToken;

    do {
      final response = await api.files.list(
        q: [
          'trashed = false',
          "${_queryLiteral(folderId)} in parents",
        ].join(' and '),
        orderBy: 'folder,name_natural',
        pageSize: 100,
        pageToken: pageToken,
        spaces: 'drive',
        $fields: 'nextPageToken,files(id,name,mimeType,size,modifiedTime)',
      );
      items.addAll(
        response.files
                ?.where((file) => file.id != null)
                .map(DriveFileItem.fromDriveFile) ??
            const Iterable<DriveFileItem>.empty(),
      );
      pageToken = response.nextPageToken;
    } while (pageToken != null);

    return items;
  }

  Future<void> _collectFiles(
    drive.DriveApi api, {
    required String folderId,
    required List<String> folderPath,
    required List<DriveFileItem> output,
  }) async {
    final items = await _listItems(api, folderId);
    for (final item in items) {
      if (item.isFolder) {
        await _collectFiles(
          api,
          folderId: item.id,
          folderPath: <String>[...folderPath, item.name],
          output: output,
        );
      } else {
        output.add(item.copyWith(relativeFolderPath: folderPath));
      }
    }
  }

  Future<Directory> _importsDirectory([
    List<String> folderPath = const <String>[],
  ]) async {
    final documents = await getApplicationDocumentsDirectory();
    final directory = Directory(
      p.joinAll(<String>[
        documents.path,
        'imports',
        ...folderPath.map(_safePathSegment),
      ]),
    );
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    return directory;
  }

  File _uniqueFile(Directory directory, String desiredName) {
    var candidate = File(p.join(directory.path, desiredName));
    if (!candidate.existsSync()) return candidate;

    final extension = p.extension(desiredName);
    final baseName = p.basenameWithoutExtension(desiredName);
    var index = 1;
    while (candidate.existsSync()) {
      candidate = File(p.join(directory.path, '$baseName ($index)$extension'));
      index++;
    }
    return candidate;
  }

  String _safeFileName(String name, String fallbackExtension) {
    final cleaned = name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    final fileName = cleaned.isEmpty ? 'drive2share-file' : cleaned;
    return p.extension(fileName).isEmpty
        ? '$fileName.$fallbackExtension'
        : fileName;
  }

  String _safePathSegment(String name) {
    final cleaned = name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    return cleaned.isEmpty ? 'folder' : cleaned;
  }

  String _queryLiteral(String value) {
    final escaped = value.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
    return "'$escaped'";
  }
}
