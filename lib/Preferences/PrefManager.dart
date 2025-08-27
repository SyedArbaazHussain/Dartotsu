import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartotsu/logger.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:objectbox/objectbox.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'objectbox.g.dart';

class Pref<T> {
  final String key;
  final T defaultValue;
  const Pref(this.key, this.defaultValue);
}

@Entity()
class CustomKeyValue {
  @Id()
  int id;
  @Unique()
  String key;
  String valueJson;
  CustomKeyValue({this.id = 0, required this.key, required this.valueJson});
}

class PrefManager {
  static late final Store _store;
  static late final Box<CustomKeyValue> _keyValueBox;
  static final Map<String, dynamic> cache = {};

  static Future<void> init() async {
    try {
      final dir = await getDirectory(subPath: 'settings');
      _store = await openStore(directory: dir!.path);
      _keyValueBox = _store.box<CustomKeyValue>();
      await _populateCache();
    } catch (e) {
      Logger.log('Error initializing preferences: $e');
    }
  }

  static void setVal<T>(Pref<T> pref, T value) =>
      setCustomVal<T>(pref.key, value);
  static T getVal<T>(Pref<T> pref) =>
      (cache[pref.key] as T?) ?? pref.defaultValue;
  static void removeVal<T>(Pref<dynamic> pref) => removeCustomVal<T>(pref.key);

  static void setCustomVal<T>(String key, T value) {
    cache[key] = value;
    final jsonStr = jsonEncode(value);
    final existing = _keyValueBox
        .query(CustomKeyValue_.key.equal(key))
        .build()
        .findFirst();
    if (existing != null) {
      existing.valueJson = jsonStr;
      _keyValueBox.put(existing);
    } else {
      _keyValueBox.put(CustomKeyValue(key: key, valueJson: jsonStr));
    }
  }

  static T? getCustomVal<T>(String key) => cache[key] as T?;

  static void removeCustomVal<T>(String key) {
    cache.remove(key);
    final item = _keyValueBox
        .query(CustomKeyValue_.key.equal(key))
        .build()
        .findFirst();
    if (item != null) _keyValueBox.remove(item.id);
  }

  static Future<void> _populateCache() async {
    for (var kv in _keyValueBox.getAll()) {
      cache[kv.key] = jsonDecode(kv.valueJson);
    }
  }

  static Future<Directory?> getDirectory({String? subPath}) async {
    final appDir = await getApplicationDocumentsDirectory();
    final baseDir = Directory(path.join(appDir.path, 'Dartotsu'));
    baseDir.createSync(recursive: true);
    if (subPath != null && subPath.isNotEmpty) {
      final subDir = Directory(path.join(baseDir.path, subPath));
      subDir.createSync(recursive: true);
      return subDir;
    }
    return baseDir;
  }

  static Future<bool> requestPermission() async {
    if (!Platform.isAndroid) return true;
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    if (androidInfo.version.sdkInt <= 29) {
      final storagePermission = Permission.storage;
      if (await storagePermission.isGranted) return true;
      return (await storagePermission.request()).isGranted;
    }
    final managePermission = Permission.manageExternalStorage;
    if (await managePermission.isGranted) return true;
    return (await managePermission.request()).isGranted;
  }
}

extension StringPathExtension on String {
  String get fixSeparator {
    if (Platform.isWindows) {
      return replaceAll("/", path.separator);
    } else {
      return replaceAll("\\\\", "/");
    }
  }
}
