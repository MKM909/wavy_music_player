import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../bottom_sheets/queue_editor_sheet.dart';
import '../handlers/wavy_audio_handler.dart';
import '../model/song.dart';
import '../services/artwork_service.dart';

enum PlaybackStateEnum {
  playing,
  paused,
  stopped,
  loading,
}

enum RepeatMode {
  off,
  all,
  one,
}

class MusicController extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Current state
  Song? _currentSong;
  PlaybackStateEnum _playbackStateEnum = PlaybackStateEnum.stopped;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isShuffleOn = false;
  RepeatMode _repeatMode = RepeatMode.all;

  // Queue management
  List<Song> _queue = [];
  List<Song> _originalQueue = []; // For shuffle
  int _currentIndex = 0;

  Timer? _sleepTimer;
  Duration? _sleepDuration;

  Duration? get sleepDuration => _sleepDuration;
  bool get hasSleepTimer => _sleepTimer != null;


  // Getters
  Song? get currentSong => _currentSong;
  PlaybackStateEnum get playbackState => _playbackStateEnum;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  bool get isPlaying => _playbackStateEnum == PlaybackStateEnum.playing;
  bool get isShuffleOn => _isShuffleOn;
  RepeatMode get repeatMode => _repeatMode;
  List<Song> get queue => _queue;
  int get currentIndex => _currentIndex;
  bool get hasNext => _currentIndex < _queue.length - 1;
  bool get hasPrevious => _currentIndex > 0;
  AudioPlayer get audioPlayer => _audioPlayer;


  late final WavyAudioHandler _audioHandler;

  MusicController() {
    _initAudioPlayer();
  }

  void _initAudioPlayer() async {
    try {
      // 🔹 Step 1: Initialize audioHandler first
      _audioHandler = await AudioService.init(
        builder: () => WavyAudioHandler(this), // We'll fix circular dependency in a sec
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.wavy.music.player.channel',
          androidNotificationChannelName: 'Wavy Music',
          androidNotificationOngoing: false,
          androidStopForegroundOnPause: false,
        ),
      );
      debugPrint('MYAPP: init -> ✅ AudioService initialized');
    } catch (e) {
      debugPrint('MYAPP: init -> ❌ AudioService init error: $e');
    }
    _audioPlayer.positionStream.listen((position) {
      _currentPosition = position;
      _updateHandlerPosition();
      notifyListeners();
    });

    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        _totalDuration = duration;
        notifyListeners();
      }
    });

    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _onSongComplete();
        return;
      }

      if (state.playing) {
        _playbackStateEnum = PlaybackStateEnum.playing;
      } else if (state.processingState == ProcessingState.ready) {
        _playbackStateEnum = PlaybackStateEnum.paused;
      } else if (state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering) {
        _playbackStateEnum = PlaybackStateEnum.loading;
      }

      _updateHandlerState();
      notifyListeners();
    });
  }

  // ===================== Playback Controls =====================
  Future<void> playSong(Song song, {List<Song>? newQueue, int? startIndex}) async {
    try {
      _playbackStateEnum = PlaybackStateEnum.loading;
      notifyListeners();

      if (newQueue != null) {
        _queue = List.from(newQueue);
        _originalQueue = List.from(newQueue);
        _currentIndex = startIndex ?? 0;
      }

      _currentSong = song;

      // Update AudioHandler
      await _audioHandler.setCurrentMediaItem(song);
      _audioHandler.updateQueue(await _queueToMediaItems(_queue));

      // Load and play
      await _audioPlayer.setFilePath(song.filePath);
      await _audioPlayer.play();

      _playbackStateEnum = PlaybackStateEnum.playing;
      notifyListeners();
    } catch (e) {
      debugPrint('MYAPP: playSong -> Error playing song: $e');
      _playbackStateEnum = PlaybackStateEnum.stopped;
      notifyListeners();
    }
  }

  Future<void> playAt(int index) async {
    if (index < 0 || index >= _queue.length) return;
    _currentIndex = index;
    await playSong(_queue[index]);
  }


  Future<void> togglePlayPause() async {
    if (_audioPlayer.playing) {
      await pause();
    } else {
      await resume();
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> resume() async {
    await _audioPlayer.play();
  }


  Future<void> stop() async {
    _sleepTimer?.cancel();
    _clearSleepTimer();
    await _audioPlayer.stop();
    _playbackStateEnum = PlaybackStateEnum.stopped;
    _currentPosition = Duration.zero;
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
    notifyListeners();
  }

  // ========== QUEUE MANAGEMENT ==========

  Future<void> playNext() async {
    if (_queue.isEmpty) return;

    if (!hasNext) {
      if (_repeatMode == RepeatMode.all) {
        _currentIndex = 0;
      }
    } else {
      _currentIndex++;
    }


    await _restartAndPlay(_queue[_currentIndex]);
  }

  Future<void> _restartAndPlay(Song song) async {
    try {
      _playbackStateEnum = PlaybackStateEnum.loading;
      notifyListeners();

      // 🔑 Reset player completely
      await _audioPlayer.stop();
      await _audioPlayer.seek(Duration.zero);

      _currentSong = song;

      await _audioHandler.setCurrentMediaItem(song);

      await _audioPlayer.setFilePath(song.filePath);
      await _audioPlayer.play();

      _playbackStateEnum = PlaybackStateEnum.playing;
      notifyListeners();
    } catch (e) {
      debugPrint('MYAPP: _restartAndPlay -> Restart play error: $e');
    }
  }


  Future<void> playPrevious() async {
    // If more than 3 seconds played, restart current song
    if (_currentPosition.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }

    if (!hasPrevious) {
      if (_repeatMode == RepeatMode.all) {
        _currentIndex = _queue.length - 1;
      } else {
        await seek(Duration.zero);
        return;
      }
    } else {
      _currentIndex--;
    }

    if (_currentIndex >= 0 && _currentIndex < _queue.length) {
      await playSong(_queue[_currentIndex]);
    }
  }

  void _onSongComplete() {
    if (_queue.isEmpty) return;

    if (_repeatMode == RepeatMode.one && _currentSong != null) {
      _restartAndPlay(_currentSong!);
      return;
    }

    playNext();
  }


  Future<List<MediaItem>> _queueToMediaItems(List<Song> songs) async {
    final items = <MediaItem>[];
    for (final song in songs) {
      items.add(await _songToMediaItem(song));
    }
    return items;
  }

  // ========== SHUFFLE & REPEAT ==========

  Future<void> toggleShuffle() async {
    _isShuffleOn = !_isShuffleOn;

    if (_isShuffleOn) {
      // Save current song
      final currentSong = _currentSong;

      // Shuffle queue
      _queue.shuffle();

      // Move current song to front
      if (currentSong != null) {
        _queue.remove(currentSong);
        _queue.insert(0, currentSong);
        _currentIndex = 0;
      }
    } else {
      // Restore original queue
      final currentSong = _currentSong;
      _queue = List.from(_originalQueue);

      // Find current song index in original queue
      if (currentSong != null) {
        _currentIndex = _queue.indexWhere((s) => s.filePath == currentSong.filePath);
        if (_currentIndex == -1) _currentIndex = 0;
      }
    }

    _audioHandler.updateQueue(await _queueToMediaItems(_queue));
    notifyListeners();
  }

  void toggleRepeatMode() {
    switch (_repeatMode) {
      case RepeatMode.off:
        _repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.off;
        break;
    }
    notifyListeners();
  }

  // ========== QUEUE MANIPULATION ==========

  Future<void> addToQueue(Song song) async {
    _queue.add(song);
    _originalQueue.add(song);
    _audioHandler.updateQueue(await _queueToMediaItems(_queue));
    notifyListeners();
  }

  Future<void> removeFromQueue(int index) async {
    if (index < _queue.length) {
      final song = _queue[index];
      _queue.removeAt(index);
      _originalQueue.remove(song);

      // Adjust current index if needed
      if (index < _currentIndex) {
        _currentIndex--;
      }
    _audioHandler.updateQueue(await _queueToMediaItems(_queue));
    notifyListeners();
    }
  }

  void clearQueue() {
    _queue.clear();
    _originalQueue.clear();
    _currentIndex = 0;
    notifyListeners();
  }

  void reorderQueue(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final song = _queue.removeAt(oldIndex);
    _queue.insert(newIndex, song);

    // Update current index if needed
    if (oldIndex == _currentIndex) {
      _currentIndex = newIndex;
    } else if (oldIndex < _currentIndex && newIndex >= _currentIndex) {
      _currentIndex--;
    } else if (oldIndex > _currentIndex && newIndex <= _currentIndex) {
      _currentIndex++;
    }

    notifyListeners();
  }

  // ========== UTILITY ==========

  String formatDuration(Duration? duration) {
    if (duration == null) return '0:00';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes;
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  double get progress {
    if (_totalDuration.inMilliseconds == 0) return 0.0;
    return _currentPosition.inMilliseconds / _totalDuration.inMilliseconds;
  }

  bool get isSpinning => _playbackStateEnum == PlaybackStateEnum.playing;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }


  void showQueueEditor(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const QueueEditorSheet(),
    );
  }


  Future<void> playPlaylist({
    required List<Song> songs,
    int startIndex = 0,
  }) async {
    if (songs.isEmpty) return;

    _playbackStateEnum = PlaybackStateEnum.loading;

    _queue = List.from(songs);
    _originalQueue = List.from(songs);
    _currentIndex = startIndex.clamp(0, songs.length - 1);

    final songToPlay = _queue[_currentIndex];
    _currentSong = songToPlay;

    // Update AudioHandler
    await _audioHandler.setCurrentMediaItem(_queue[_currentIndex]);
    _audioHandler.updateQueue(await _queueToMediaItems(_queue));

    notifyListeners();

    try {
      final mediaItem = await _songToMediaItem(songToPlay);
      _audioHandler.playMediaItem(mediaItem);
      await _audioPlayer.setFilePath(songToPlay.filePath);
      await _audioPlayer.play();
      _playbackStateEnum = PlaybackStateEnum.playing;
    } catch (e) {
      debugPrint('Error playing playlist: $e');
      _playbackStateEnum = PlaybackStateEnum.stopped;
    }

    notifyListeners();
  }

  void startSleepTimer(Duration duration) {
    _sleepTimer?.cancel();

    _sleepDuration = duration;
    notifyListeners();

    _sleepTimer = Timer(duration, () async {
      await stop();
      _clearSleepTimer();
    });
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _clearSleepTimer();
  }

  void _clearSleepTimer() {
    _sleepTimer = null;
    _sleepDuration = null;
    notifyListeners();
  }

  Future<MediaItem> _songToMediaItem(Song song) async {
    Uri? artUri = await ArtworkService.getArtworkUri(song.filePath);
    // If null, use default image from assets or network
    artUri ??= _audioHandler.getDefaultArtUri();
    return MediaItem(
      id: song.filePath,
      title: song.title,
      artist: song.artist,
      album: song.album,
      duration: totalDuration,
      artUri: artUri,
    );
  }

  // ===================== AudioHandler Sync =====================
  void _updateHandlerState() {
    _audioHandler.playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          _playbackStateEnum == PlaybackStateEnum.playing
              ? MediaControl.pause
              : MediaControl.play,
          MediaControl.skipToNext,
        ],
        androidCompactActionIndices: const [0, 1, 2],
        processingState: _mapProcessingState(_audioPlayer.processingState),
        playing: _playbackStateEnum == PlaybackStateEnum.playing,
        updatePosition: _currentPosition,
        bufferedPosition: _audioPlayer.bufferedPosition,
        speed: _audioPlayer.speed,
        systemActions: {
          MediaAction.seek,
          MediaAction.play,
          MediaAction.pause,
          MediaAction.stop,
          MediaAction.skipToNext,
          MediaAction.skipToPrevious,
        },
        queueIndex: _currentIndex,
        updateTime: DateTime.now(),
      ),
    );
  }



  void _updateHandlerPosition() {
    final current = _audioHandler.playbackState.value;
    _audioHandler.playbackState.add(
      current.copyWith(updatePosition: _currentPosition),
    );
  }

  AudioProcessingState _mapProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

}
