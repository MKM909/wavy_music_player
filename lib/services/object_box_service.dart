import 'package:objectbox/objectbox.dart';
import '../objectbox.g.dart';

class ObjectBoxService {
  static final ObjectBoxService _instance = ObjectBoxService._internal();
  Store? _store;

  factory ObjectBoxService() => _instance;
  ObjectBoxService._internal();

  Future<Store> init() async {
    if (_store != null) return _store!;
    _store = await openStore();
    return _store!;
  }

  Store get store {
    if (_store == null) {
      throw Exception('ObjectBox not initialized');
    }
    return _store!;
  }
}
