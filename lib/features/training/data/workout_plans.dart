import 'package:secret_mission/features/training/models/active_workout.dart';

class WorkoutPlan {
  final String name;
  final List<String> exercises;

  const WorkoutPlan({
    required this.name,
    required this.exercises,
  });
}

class WorkoutPlans {
  static const push = WorkoutPlan(
    name: 'Push Day',
    exercises: [
      'Incline Bench Press',
      'Machine Chest Press',
      'Seated Shoulder Press',
      'Lateral Raise',
      'Triceps Pushdown',
    ],
  );

  static const pull = WorkoutPlan(
    name: 'Pull Day',
    exercises: [
      'Lat Pulldown',
      'Chest Supported Row',
      'Seated Cable Row',
      'Face Pull',
      'Hammer Curl',
    ],
  );

  static const legs = WorkoutPlan(
    name: 'Leg Day',
    exercises: [
      'Barbell Squat',
      'Romanian Deadlift',
      'Leg Press',
      'Leg Curl',
      'Standing Calf Raise',
    ],
  );

  static const upper = WorkoutPlan(
    name: 'Upper Body',
    exercises: [
      'Bench Press',
      'Pull-Up',
      'Shoulder Press',
      'Cable Row',
      'Bicep Curl',
    ],
  );

  static const lower = WorkoutPlan(
    name: 'Lower Body',
    exercises: [
      'Squat',
      'Romanian Deadlift',
      'Walking Lunges',
      'Leg Extension',
      'Seated Calf Raise',
    ],
  );

  static const fullBody = WorkoutPlan(
    name: 'Full Body',
    exercises: [
      'Squat',
      'Bench Press',
      'Lat Pulldown',
      'Shoulder Press',
      'Plank',
    ],
  );

  static const custom = WorkoutPlan(
    name: 'Custom Workout',
    exercises: [],
  );

  static WorkoutPlan forType(WorkoutType type) {
  switch (type) {
    case WorkoutType.push:
      return push;
    case WorkoutType.pull:
      return pull;
    case WorkoutType.legs:
      return legs;
    case WorkoutType.upper:
      return upper;
    case WorkoutType.lower:
      return lower;
    case WorkoutType.fullBody:
      return fullBody;
    case WorkoutType.custom:
      return custom;
  }
}
  
}
