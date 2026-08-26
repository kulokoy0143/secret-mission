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

  String get trainingGuidance {
    switch (level) {
      case RecoveryLevel.low:
        return 'Prioritize recovery today. Consider rest, mobility, or very light activity.';
      case RecoveryLevel.moderate:
        return 'Train lighter than usual. Reduce volume or intensity and avoid pushing to failure.';
      case RecoveryLevel.good:
        return 'You are ready to train normally. Follow your planned session.';
      case RecoveryLevel.excellent:
        return 'Recovery is excellent. Train as planned and push your normal working intensity.';
    }
  }

  String get trainingPlan {
    switch (level) {
      case RecoveryLevel.low:
        return 'Rest • Mobility • Light activity';
      case RecoveryLevel.moderate:
        return 'Reduce volume 20–30% • Avoid failure';
      case RecoveryLevel.good:
        return 'Normal training • Follow the plan';
      case RecoveryLevel.excellent:
        return 'Full planned training • Normal intensity';
    }
  }
}
