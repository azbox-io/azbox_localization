import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'storage.dart';

class CacheStorage implements Storage {
  static late HiveInterface hiveInstance;
  static dynamic encryptionKey;
  static late Directory? appDir;
  static String boxeName = '_azbox_';
  CacheStorage._internal();
  static late Box<dynamic> box;
  static final CacheStorage instance = CacheStorage._internal();

  factory CacheStorage() {
    setUpHive();
    return instance;
  }

  CacheStorage.testing(HiveInterface hiveMock) {
    hiveInstance = hiveMock;
    appDir = Directory.current;
  }

  static Future<void> setUpHive() async {
    hiveInstance = Hive;
    await hiveInstance.initFlutter();
    
    if (kIsWeb) {
      appDir = Directory('/assets/db');
    } else {
      appDir = await getApplicationDocumentsDirectory();
    }
    
    box = await hiveInstance.openBox(boxeName);
  }

  @override
  Future<void> clear({String? keyCache}) async {
    if (keyCache == null) {
      await box.clear();
    } else {
      for (var key in box.keys) {
        if (key is String && key.startsWith(keyCache)) {
          await box.delete(key);
        }
      }
    }
  }

  @override
  dynamic read(String keyCache) {
    return box.get(keyCache);
  }

  @override
  Future<void> write(String keyCache, dynamic value) async {
    return box.put(keyCache, value);
  }
}
