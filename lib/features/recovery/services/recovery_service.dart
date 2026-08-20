import 'package:secret_mission/features/recovery/models/recovery_status.dart';
import 'package:secret_mission/features/recovery/models/sleep_entry.dart';

class RecoveryService {
  static RecoveryStatus calculateRecovery(SleepEntry sleep) {
    final sleepScore = _calculateSleepScore(sleep);

    if (sleepScore >= 90) {
      return const RecoveryStatus(score: 95, level: RecoveryLevel.excellent);
    }

    if (sleepScore >= 75) {
      return RecoveryStatus(score: sleepScore, level: RecoveryLevel.good);
    }

    if (sleepScore >= 55) {
      return RecoveryStatus(score: sleepScore, level: RecoveryLevel.moderate);
    }

    return RecoveryStatus(score: sleepScore, level: RecoveryLevel.low);
  }

  static int _calculateSleepScore(SleepEntry sleep) {
    final durationScore = _durationScore(sleep.sleepMinutes);
    final qualityScore = sleep.quality.clamp(1, 5) * 20;

    return ((durationScore * 0.7) + (qualityScore * 0.3)).round().clamp(0, 100);
  }

  static int _durationScore(int minutes) {
    if (minutes >= 480) return 100;
    if (minutes >= 420) return 90;
    if (minutes >= 360) return 75;
    if (minutes >= 300) return 55;

    return 35;
  }
}
