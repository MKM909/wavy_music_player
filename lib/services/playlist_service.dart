import 'package:objectbox/objectbox.dart';
import '../model/playlist.dart';
import '../model/playlist_song.dart';
import '../model/song.dart';
import '../objectbox.g.dart';

class PlaylistService {
  static final PlaylistService _instance = PlaylistService._internal();

  late final Box<Playlist> _playlistBox;
  late final Box<PlaylistSong> _songBox;

  factory PlaylistService() => _instance;
  PlaylistService._internal();

  void init(Store store) {
    _playlistBox = store.box<Playlist>();
    _songBox = store.box<PlaylistSong>();
  }

  // ───────── PLAYLIST CRUD ─────────

  List<Playlist> getAllPlaylists() =>
      _playlistBox.getAll();

  int createPlaylist(String name) {
    return _playlistBox.put(Playlist(name: name));
  }

  void deletePlaylist(int playlistId) {
    _songBox
        .query(PlaylistSong_.playlistId.equals(playlistId))
        .build()
        .find()
        .forEach((s) => _songBox.remove(s.id));

    _playlistBox.remove(playlistId);
  }

  // ───────── SONGS ─────────

  bool addSongToPlaylist(int playlistId, Song song) {
    // ⛔ Prevent duplicates in same playlist
    final exists = _songBox.query(
      PlaylistSong_.playlistId.equals(playlistId) &
      PlaylistSong_.filePath.equals(song.filePath),
    ).build().findFirst();

    if (exists != null) {
      return false; // Song already exists → do nothing
    }

    _songBox.put(
      PlaylistSong(
        playlistId: playlistId,
        filePath: song.filePath,
        title: song.title,
        fileSize: song.fileSize!,
        fileName: song.fileName,
      ),
    );

    return true;
  }


  void removeSongFromPlaylist(int playlistId, String filePath) {
    final q = _songBox.query(
      PlaylistSong_.playlistId.equals(playlistId) &
      PlaylistSong_.filePath.equals(filePath),
    ).build();

    final s = q.findFirst();
    q.close();

    if (s != null) _songBox.remove(s.id);
  }

  List<PlaylistSong> getSongs(int playlistId) {
    return _songBox
        .query(PlaylistSong_.playlistId.equals(playlistId))
        .build()
        .find();
  }

  bool containsSong(int playlistId, String filePath) {
    final q = _songBox.query(
      PlaylistSong_.playlistId.equals(playlistId) &
      PlaylistSong_.filePath.equals(filePath),
    ).build();

    final exists = q.findFirst() != null;
    q.close();
    return exists;
  }

  Stream<List<Playlist>> watchPlaylists() {
    return _playlistBox
        .query()
        .watch(triggerImmediately: true)
        .map((q) => q.find());
  }
}
