import 'dart:io';
import 'dart:typed_data';
import 'package:audiotags/audiotags.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ArtworkService {
  static final Map<String, Uint8List?> _artworkCache = {};

  static final Map<String, Uri?> _artUriCache = {};

  static Future<Uri?> getArtworkUri(String filePath) async {
    if (_artUriCache.containsKey(filePath)) {
      return _artUriCache[filePath];
    }

    final bytes = await extractArtwork(filePath);
    if (bytes == null) {
      _artUriCache[filePath] = null;
      return null;
    }

    final dir = await getTemporaryDirectory();
    final file = File(
      p.join(dir.path, '${filePath.hashCode}.jpg'),
    );

    await file.writeAsBytes(bytes, flush: true);

    final uri = Uri.file(file.path);
    _artUriCache[filePath] = uri;
    return uri;
  }

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