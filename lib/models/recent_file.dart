class RecentFile {
  const RecentFile({
    required this.id,
    required this.driveFileId,
    required this.name,
    required this.mimeType,
    required this.localPath,
    required this.sizeBytes,
    required this.modifiedAtMillis,
    required this.importedAtMillis,
  });

  final String id;
  final String? driveFileId;
  final String name;
  final String mimeType;
  final String localPath;
  final int sizeBytes;
  final int modifiedAtMillis;
  final int importedAtMillis;

  RecentFile copyWith({
    String? id,
    String? driveFileId,
    String? name,
    String? mimeType,
    String? localPath,
    int? sizeBytes,
    int? modifiedAtMillis,
    int? importedAtMillis,
  }) {
    return RecentFile(
      id: id ?? this.id,
      driveFileId: driveFileId ?? this.driveFileId,
      name: name ?? this.name,
      mimeType: mimeType ?? this.mimeType,
      localPath: localPath ?? this.localPath,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      modifiedAtMillis: modifiedAtMillis ?? this.modifiedAtMillis,
      importedAtMillis: importedAtMillis ?? this.importedAtMillis,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'driveFileId': driveFileId,
      'name': name,
      'mimeType': mimeType,
      'localPath': localPath,
      'sizeBytes': sizeBytes,
      'modifiedAtMillis': modifiedAtMillis,
      'importedAtMillis': importedAtMillis,
    };
  }

  factory RecentFile.fromMap(Map<String, Object?> map) {
    return RecentFile(
      id: map['id'] as String,
      driveFileId: map['driveFileId'] as String?,
      name: map['name'] as String,
      mimeType: map['mimeType'] as String,
      localPath: map['localPath'] as String,
      sizeBytes: map['sizeBytes'] as int,
      modifiedAtMillis: map['modifiedAtMillis'] as int,
      importedAtMillis: map['importedAtMillis'] as int,
    );
  }
}
