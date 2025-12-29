import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../bottom_sheets/queue_editor_sheet.dart';
import '../model/song.dart';
import '../services/music_library_service.dart';

enum PlaybackState {
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
  PlaybackState _playbackState = PlaybackState.stopped;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isShuffleOn = false;
  RepeatMode _repeatMode = RepeatMode.off;

  // Queue management
  List<Song> _queue = [];
  List<Song> _originalQueue = []; // For shuffle
  int _currentIndex = 0;

  // Getters
  Song? get currentSong => _currentSong;
  PlaybackState get playbackState => _playbackState;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  bool get isPlaying => _playbackState == PlaybackState.playing;
  bool get isShuffleOn => _isShuffleOn;
  RepeatMode get repeatMode => _repeatMode;
  List<Song> get queue => _queue;
  int get currentIndex => _currentIndex;
  bool get hasNext => _currentIndex < _queue.length - 1;
  bool get hasPrevious => _currentIndex > 0;

  MusicController() {
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    // Listen to position updates
    _audioPlayer.positionStream.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });

    // Listen to duration updates
    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        _totalDuration = duration;
        notifyListeners();
      }
    });

    _audioPlayer.playerStateStream.listen((state) {
      final playing = state.playing;

      if (state.processingState == ProcessingState.completed) {
        _onSongComplete();
        return;
      }

      if (playing) {
        _playbackState = PlaybackState.playing;
      } else if (state.processingState == ProcessingState.ready) {
        _playbackState = PlaybackState.paused;
      } else if (state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering) {
        _playbackState = PlaybackState.loading;
      }

      notifyListeners();
    });

  }

  // ========== PLAYBACK CONTROLS ==========

  Future<void> playSong(Song song, {List<Song>? newQueue, int? startIndex}) async {
    try {
      _playbackState = PlaybackState.loading;
      notifyListeners();

      // Update queue if provided
      if (newQueue != null) {
        _queue = List.from(newQueue);
        _originalQueue = List.from(newQueue);
        _currentIndex = startIndex ?? 0;
      }

      _currentSong = song;

      // Load and play the song
      await _audioPlayer.setFilePath(song.filePath);
      await _audioPlayer.play();

      _playbackState = PlaybackState.playing;
      notifyListeners();
    } catch (e) {
      print('Error playing song: $e');
      _playbackState = PlaybackState.stopped;
      notifyListeners();
    }
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
    await _audioPlayer.stop();
    _playbackState = PlaybackState.stopped;
    _currentPosition = Duration.zero;
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
    notifyListeners();
  }

  // ========== QUEUE MANAGEMENT ==========

  Future<void> playNext() async {
    if (!hasNext) {
      if (_repeatMode == RepeatMode.all) {
        _currentIndex = 0;
      } else {
        return;
      }
    } else {
      _currentIndex++;
    }

    if (_currentIndex < _queue.length) {
      await playSong(_queue[_currentIndex]);
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
    if (_repeatMode == RepeatMode.one) {
      playSong(_currentSong!);
    } else {
      playNext();
    }
  }

  // ========== SHUFFLE & REPEAT ==========

  void toggleShuffle() {
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

  void addToQueue(Song song) {
    _queue.add(song);
    _originalQueue.add(song);
    notifyListeners();
  }

  void removeFromQueue(int index) {
    if (index < _queue.length) {
      final song = _queue[index];
      _queue.removeAt(index);
      _originalQueue.remove(song);

      // Adjust current index if needed
      if (index < _currentIndex) {
        _currentIndex--;
      }

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

  bool get isSpinning => _playbackState == PlaybackState.playing;

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

}
