import 'package:objectbox/objectbox.dart';
import '../objectbox.g.dart';

class ObjectBoxService {
  static final ObjectBoxService _instance = ObjectBoxService._internal();

  late final Store store;

  factory ObjectBoxService() => _instance;
  ObjectBoxService._internal();

  Future<void> init() async {
    store = await openStore();
  }
}
