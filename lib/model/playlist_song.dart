import 'package:objectbox/objectbox.dart';
import 'package:wavy_muic_player/model/song.dart';

@Entity()
class PlaylistSong {
  @Id()
  int id = 0;

  int playlistId;

  final String filePath;
  final String title;
  final int? fileSize;
  final String fileName;

  PlaylistSong({
    required this.playlistId,
    required this.filePath,
    required this.title,
    required this.fileSize,
    required this.fileName,
  });

  String get artist => 'Unknown Artist';
  String get album => 'Unknown Album';


}
