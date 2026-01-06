import 'package:objectbox/objectbox.dart';
import '../objectbox.g.dart';

class ObjectBoxService {
  static final ObjectBoxService _instance = ObjectBoxService._internal();
  factory ObjectBoxService() => _instance;
  ObjectBoxService._internal();

  Store? _store;
  bool _isInitializing = false;

  /// Lazy init store - PREVENTS DOUBLE INITIALIZATION
  Future<Store> init() async {
    // Already initialized and open? Return it
    if (_store != null && !_store!.isClosed()) {
      return _store!;
    }

    // Currently initializing? Wait for it
    if (_isInitializing) {
      // Wait a bit and check again
      await Future.delayed(const Duration(milliseconds: 100));
      return init(); // Recursive check
    }

    try {
      _isInitializing = true;

      // Close any existing store first
      if (_store != null) {
        _store!.close();
        _store = null;
      }

      _store = await openStore();
      return _store!;
    } finally {
      _isInitializing = false;
    }
  }

  /// Safe access
  Store get store {
    if (_store == null || _store!.isClosed()) {
      throw Exception('ObjectBox store not initialized. Call init() first.');
    }
    return _store!;
  }

  /// Check if initialized
  bool get isInitialized => _store != null && !_store!.isClosed();

  /// Close the store when app is terminating
  Future<void> close() async {
    if (_store != null && !_store!.isClosed()) {
      _store!.close();
    }
    _store = null;
  }
}
