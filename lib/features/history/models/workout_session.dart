import 'package:secret_mission/features/training/models/workout_set.dart';

class WorkoutSession {
  const WorkoutSession({
    required this.sessionId,
    required this.startedAt,
    required this.sets,
  });

  final String sessionId;
  final DateTime startedAt;
  final List<WorkoutSet> sets;

  int get totalSets => sets.length;

  int get exerciseCount {
    return sets.map((set) => set.exerciseName).toSet().length;
  }

  double get totalVolume {
    return sets.fold(
      0,
      (total, set) => total + set.volume,
    );
  }

  DateTime get finishedAt {
    if (sets.isEmpty) {
      return startedAt;
    }

    return sets
        .map((set) => set.completedAt)
        .reduce((first, second) => first.isAfter(second) ? first : second);
  }

  Duration get duration => finishedAt.difference(startedAt);

  Map<String, List<WorkoutSet>> get setsByExercise {
    final groupedSets = <String, List<WorkoutSet>>{};

    for (final set in sets) {
      groupedSets.putIfAbsent(set.exerciseName, () => []);
      groupedSets[set.exerciseName]!.add(set);
    }

    return groupedSets;
  }
}