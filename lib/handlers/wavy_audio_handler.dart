import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import '../controllers/music_controller.dart';
import '../model/song.dart';
import '../services/artwork_service.dart';

class WavyAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  late MusicController musicController;
  late Uri? defaultArtUri;


  WavyAudioHandler(this.musicController) {
    _initDefaultArt();
    _notifyAudioHandlerAboutPlaybackEvents();
  }

  /// Load default placeholder image once
  Future<void> _initDefaultArt() async {
    final byteData = await rootBundle.load('assets/default_placeholder_image.jpg');
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/default_placeholder_image.jpg');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    defaultArtUri = file.uri;
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    // Sync playback state from MusicController's AudioPlayer
    musicController.audioPlayer.playbackEventStream.listen((event) {
      final playing = musicController.audioPlayer.playing;

      playbackState.add(
        PlaybackState(
          processingState: _mapProcessingState(
              musicController.audioPlayer.processingState),
          playing: playing,
          controls: [
            MediaControl.skipToPrevious,
            playing ? MediaControl.pause : MediaControl.play,
            MediaControl.skipToNext,
          ],
          androidCompactActionIndices: const [0, 1, 2],
          updatePosition: musicController.currentPosition,
          bufferedPosition: musicController.audioPlayer.bufferedPosition,
          speed: musicController.audioPlayer.speed,
          updateTime: DateTime.now(),
          // ✅ This is crucial for enabling seeking
          systemActions: {
            MediaAction.seek,
            MediaAction.play,
            MediaAction.pause,
            MediaAction.stop,
            MediaAction.skipToNext,
            MediaAction.skipToPrevious,
          },
        ),
      );
    });
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

  // Helper to build MediaItem with artwork
  Future<MediaItem> songToMediaItem(Song song) async {
    Uri? artUri = await ArtworkService.getArtworkUri(song.filePath);
    // If null, use default image from assets or network
    artUri ??= defaultArtUri;
    return MediaItem(
      id: song.filePath,
      title: song.title,
      artist: song.artist,
      album: song.album,
      duration: musicController.totalDuration,
      artUri: artUri,
    );

  }

  // =================== BaseAudioHandler overrides ===================

  @override
  Future<void> play() => musicController.resume();

  @override
  Future<void> pause() => musicController.pause();

  @override
  Future<void> stop() => musicController.stop();

  @override
  Future<void> seek(Duration position) =>
      musicController.seek(position);

  @override
  Future<void> skipToNext() => musicController.playNext();

  @override
  Future<void> skipToPrevious() => musicController.playPrevious();

  @override
  Future<void> updateQueue(List<MediaItem> items) async {
    queue.add(items); // `this.queue` is the AudioHandler queue
  }


  // Notify handler of current media item
  Future<void> setCurrentMediaItem(Song song) async {
    // Load the file first
    await musicController.audioPlayer.setFilePath(song.filePath);

    // Get duration
    final duration = musicController.audioPlayer.duration;

    // Get artwork
    Uri? artUri = await ArtworkService.getArtworkUri(song.filePath);
    artUri ??=  defaultArtUri;

    // Update mediaItem with proper duration
    mediaItem.add(MediaItem(
      id: song.filePath,
      title: song.title,
      artist: song.artist,
      album: song.album,
      duration: duration,
      artUri: artUri,
    ));
  }


  /// Returns the default art URI for MusicController
  Uri? getDefaultArtUri() => defaultArtUri;
}
