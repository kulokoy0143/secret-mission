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

  /// Returns the total number of sets saved in Hive.
  static int get savedSetCount => _workoutBox.length;
}