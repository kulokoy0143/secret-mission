import 'package:hive/hive.dart';

part 'workout_set.g.dart';

@HiveType(typeId: 0)
class WorkoutSet extends HiveObject {
  WorkoutSet({
    required this.exerciseName,
    required this.setNumber,
    required this.weight,
    required this.reps,
    required this.unit,
    required this.completedAt,
    required this.workoutName,
    this.sessionId,
  });

  @HiveField(0)
  final String exerciseName;

  @HiveField(1)
  final int setNumber;

  @HiveField(2)
  final double weight;

  @HiveField(3)
  final int reps;

  @HiveField(4)
  final String unit;

  @HiveField(5)
  final DateTime completedAt;

  // Nullable so workout sets saved before Mission 4 remain compatible.
  @HiveField(6)
  final String? sessionId;

  @HiveField(7)
  final String workoutName;

  double get volume => weight * reps;
}
