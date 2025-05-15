import 'package:flutter/material.dart';
import 'package:api_cache/api_cache.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API Cache Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _apiCache = ApiCacheRepository(HiveRepositoryImpl());
  String _cachedData = 'No data cached yet';

  @override
  void initState() {
    super.initState();
    _initializeCache();
  }

  Future<void> _initializeCache() async {
    await _apiCache.init();
  }

  Future<void> _cacheData() async {
    // Example data to cache
    final data = {
      'id': 1,
      'name': 'Example Data',
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Cache data with 1 hour expiration
    await _apiCache.cacheData(
      cacheKey: 'example_key',
      data: data,
      expiration: const Duration(hours: 1),
    );

    setState(() {
      _cachedData = 'Data cached successfully!';
    });
  }

  Future<void> _retrieveData() async {
    final data = await _apiCache.getCachedData(
      cacheKey: 'example_key',
      defaultValue: 'No data found',
    );

    setState(() {
      _cachedData = data.toString();
    });
  }

  Future<void> _clearCache() async {
    await _apiCache.clearCache();
    setState(() {
      _cachedData = 'Cache cleared!';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Cache Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Cached Data:\n$_cachedData',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _cacheData,
              child: const Text('Cache Data'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _retrieveData,
              child: const Text('Retrieve Data'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _clearCache,
              child: const Text('Clear Cache'),
            ),
          ],
        ),
      ),
    );
  }
}
