import 'package:secret_mission/features/training/data/guides/legs_guides.dart';
import 'package:secret_mission/features/training/data/guides/pull_guides.dart';
import 'package:secret_mission/features/training/data/guides/push_guides.dart';
import 'package:secret_mission/features/training/models/exercise_guide.dart';

class ExerciseGuides {
  static final Map<String, ExerciseGuide> all = {
    for (final exercise in PushGuides.exercises)
      exercise.exerciseName: exercise,
    for (final exercise in PullGuides.exercises)
      exercise.exerciseName: exercise,
    for (final exercise in LegsGuides.exercises)
      exercise.exerciseName: exercise,
  };

  static ExerciseGuide? findByName(String exerciseName) {
    return all[exerciseName];
  }
}