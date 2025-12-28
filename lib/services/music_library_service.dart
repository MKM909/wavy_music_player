import 'dart:io';
import 'dart:convert';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
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
  final Uint8List? artwork; // 👈 NEW

  Song({
    required this.filePath,
    required this.title,
    required this.fileName,
    this.fileSize,
    this.artwork,
  });

  String get artist => 'Unknown Artist';
  String get album => 'Unknown Album';

  Map<String, dynamic> toJson() => {
    'filePath': filePath,
    'title': title,
    'fileName': fileName,
    'fileSize': fileSize,
    // artwork is NOT cached (too large)
  };

  factory Song.fromJson(Map<String, dynamic> json) => Song(
    filePath: json['filePath'],
    title: json['title'],
    fileName: json['fileName'],
    fileSize: json['fileSize'],
    artwork: null, // reloaded dynamically
  );
}

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

            try {
              final metadata = readMetadata(
                entity,
                getImage: true,
              );

              if (metadata.pictures.isNotEmpty) {
                artwork = metadata.pictures.first.bytes;
              }
            } catch (_) {
              artwork = null;
            }

            songs.add(
              Song(
                filePath: entity.path,
                title: _getFileNameWithoutExtension(entity.path),
                fileName: entity.path.split('/').last,
                fileSize: stats.size,
                artwork: artwork,
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
}
// ============================================================================
// OPTIMIZED USAGE EXAMPLE
// ============================================================================

/*
class MusicLibraryExample extends StatefulWidget {
  @override
  _MusicLibraryExampleState createState() => _MusicLibraryExampleState();
}

class _MusicLibraryExampleState extends State<MusicLibraryExample> {
  final MusicLibraryService _musicService = MusicLibraryService();
  List<Song> songs = [];
  bool isLoading = false;
  bool isScanning = false;
  int scanProgress = 0;
  int scanTotal = 0;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMusicFast();
  }

  // FAST INITIAL LOAD - Show cached data immediately
  Future<void> _loadMusicFast() async {
    // Try to get cached data first (instant!)
    final cached = _musicService.getCachedSongs();
    if (cached != null) {
      setState(() {
        songs = cached;
      });
      return;
    }

    // No cache, do full load
    await _loadMusicFull();
  }

  // FULL LOAD WITH PROGRESS
  Future<void> _loadMusicFull({bool forceRefresh = false}) async {
    setState(() {
      isLoading = true;
      isScanning = true;
      errorMessage = null;
      scanProgress = 0;
      scanTotal = 0;
    });

    try {
      final hasPermission = await _musicService.requestMusicPermission();

      if (hasPermission) {
        // Scan with progress callback
        final allSongs = await _musicService.getAllSongs(
          forceRefresh: forceRefresh,
          onProgress: (current, total) {
            setState(() {
              scanProgress = current;
              scanTotal = total;
            });
          },
        );

        setState(() {
          songs = allSongs;
          isLoading = false;
          isScanning = false;
        });

        if (songs.isEmpty) {
          setState(() {
            errorMessage = 'No music files found';
          });
        }
      } else {
        setState(() {
          errorMessage = 'Permission denied';
          isLoading = false;
          isScanning = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
        isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE695),
      appBar: AppBar(
        title: Text('My Music (${songs.length})'),
        backgroundColor: const Color(0xFF342E1B),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _loadMusicFull(forceRefresh: true),
          ),
        ],
      ),
      body: isScanning
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    'Scanning music files...',
                    style: TextStyle(fontSize: 16),
                  ),
                  if (scanTotal > 0)
                    Text(
                      '$scanProgress / $scanTotal directories',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                ],
              ),
            )
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : ListView.builder(
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    return ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0xFF342E1B),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.music_note, color: Color(0xFFFFE695)),
                      ),
                      title: Text(song.title),
                      subtitle: Text('${_musicService.getFormattedFileSize(song.fileSize)}'),
                      trailing: Icon(Icons.play_arrow),
                      onTap: () => print('Play: ${song.filePath}'),
                    );
                  },
                ),
    );
  }
}
*/