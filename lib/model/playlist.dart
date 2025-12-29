import 'package:objectbox/objectbox.dart';

@Entity()
class Playlist {
  @Id()
  int id = 0;

  String name;
  int createdAt;

  Playlist({
    required this.name,
    int? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;
}
