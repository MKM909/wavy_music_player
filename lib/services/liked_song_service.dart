import 'package:objectbox/objectbox.dart';
import '../model/liked_songs.dart';
import '../model/song.dart';
import '../objectbox.g.dart';

class LikedSongsService {
  static final LikedSongsService _instance = LikedSongsService._internal();

  Box<LikedSong>? _box;

  factory LikedSongsService() => _instance;
  LikedSongsService._internal();

  void init(Store store) {
    _box = store.box<LikedSong>();
  }

  Box<LikedSong> get _safeBox {
    if (_box == null) {
      throw Exception('LikedSongsService not initialized');
    }
    return _box!;
  }

  // ───────────────────────── CRUD ─────────────────────────

  List<LikedSong> getAll() => _safeBox.getAll();

  void addSong(LikedSong song) => _safeBox.put(song);

  void removeSong(String filePath) {
    final query =
    _safeBox.query(LikedSong_.filePath.equals(filePath)).build();
    final song = query.findFirst();
    query.close();
    if (song != null) _safeBox.remove(song.id);
  }

  bool isLiked(String filePath) {
    final query =
    _safeBox.query(LikedSong_.filePath.equals(filePath)).build();
    final liked = query.findFirst() != null;
    query.close();
    return liked;
  }

  // ───────────────────────── Helpers ─────────────────────────

  List<Song> getAllAsSongs() {
    return getAll()
        .map((liked) => Song(
      filePath: liked.filePath,
      title: liked.title,
      fileName: liked.title,
    ))
        .toList();
  }

  int indexOf(String filePath) {
    final list = getAll();
    return list.indexWhere((s) => s.filePath == filePath);
  }

  Stream<List<LikedSong>> watchAll() {
    return _safeBox
        .query()
        .watch(triggerImmediately: true)
        .map((q) => q.find());
  }

  Stream<bool> watchIsLiked(String filePath) {
    return _safeBox
        .query(LikedSong_.filePath.equals(filePath))
        .watch(triggerImmediately: true)
        .map((q) {
      final liked = q.findFirst() != null;
      q.close();
      return liked;
    });
  }


}
