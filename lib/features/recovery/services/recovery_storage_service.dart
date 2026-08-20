import 'package:hive_flutter/hive_flutter.dart';
import 'package:secret_mission/features/recovery/models/sleep_entry.dart';

class RecoveryStorageService {
  static String _dateKey(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return 'sleep_$year-$month-$day';
  }

  static Future<void> saveSleepEntry(SleepEntry entry) async {
    await _box.put(_dateKey(entry.date), {
      'sleepMinutes': entry.sleepMinutes,
      'quality': entry.quality,
    });
  }

  static SleepEntry? getSleepEntry(DateTime date) {
    final data = _box.get(_dateKey(date));

    if (data == null) {
      return null;
    }

    final values = Map<String, dynamic>.from(data as Map);

    return SleepEntry(
      date: DateTime(date.year, date.month, date.day),
      sleepMinutes: (values['sleepMinutes'] as num).toInt(),
      quality: (values['quality'] as num).toInt(),
    );
  }

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
