abstract class Storage {
  Future<void> write(String key, dynamic value);
  dynamic read(String key);
  Future<void> clear({String? keyCache});
}
