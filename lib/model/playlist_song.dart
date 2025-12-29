import 'package:objectbox/objectbox.dart';

@Entity()
class PlaylistSong {
  @Id()
  int id = 0;

  int playlistId;

  String filePath;
  String title;
  int fileSize;

  PlaylistSong({
    required this.playlistId,
    required this.filePath,
    required this.title,
    required this.fileSize,
  });
}
