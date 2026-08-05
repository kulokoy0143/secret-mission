enum MuscleRole {
  primary,
  secondary,
  stabilizer,
}

class ExerciseMuscle {
  const ExerciseMuscle({
    required this.name,
    required this.role,
  });

  final String name;
  final MuscleRole role;
}