import 'dart:convert';
import 'package:api_cache/src/constants/hive_constants.dart';
import 'package:api_cache/src/repository/hive_repository.dart';

/// Repository for caching API responses
class ApiCacheRepository {
  ApiCacheRepository(this._localStorage);
  final HiveRepository _localStorage;

  Future<void> init() async {
    await _localStorage.init();
  }

  /// Store JSON data with optional expiration
  Future<void> cacheData({
    required String cacheKey,
    required dynamic data,
    Duration? expiration,
  }) async {
    try {
      const boxName = HiveConstants.apiCacheBoxName;

      // Normalize data to ensure proper typing
      dynamic normalizedData = data;
      if (data is Map || data is List) {
        final jsonString = jsonEncode(data);
        normalizedData = jsonDecode(jsonString);
      }

      if (expiration != null) {
        final expirationTime =
            DateTime.now().add(expiration).millisecondsSinceEpoch;
        await _localStorage.store(
          boxName: boxName,
          key: cacheKey,
          data: {
            'data': normalizedData,
            'expirationTime': expirationTime,
          },
        );
      } else {
        await _localStorage.store(
          boxName: boxName,
          key: cacheKey,
          data: normalizedData,
        );
      }
    } catch (e) {
      throw Exception('Failed to cache API data: $e');
    }
  }

  /// Retrieve cached data, respecting expiration if set
  Future<dynamic> getCachedData({
    required String cacheKey,
    dynamic defaultValue,
  }) async {
    try {
      const boxName = HiveConstants.apiCacheBoxName;
      final storedData = await _localStorage.retrieve(
        boxName: boxName,
        key: cacheKey,
        defaultValue: null,
      );

      if (storedData == null) {
        return defaultValue;
      }

      // Check if this is data with expiration
      if (storedData is Map && storedData.containsKey('expirationTime')) {
        final expirationTime = storedData['expirationTime'] as num;
        final currentTime = DateTime.now().millisecondsSinceEpoch;

        if (currentTime > expirationTime) {
          // Data is expired, delete it and return default value
          await _localStorage.delete(boxName: boxName, key: cacheKey);
          return defaultValue;
        }

        // Normalize the retrieved data to ensure proper typing
        dynamic retrievedData = storedData['data'];
        if (retrievedData is Map || retrievedData is List) {
          final jsonString = jsonEncode(retrievedData);
          retrievedData = jsonDecode(jsonString);
        }

        return retrievedData;
      }

      // Normalize non-expiring data too
      if (storedData is Map || storedData is List) {
        final jsonString = jsonEncode(storedData);
        return jsonDecode(jsonString);
      }

      return storedData;
    } catch (e) {
      throw Exception('Failed to retrieve cached API data: $e');
    }
  }

  /// Clear all cached API data
  Future<void> clearCache() async {
    try {
      await _localStorage.clear(
        boxName: HiveConstants.apiCacheBoxName,
      );
    } catch (e) {
      throw Exception('Failed to clear API cache: $e');
    }
  }

  /// Check if cache exists for a key
  Future<bool> hasCachedData(String cacheKey) async {
    try {
      return await _localStorage.exists(
        boxName: HiveConstants.apiCacheBoxName,
        key: cacheKey,
      );
    } catch (e) {
      throw Exception('Failed to check if cached data exists: $e');
    }
  }
}
