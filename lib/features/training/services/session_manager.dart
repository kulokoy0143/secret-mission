import 'package:flutter/foundation.dart';

class SessionManager {
  SessionManager._();

  static String? _currentSessionId;

  static DateTime? _workoutStartedAt;

  /// Returns the active workout session ID.
  static String get currentSessionId {
    if (_currentSessionId == null) {
      startWorkout();
    }

    return _currentSessionId!;
  }

  /// Starts a brand-new workout session.
  static void startWorkout() {
    _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
    _workoutStartedAt = DateTime.now();

    debugPrint('Workout Started: $_currentSessionId');
  }

  /// Ends the current workout.
  static void endWorkout() {
    debugPrint('Workout Ended: $_currentSessionId');

    _currentSessionId = null;
    _workoutStartedAt = null;
  }

  /// Whether a workout is currently active.
  static bool get isWorkoutActive => _currentSessionId != null;

  /// When the workout started.
  static DateTime? get workoutStartedAt => _workoutStartedAt;
}