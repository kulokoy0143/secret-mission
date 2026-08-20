import 'package:hive_flutter/hive_flutter.dart';

class RecoveryStorageService {
  static const String boxName = 'recovery_data';

  static Box<dynamic> get _box => Hive.box<dynamic>(boxName);

  static int getSleepMinutes() {
    return _box.get('sleepMinutes', defaultValue: 465) as int;
  }

  static int getSleepQuality() {
    return _box.get('sleepQuality', defaultValue: 4) as int;
  }

  static Future<void> saveSleep({
    required int sleepMinutes,
    required int sleepQuality,
  }) async {
    await _box.put('sleepMinutes', sleepMinutes);
    await _box.put('sleepQuality', sleepQuality);
  }
}
