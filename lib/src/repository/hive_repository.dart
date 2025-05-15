/// Interface defining storage operations
abstract class HiveRepository {
  Future<void> init();
  Future<void> store({
    required String boxName,
    required String key,
    required dynamic data,
  });
  Future<dynamic> retrieve({
    required String boxName,
    required String key,
    dynamic defaultValue,
  });
  Future<void> delete({required String boxName, required String key});
  Future<void> clear({required String boxName});
  Future<bool> exists({required String boxName, required String key});
  Future<void> close();
}
