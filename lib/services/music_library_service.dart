import 'dart:io';
import 'dart:convert';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';

import '../model/album.dart';
import '../model/song.dart';

class MusicLibraryService {
  List<Song>? _cachedSongs;
  DateTime? _lastScanTime;
  static const Duration _cacheValidDuration = Duration(hours: 24);

  Future<bool> requestMusicPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.audio.isGranted || await Permission.storage.isGranted) {
        return true;
      }

      var status = await Permission.audio.request();
      if (status.isGranted) return true;

      status = await Permission.storage.request();
      if (status.isGranted) return true;

      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
      return false;
    }
    return true; // iOS handled differently
  }

  Future<bool> hasPermission() async {
    if (Platform.isAndroid) {
      return await Permission.audio.isGranted || await Permission.storage.isGranted;
    }
    return true;
  }

  Future<List<Song>> getAllSongs({
    bool forceRefresh = false,
    Function(int current, int total)? onProgress,
  }) async {
    if (!forceRefresh && _isCacheValid()) {
      return _cachedSongs!;
    }

    if (!forceRefresh) {
      final diskCache = await _loadFromDiskCache();
      if (diskCache != null) {
        _cachedSongs = diskCache;
        _lastScanTime = DateTime.now();
        return diskCache;
      }
    }

    final songs = await _scanMusicFiles(onProgress: onProgress);
    _cachedSongs = songs;
    _lastScanTime = DateTime.now();
    _saveToDiskCache(songs);
    return songs;
  }

  List<Song>? getCachedSongs() => _cachedSongs;

  bool _isCacheValid() {
    if (_cachedSongs == null || _lastScanTime == null) return false;
    return DateTime.now().difference(_lastScanTime!) < _cacheValidDuration;
  }

  Future<String> _getCacheFilePath() async {
    final appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/music_cache.json';
  }

  Future<List<Song>?> _loadFromDiskCache() async {
    try {
      final cacheFile = File(await _getCacheFilePath());
      if (!await cacheFile.exists()) return null;

      final stats = await cacheFile.stat();
      if (DateTime.now().difference(stats.modified) > _cacheValidDuration) {
        return null;
      }

      final jsonString = await cacheFile.readAsString();
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Song.fromJson(json)).toList();
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveToDiskCache(List<Song> songs) async {
    try {
      final cacheFile = File(await _getCacheFilePath());
      final jsonList = songs.map((song) => song.toJson()).toList();
      await cacheFile.writeAsString(json.encode(jsonList));
    } catch (e) {
      // Ignore cache save errors
    }
  }

  Future<List<Song>> _scanMusicFiles({
    Function(int current, int total)? onProgress,
  }) async {
    List<Song> songs = [];
    final directories = await _getMusicDirectories();

    int totalDirs = directories.length;
    int processedDirs = 0;

    for (var directory in directories) {
      try {
        if (await directory.exists()) {
          await _scanDirectory(directory, songs, maxDepth: 3, currentDepth: 0);
        }
      } catch (e) {
        // Continue on error
      }

      processedDirs++;
      onProgress?.call(processedDirs, totalDirs);
    }

    songs.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return songs;
  }

  Future<void> _scanDirectory(
      Directory directory,
      List<Song> songs, {
        required int maxDepth,
        required int currentDepth,
      }) async {
    if (currentDepth >= maxDepth) return;

    try {
      await for (var entity in directory.list(followLinks: false)) {
        if (entity is File && _isAudioFile(entity.path)) {
          try {
            final stats = await entity.stat();
            Uint8List? artwork;
            String? album;
            String? artist;

            try {
              final metadata = readMetadata(
                entity,
                getImage: true,
              );

              if (metadata.pictures.isNotEmpty) {
                artwork = metadata.pictures.first.bytes;
              }

              album = metadata.album?.trim();
              artist = metadata.artist?.trim();

            } catch (_) {
              artwork = null;
            }

            songs.add(
              Song(
                filePath: entity.path,
                title: _getFileNameWithoutExtension(entity.path),
                fileName: entity.path.split('/').last,
                fileSize: stats.size,
                album: album ?? 'Unknown Album',
                artist: artist ?? 'Unknown Artist',
              ),
            );
          } catch (e) {
            // Skip unreadable files
          }
        } else if (entity is Directory) {
          await _scanDirectory(entity, songs, maxDepth: maxDepth, currentDepth: currentDepth + 1);
        }
      }
    } catch (e) {
      // Skip inaccessible directories
    }
  }

  Future<List<Directory>> _getMusicDirectories() async {
    List<Directory> directories = [];

    if (Platform.isAndroid) {
      final paths = [
        '/storage/emulated/0/Music',
        '/storage/emulated/0/Download',
        '/storage/emulated/0/Downloads',
      ];

      for (var path in paths) {
        final dir = Directory(path);
        if (await dir.exists()) directories.add(dir);
      }

      try {
        final external = await getExternalStorageDirectory();
        if (external != null) {
          directories.add(Directory('${external.path}/Music'));
        }
      } catch (e) {
        // Ignore
      }
    }

    return directories;
  }

  bool _isAudioFile(String path) {
    final ext = path.toLowerCase().split('.').last;
    return ['mp3', 'wav', 'm4a', 'aac', 'ogg', 'flac', 'wma', 'opus'].contains(ext);
  }

  String _getFileNameWithoutExtension(String path) {
    final fileName = path.split('/').last;
    final parts = fileName.split('.');
    if (parts.length > 1) {
      parts.removeLast();
      return parts.join('.');
    }
    return fileName;
  }

  String getFormattedFileSize(int? bytes) {
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }

  Future<List<Song>> searchSongs(String query) async {
    final songs = _cachedSongs ?? await getAllSongs();
    final lowerQuery = query.toLowerCase();
    return songs.where((song) =>
    song.title.toLowerCase().contains(lowerQuery) ||
        song.fileName.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  Map<String, Album> categorizeByAlbum(List<Song> songs) {
    final Map<String, Album> albums = {};

    for (final song in songs) {
      final albumName = song.album ?? 'Unknown Album';
      final artistName = song.artist ?? 'Unknown Artist';

      final albumKey = '$albumName|$artistName';

      if (!albums.containsKey(albumKey)) {
        albums[albumKey] = Album(
          name: albumName,
          artist: artistName,
          songs: [],
        );
      }

      albums[albumKey]!.songs.add(song);
    }

    // Optional: sort songs inside each album
    for (final album in albums.values) {
      album.songs.sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
    }

    return albums;
  }

  Future<List<Album>> getAlbums({bool forceRefresh = false}) async {
    final songs = await getAllSongs(forceRefresh: forceRefresh);
    final albumMap = categorizeByAlbum(songs);
    return albumMap.values.toList();
  }

}
