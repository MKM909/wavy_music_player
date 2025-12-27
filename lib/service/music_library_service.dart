import 'dart:io';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

// Simple models for our music data
class Song {
  final String filePath;
  final String title;
  final String fileName;
  final int? fileSize;

  Song({
    required this.filePath,
    required this.title,
    required this.fileName,
    this.fileSize,
  });

  String get artist => 'Unknown Artist';
  String get album => 'Unknown Album';

  // Convert to/from JSON for caching
  Map<String, dynamic> toJson() => {
    'filePath': filePath,
    'title': title,
    'fileName': fileName,
    'fileSize': fileSize,
  };

  factory Song.fromJson(Map<String, dynamic> json) => Song(
    filePath: json['filePath'],
    title: json['title'],
    fileName: json['fileName'],
    fileSize: json['fileSize'],
  );
}

class MusicLibraryService {
  List<Song>? _cachedSongs; // In-memory cache
  DateTime? _lastScanTime;
  static const Duration _cacheValidDuration = Duration(hours: 24);

  // ========== PERMISSION HANDLING ==========

  Future<bool> requestMusicPermission() async {
    if (Platform.isAndroid) {
      PermissionStatus status;

      if (await Permission.audio.isGranted) {
        return true;
      }

      status = await Permission.audio.request();

      if (status.isGranted) {
        return true;
      }

      if (await Permission.storage.isGranted) {
        return true;
      }

      status = await Permission.storage.request();

      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        await openAppSettings();
        return false;
      }

      return false;
    } else if (Platform.isIOS) {
      final status = await Permission.mediaLibrary.request();
      return status.isGranted;
    }
    return false;
  }

  Future<bool> hasPermission() async {
    if (Platform.isAndroid) {
      return await Permission.audio.isGranted ||
          await Permission.storage.isGranted;
    } else if (Platform.isIOS) {
      return await Permission.mediaLibrary.isGranted;
    }
    return false;
  }

  // ========== OPTIMIZED MUSIC SCANNING ==========

  /// Get all songs with caching and progress callback
  /// [forceRefresh] - Force rescan even if cache exists
  /// [onProgress] - Callback for scan progress (current/total)
  Future<List<Song>> getAllSongs({
    bool forceRefresh = false,
    Function(int current, int total)? onProgress,
  }) async {
    if (!await hasPermission()) {
      throw Exception('Music permission not granted');
    }

    // Return cached data if valid
    if (!forceRefresh && _isCacheValid()) {
      return _cachedSongs!;
    }

    // Try to load from disk cache first (fast!)
    if (!forceRefresh) {
      final diskCache = await _loadFromDiskCache();
      if (diskCache != null) {
        _cachedSongs = diskCache;
        _lastScanTime = DateTime.now();
        return diskCache;
      }
    }

    // Perform full scan with progress tracking
    final songs = await _scanMusicFiles(onProgress: onProgress);

    // Cache results
    _cachedSongs = songs;
    _lastScanTime = DateTime.now();

    // Save to disk cache asynchronously (don't wait)
    _saveToDiskCache(songs);

    return songs;
  }

  /// Fast lookup - returns cached data immediately if available
  List<Song>? getCachedSongs() {
    return _cachedSongs;
  }

  /// Check if we need to refresh
  bool needsRefresh() {
    return !_isCacheValid();
  }

  bool _isCacheValid() {
    if (_cachedSongs == null || _lastScanTime == null) {
      return false;
    }

    final now = DateTime.now();
    return now.difference(_lastScanTime!) < _cacheValidDuration;
  }

  // ========== DISK CACHE ==========

  Future<String> _getCacheFilePath() async {
    final appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/music_cache.json';
  }

  Future<List<Song>?> _loadFromDiskCache() async {
    try {
      final cacheFile = File(await _getCacheFilePath());
      if (!await cacheFile.exists()) return null;

      // Check if cache file is too old
      final stats = await cacheFile.stat();
      final now = DateTime.now();
      if (now.difference(stats.modified) > _cacheValidDuration) {
        return null;
      }

      final jsonString = await cacheFile.readAsString();
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Song.fromJson(json)).toList();
    } catch (e) {
      print('Error loading cache: $e');
      return null;
    }
  }

  Future<void> _saveToDiskCache(List<Song> songs) async {
    try {
      final cacheFile = File(await _getCacheFilePath());
      final jsonList = songs.map((song) => song.toJson()).toList();
      await cacheFile.writeAsString(json.encode(jsonList));
    } catch (e) {
      print('Error saving cache: $e');
    }
  }

  // ========== FILE SCANNING (OPTIMIZED) ==========

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
          // Scan directory with limited depth to avoid deep recursion
          await _scanDirectory(
            directory,
            songs,
            maxDepth: 3, // Limit recursion depth
            currentDepth: 0,
          );
        }
      } catch (e) {
        print('Error scanning directory ${directory.path}: $e');
      }

      processedDirs++;
      onProgress?.call(processedDirs, totalDirs);
    }

    // Sort by title
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
            final song = Song(
              filePath: entity.path,
              title: _getFileNameWithoutExtension(entity.path),
              fileName: entity.path.split('/').last,
              fileSize: stats.size,
            );
            songs.add(song);
          } catch (e) {
            // Skip files we can't read
          }
        } else if (entity is Directory) {
          // Recursively scan subdirectories
          await _scanDirectory(
            entity,
            songs,
            maxDepth: maxDepth,
            currentDepth: currentDepth + 1,
          );
        }
      }
    } catch (e) {
      // Skip directories we can't access
    }
  }

  // ========== SEARCH (USES CACHE) ==========

  Future<List<Song>> searchSongs(String query) async {
    final songs = _cachedSongs ?? await getAllSongs();
    final lowerQuery = query.toLowerCase();

    return songs.where((song) {
      return song.title.toLowerCase().contains(lowerQuery) ||
          song.fileName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // ========== PAGINATION (for large libraries) ==========

  /// Get songs in pages for smooth scrolling
  List<Song> getSongsPaginated(int page, {int pageSize = 50}) {
    if (_cachedSongs == null) return [];

    final start = page * pageSize;
    final end = (start + pageSize).clamp(0, _cachedSongs!.length);

    if (start >= _cachedSongs!.length) return [];

    return _cachedSongs!.sublist(start, end);
  }

  int get totalPages {
    if (_cachedSongs == null) return 0;
    return (_cachedSongs!.length / 50).ceil();
  }

  // ========== HELPER METHODS ==========

  Future<List<Directory>> _getMusicDirectories() async {
    List<Directory> directories = [];

    if (Platform.isAndroid) {
      // Prioritize common music locations (faster)
      final commonPaths = [
        '/storage/emulated/0/Music',
        '/storage/emulated/0/Download',
        '/storage/emulated/0/Downloads',
      ];

      for (var path in commonPaths) {
        final dir = Directory(path);
        if (await dir.exists()) {
          directories.add(dir);
        }
      }

      try {
        final external = await getExternalStorageDirectory();
        if (external != null) {
          directories.add(Directory('${external.path}/Music'));
        }
      } catch (e) {
        print('Error getting external storage: $e');
      }
    } else if (Platform.isIOS) {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        directories.add(Directory('${appDir.path}/Music'));
      } catch (e) {
        print('Error getting iOS directory: $e');
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

  /// Clear all caches (for refresh)
  Future<void> clearCache() async {
    _cachedSongs = null;
    _lastScanTime = null;

    try {
      final cacheFile = File(await _getCacheFilePath());
      if (await cacheFile.exists()) {
        await cacheFile.delete();
      }
    } catch (e) {
      print('Error clearing cache: $e');
    }
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