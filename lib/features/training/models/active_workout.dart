enum WorkoutType {
  push,
  pull,
  legs,
  upper,
  lower,
  fullBody,
  custom,
}

extension WorkoutTypeDetails on WorkoutType {
  String get displayName {
    switch (this) {
      case WorkoutType.push:
        return 'Push Day';
      case WorkoutType.pull:
        return 'Pull Day';
      case WorkoutType.legs:
        return 'Leg Day';
      case WorkoutType.upper:
        return 'Upper Body';
      case WorkoutType.lower:
        return 'Lower Body';
      case WorkoutType.fullBody:
        return 'Full Body';
      case WorkoutType.custom:
        return 'Custom Workout';
    }
  }
}

class ActiveWorkout {
  const ActiveWorkout({
    required this.sessionId,
    required this.name,
    required this.type,
    required this.startedAt,
  });

  final String sessionId;
  final String name;
  final WorkoutType type;
  final DateTime startedAt;

  Duration get elapsedTime {
    return DateTime.now().difference(startedAt);
  }
}