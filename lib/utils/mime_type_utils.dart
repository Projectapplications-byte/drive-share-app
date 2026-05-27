import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

class MimeTypeUtils {
  static const Map<String, String> _workspaceExports = <String, String>{
    'application/vnd.google-apps.document': 'application/pdf',
    'application/vnd.google-apps.spreadsheet':
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'application/vnd.google-apps.presentation':
        'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'application/vnd.google-apps.drawing': 'image/png',
  };

  static bool isGoogleWorkspace(String mimeType) =>
      mimeType.startsWith('application/vnd.google-apps');

  static String exportMimeType(String mimeType) =>
      _workspaceExports[mimeType] ?? 'application/pdf';

  static String localMimeType(String mimeType) =>
      isGoogleWorkspace(mimeType) ? exportMimeType(mimeType) : mimeType;

  static String extensionFor(String mimeType) {
    final local = localMimeType(mimeType);
    return switch (local) {
      'application/pdf' => 'pdf',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document' =>
        'docx',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' =>
        'xlsx',
      'application/vnd.openxmlformats-officedocument.presentationml.presentation' =>
        'pptx',
      'text/plain' => 'txt',
      'image/jpeg' => 'jpg',
      'image/png' => 'png',
      'image/webp' => 'webp',
      'video/mp4' => 'mp4',
      _ => extensionFromMime(local) ?? 'bin',
    };
  }

  static String mimeFromName(String fileName) {
    return lookupMimeType(fileName) ??
        switch (fileName.split('.').last.toLowerCase()) {
          'pdf' => 'application/pdf',
          'docx' =>
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
          'txt' || 'md' || 'json' || 'csv' || 'xml' => 'text/plain',
          _ => 'application/octet-stream',
        };
  }

  static bool isImage(String mimeType) =>
      localMimeType(mimeType).startsWith('image/');

  static bool isVideo(String mimeType) =>
      localMimeType(mimeType).startsWith('video/');

  static bool isPdf(String mimeType, String fileName) =>
      localMimeType(mimeType) == 'application/pdf' ||
      fileName.toLowerCase().endsWith('.pdf');

  static bool isText(String mimeType, String fileName) {
    final lowerName = fileName.toLowerCase();
    return localMimeType(mimeType).startsWith('text/') ||
        lowerName.endsWith('.txt') ||
        lowerName.endsWith('.md') ||
        lowerName.endsWith('.json') ||
        lowerName.endsWith('.csv');
  }

  static IconData iconFor(String mimeType, String fileName) {
    if (mimeType == 'application/vnd.google-apps.folder') {
      return Icons.folder_outlined;
    }
    if (isImage(mimeType)) return Icons.image_outlined;
    if (isVideo(mimeType)) return Icons.movie_outlined;
    if (isPdf(mimeType, fileName)) return Icons.picture_as_pdf_outlined;
    if (isText(mimeType, fileName)) return Icons.description_outlined;
    return Icons.insert_drive_file_outlined;
  }
}
