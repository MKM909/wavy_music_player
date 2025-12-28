import 'dart:typed_data';

// Simple models for our music data

// ============================================================================
// FILE 1: lib/services/music_library_service.dart
// ============================================================================

class Song {
  final String filePath;
  final String title;
  final String fileName;
  final int? fileSize;
  Uint8List? albumArt; // Add this field for artwork

  Song({
    required this.filePath,
    required this.title,
    required this.fileName,
    this.fileSize,
    this.albumArt,
  });

  String get artist => 'Unknown Artist';
  String get album => 'Unknown Album';

  Map<String, dynamic> toJson() => {
    'filePath': filePath,
    'title': title,
    'fileName': fileName,
    'fileSize': fileSize,
    // Don't cache artwork in JSON (too large)
  };

  factory Song.fromJson(Map<String, dynamic> json) => Song(
    filePath: json['filePath'],
    title: json['title'],
    fileName: json['fileName'],
    fileSize: json['fileSize'],
  );
}
