import 'package:flutter/foundation.dart';
import 'package:secret_mission/features/training/models/active_workout.dart';

class SessionManager {
  SessionManager._();

  static ActiveWorkout? _activeWorkout;

  static final ValueNotifier<String?> sessionNotifier = ValueNotifier<String?>(
    null,
  );

  static ActiveWorkout? get activeWorkout => _activeWorkout;

  static bool get isWorkoutActive => _activeWorkout != null;

  static String? get currentSessionId => _activeWorkout?.sessionId;

  static DateTime? get workoutStartedAt => _activeWorkout?.startedAt;

  static void startWorkout({required WorkoutType type, String? customName}) {
    if (_activeWorkout != null) {
      debugPrint('Workout already active: ${_activeWorkout!.sessionId}');
      return;
    }

    final now = DateTime.now();

    final workoutName = type == WorkoutType.custom
        ? _resolveCustomName(customName)
        : type.displayName;

    _activeWorkout = ActiveWorkout(
      sessionId: now.microsecondsSinceEpoch.toString(),
      name: workoutName,
      type: type,
      startedAt: now,
    );

    debugPrint(
      'Workout started: '
      '${_activeWorkout!.name} '
      '(${_activeWorkout!.sessionId})',
    );
  }

  static ActiveWorkout? finishWorkout() {
    final finishedWorkout = _activeWorkout;

    if (finishedWorkout == null) {
      debugPrint('No active workout to finish.');
      return null;
    }

    debugPrint(
      'Workout finished: '
      '${finishedWorkout.name} '
      '(${finishedWorkout.sessionId})',
    );

    _activeWorkout = null;

    return finishedWorkout;
  }

  static void cancelWorkout() {
    if (_activeWorkout == null) {
      return;
    }

    debugPrint(
      'Workout cancelled: '
      '${_activeWorkout!.name} '
      '(${_activeWorkout!.sessionId})',
    );

    _activeWorkout = null;
  }

  static String _resolveCustomName(String? customName) {
    final cleanedName = customName?.trim();

    if (cleanedName == null || cleanedName.isEmpty) {
      return WorkoutType.custom.displayName;
    }

    return cleanedName;
  }
}
