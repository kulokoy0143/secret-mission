import 'package:secret_mission/features/training/models/exercise_difficulty.dart';
import 'package:secret_mission/features/training/models/exercise_mistake.dart';
import 'package:secret_mission/features/training/models/exercise_muscle.dart';

class ExerciseGuide {
  const ExerciseGuide({
    required this.exerciseName,
    required this.whyThisExercise,
    required this.muscles,
    required this.commanderInsight,
    required this.setupSteps,
    required this.executionSteps,
    required this.returnSteps,
    required this.commonMistakes,
    required this.exerciseImagePath,
    required this.frontMuscleImagePath,
    required this.backMuscleImagePath,
    required this.difficulty,
    required this.category,
    required this.equipment,
  });

  final String exerciseName;
  final String whyThisExercise;

  final List<ExerciseMuscle> muscles;

  final String commanderInsight;

  final List<String> setupSteps;
  final List<String> executionSteps;
  final List<String> returnSteps;

  final List<ExerciseMistake> commonMistakes;

  final String exerciseImagePath;
  final String frontMuscleImagePath;
  final String backMuscleImagePath;

  final ExerciseDifficulty difficulty;
  final String category;
  final String equipment;

List<String> get primaryMuscles {
  return muscles
      .where((muscle) => muscle.role == MuscleRole.primary)
      .map((muscle) => muscle.name)
      .toList();
}

List<String> get secondaryMuscles {
  return muscles
      .where((muscle) => muscle.role == MuscleRole.secondary)
      .map((muscle) => muscle.name)
      .toList();
}

List<String> get stabilizerMuscles {
  return muscles
      .where((muscle) => muscle.role == MuscleRole.stabilizer)
      .map((muscle) => muscle.name)
      .toList();
}

List<String> get allSteps {
  return [
    ...setupSteps,
    ...executionSteps,
    ...returnSteps,
  ];
}

// Compatibility getters used by the current UI.
List<String> get steps => allSteps;

String get proTip => commanderInsight;
}