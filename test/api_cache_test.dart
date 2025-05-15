import 'package:api_cache/api_cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'dart:io';

class TestHiveRepository implements HiveRepository {
  bool _isInitialized = false;

  @override
  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
  }

  @override
  Future<void> store({
    required String boxName,
    required String key,
    required dynamic data,
  }) async {
    final box = await Hive.openBox(boxName);
    await box.put(key, data);
  }

  @override
  Future<dynamic> retrieve({
    required String boxName,
    required String key,
    dynamic defaultValue,
  }) async {
    final box = await Hive.openBox(boxName);
    return box.get(key, defaultValue: defaultValue);
  }

  @override
  Future<void> delete({
    required String boxName,
    required String key,
  }) async {
    final box = await Hive.openBox(boxName);
    await box.delete(key);
  }

  @override
  Future<void> clear({
    required String boxName,
  }) async {
    final box = await Hive.openBox(boxName);
    await box.clear();
  }

  @override
  Future<bool> exists({
    required String boxName,
    required String key,
  }) async {
    final box = await Hive.openBox(boxName);
    return box.containsKey(key);
  }

  @override
  Future<void> close() async {
    await Hive.close();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory testDir;

  setUpAll(() async {
    testDir = Directory.systemTemp.createTempSync('api_cache_test');
    Hive.init(testDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    await testDir.delete(recursive: true);
  });

  group('API Cache Tests', () {
    late ApiCacheRepository apiCache;
    late TestHiveRepository hiveRepository;

    setUp(() async {
      hiveRepository = TestHiveRepository();
      apiCache = ApiCacheRepository(hiveRepository);
      await apiCache.init();
    });

    tearDown(() async {
      await Hive.deleteBoxFromDisk('api_cache_box');
    });

    test('Store and retrieve data', () async {
      const key = 'test_key';
      const data = {'test': 'data'};

      await apiCache.cacheData(cacheKey: key, data: data);
      final retrieved = await apiCache.getCachedData(cacheKey: key);

      expect(retrieved, equals(data));
    });

    test('Check cache expiration', () async {
      const key = 'expiring_key';
      const data = {'test': 'data'};
      const duration = Duration(seconds: 1);

      await apiCache.cacheData(
        cacheKey: key,
        data: data,
        expiration: duration,
      );
      await Future.delayed(const Duration(seconds: 2));

      final retrieved = await apiCache.getCachedData(cacheKey: key);
      expect(retrieved, isNull);
    });

    test('Check if cache exists', () async {
      const key = 'exists_key';
      const data = {'test': 'data'};

      await apiCache.cacheData(cacheKey: key, data: data);
      final exists = await apiCache.hasCachedData(key);

      expect(exists, isTrue);
    });

    test('Clear all cache', () async {
      const key1 = 'key1';
      const key2 = 'key2';
      const data = {'test': 'data'};

      await apiCache.cacheData(cacheKey: key1, data: data);
      await apiCache.cacheData(cacheKey: key2, data: data);
      await apiCache.clearCache();

      final exists1 = await apiCache.hasCachedData(key1);
      final exists2 = await apiCache.hasCachedData(key2);

      expect(exists1, isFalse);
      expect(exists2, isFalse);
    });
  });
}
