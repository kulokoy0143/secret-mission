import 'package:hive/hive.dart';
import 'package:secret_mission/features/training/models/workout_set.dart';

class WorkoutStorageService {
  static const String boxName = 'workout_sets';

  static Box<WorkoutSet> get _workoutBox {
    if (!Hive.isBoxOpen(boxName)) {
      throw StateError(
        'Workout storage is not ready. Make sure the Hive box is opened in main.dart.',
      );
    }

    return Hive.box<WorkoutSet>(boxName);
  }

  /// Returns every saved workout set, oldest first.
  static List<WorkoutSet> getAllSets() {
    final sets = _workoutBox.values.toList();

    sets.sort(
      (firstSet, secondSet) =>
          firstSet.completedAt.compareTo(secondSet.completedAt),
    );

    return sets;
  }

  /// Permanently saves a workout set.
  static Future<void> saveSet(WorkoutSet workoutSet) async {
    await _workoutBox.add(workoutSet);
  }

  /// Permanently deletes one workout set.
  static Future<void> deleteSet(WorkoutSet workoutSet) async {
    await workoutSet.delete();
  }

  /// Removes every saved workout set.
  ///
  /// We will use this later for a "Clear Workout History" option.
  static Future<void> clearAllSets() async {
    await _workoutBox.clear();
  }

  /// Returns the current consecutive workout-day streak.
  ///
  /// A streak stays active if the most recent workout was today or yesterday.
  static int getCurrentWorkoutStreak() {
    final sets = getAllSets();

    if (sets.isEmpty) {
      return 0;
    }

    final workoutDates =
        sets
            .map(
              (set) => DateTime(
                set.completedAt.year,
                set.completedAt.month,
                set.completedAt.day,
              ),
            )
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);

    final mostRecentWorkout = workoutDates.first;

    final daysSinceLastWorkout = normalizedToday
        .difference(mostRecentWorkout)
        .inDays;

    if (daysSinceLastWorkout > 1) {
      return 0;
    }

    var streak = 1;
    var expectedDate = mostRecentWorkout.subtract(const Duration(days: 1));

    for (final workoutDate in workoutDates.skip(1)) {
      if (workoutDate == expectedDate) {
        streak++;
        expectedDate = expectedDate.subtract(const Duration(days: 1));
      } else if (workoutDate.isBefore(expectedDate)) {
        break;
      }
    }

    return streak;
  }

  /// Returns the total number of sets saved in Hive.
  static int get savedSetCount => _workoutBox.length;
}
