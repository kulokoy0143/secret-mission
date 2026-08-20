enum RecoveryLevel { low, moderate, good, excellent }

class RecoveryStatus {
  const RecoveryStatus({required this.score, required this.level});

  final int score;
  final RecoveryLevel level;

  String get label {
    switch (level) {
      case RecoveryLevel.low:
        return 'RECOVER';
      case RecoveryLevel.moderate:
        return 'TAKE IT EASY';
      case RecoveryLevel.good:
        return 'READY TO TRAIN';
      case RecoveryLevel.excellent:
        return 'MISSION READY';
    }
  }
}
