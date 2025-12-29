import 'dart:typed_data';
import 'package:audiotags/audiotags.dart';

class ArtworkService {
  static final Map<String, Uint8List?> _artworkCache = {};

  /// Extract artwork from audio file
  static Future<Uint8List?> extractArtwork(String filePath) async {
    // Check cache first
    if (_artworkCache.containsKey(filePath)) {
      return _artworkCache[filePath];
    }

    try {
      // Use audiotags package to read metadata
      final tag = await AudioTags.read(filePath);

      if (tag?.pictures != null && tag!.pictures!.isNotEmpty) {
        final artwork = tag.pictures!.first.bytes;
        _artworkCache[filePath] = artwork;
        return artwork;
      }
    } catch (e) {
      print('Error extracting artwork from $filePath: $e');
    }

    _artworkCache[filePath] = null;
    return null;
  }

  /// Clear artwork cache
  static void clearCache() {
    _artworkCache.clear();
  }

  /// Get cached artwork (if available)
  static Uint8List? getCachedArtwork(String filePath) {
    return _artworkCache[filePath];
  }
}