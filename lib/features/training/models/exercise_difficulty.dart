enum ExerciseDifficulty {
  beginner,
  intermediate,
  advanced,
}

extension ExerciseDifficultyLabel on ExerciseDifficulty {
  String get label {
    switch (this) {
      case ExerciseDifficulty.beginner:
        return 'Beginner';
      case ExerciseDifficulty.intermediate:
        return 'Intermediate';
      case ExerciseDifficulty.advanced:
        return 'Advanced';
    }
  }
}