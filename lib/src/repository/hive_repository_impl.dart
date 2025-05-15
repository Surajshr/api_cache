import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:api_cache/src/repository/hive_repository.dart';

/// Implementation of local storage using Hive
class HiveRepositoryImpl implements HiveRepository {
  bool _isInitialized = false;

  @override
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Check if Hive is already initialized (for test environment)
      if (!Hive.isBoxOpen('api_cache_box')) {
        final appDocumentDir =
            await path_provider.getApplicationDocumentsDirectory();
        Hive.init(appDocumentDir.path);
      }
      _isInitialized = true;
    } catch (e) {
      print('Hive initialization failed: $e');
      throw Exception('Failed to initialize Hive: $e');
    }
  }

  @override
  Future<void> store({
    required String boxName,
    required String key,
    required dynamic data,
  }) async {
    try {
      final box = await Hive.openBox(boxName);
      await box.put(key, data);
    } catch (e) {
      throw Exception('Failed to store data in Hive: $e');
    }
  }

  @override
  Future<dynamic> retrieve({
    required String boxName,
    required String key,
    dynamic defaultValue,
  }) async {
    try {
      await init();
      final box = await Hive.openBox(boxName);
      return box.get(key, defaultValue: defaultValue);
    } catch (e) {
      throw Exception('Failed to retrieve data from Hive: $e');
    }
  }

  @override
  Future<void> delete({
    required String boxName,
    required String key,
  }) async {
    try {
      await init();
      final box = await Hive.openBox(boxName);
      await box.delete(key);
    } catch (e) {
      throw Exception('Failed to delete data from Hive: $e');
    }
  }

  @override
  Future<void> clear({
    required String boxName,
  }) async {
    try {
      await init();
      final box = await Hive.openBox(boxName);
      await box.clear();
    } catch (e) {
      throw Exception('Failed to clear Hive box: $e');
    }
  }

  @override
  Future<bool> exists({
    required String boxName,
    required String key,
  }) async {
    try {
      await init();
      final box = await Hive.openBox(boxName);
      return box.containsKey(key);
    } catch (e) {
      throw Exception('Failed to check if key exists in Hive: $e');
    }
  }

  @override
  Future<void> close() async {
    try {
      await Hive.close();
    } catch (e) {
      throw Exception('Failed to close Hive: $e');
    }
  }
}
