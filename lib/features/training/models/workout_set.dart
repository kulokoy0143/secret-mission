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

  double get volume => weight * reps;
}
