# API Cache

[![pub package](https://img.shields.io/pub/v/api_cache.svg)](https://pub.dev/packages/api_cache)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![CI](https://github.com/yourusername/api_cache/actions/workflows/ci.yml/badge.svg)](https://github.com/yourusername/api_cache/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/yourusername/api_cache/branch/main/graph/badge.svg)](https://codecov.io/gh/yourusername/api_cache)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

A Flutter package for caching API responses with expiration support using Hive.

## Features

- Cache API responses with optional expiration
- Automatic data normalization
- Type-safe data retrieval
- Easy to use API
- Built on top of Hive for efficient storage

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  api_cache: ^1.0.0
```

## Usage

### 1. Initialize the Cache

```dart
import 'package:api_cache/api_cache.dart';

// Initialize the cache
final apiCache = ApiCacheRepository(HiveRepositoryImpl());
await apiCache.init();
```

### 2. Cache Data

```dart
// Cache data with expiration
await apiCache.cacheData(
  cacheKey: 'user_profile',
  data: {
    'id': 1,
    'name': 'John Doe',
    'email': 'john@example.com',
  },
  expiration: const Duration(hours: 1),
);

// Cache data without expiration (stays until cleared)
await apiCache.cacheData(
  cacheKey: 'app_settings',
  data: {
    'theme': 'dark',
    'notifications': true,
  },
);
```

### 3. Retrieve Cached Data

```dart
// Get cached data with default value
final userData = await apiCache.getCachedData(
  cacheKey: 'user_profile',
  defaultValue: null,
);

// Get cached data with type safety
final settings = await apiCache.getCachedData<Map<String, dynamic>>(
  cacheKey: 'app_settings',
  defaultValue: {'theme': 'light', 'notifications': false},
);
```

### 4. Check Cache Status

```dart
// Check if data exists in cache
final exists = await apiCache.hasCachedData('user_profile');

// Check if data is expired
final isExpired = await apiCache.isExpired('user_profile');
```

### 5. Cache Management

```dart
// Clear specific cache
await apiCache.clearCache('user_profile');

// Clear all cache
await apiCache.clearAllCache();

// Get cache size
final size = await apiCache.getCacheSize();
```

### 6. Error Handling

```dart
try {
  await apiCache.cacheData(
    cacheKey: 'user_profile',
    data: userData,
    expiration: const Duration(hours: 1),
  );
} catch (e) {
  print('Error caching data: $e');
}
```

## API Reference

### ApiCacheRepository

The main class for managing API cache operations.

#### Methods

- `init()`: Initialize the cache system
- `cacheData({required String cacheKey, required dynamic data, Duration? expiration})`: Cache data with optional expiration
- `getCachedData<T>({required String cacheKey, required T defaultValue})`: Retrieve cached data with type safety
- `hasCachedData(String cacheKey)`: Check if data exists in cache
- `isExpired(String cacheKey)`: Check if cached data is expired
- `clearCache(String cacheKey)`: Clear specific cache
- `clearAllCache()`: Clear all cached data
- `getCacheSize()`: Get total cache size

### HiveRepositoryImpl

Implementation of the cache storage using Hive.

#### Methods

- `init()`: Initialize Hive storage
- `save(String key, dynamic value)`: Save data to Hive
- `get(String key)`: Retrieve data from Hive
- `delete(String key)`: Delete data from Hive
- `clear()`: Clear all data from Hive

## Example

Check out the [example](example/lib/main.dart) for a complete usage example.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/yourusername/api_cache/issues