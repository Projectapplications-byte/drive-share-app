import 'package:googleapis/drive/v3.dart' as drive;

class DriveFolder {
  const DriveFolder({required this.id, required this.name});

  final String id;
  final String name;

  factory DriveFolder.fromDriveFile(drive.File file) {
    return DriveFolder(id: file.id ?? '', name: file.name ?? 'Untitled');
  }
}
