import 'package:secret_mission/features/training/models/exercise_difficulty.dart';
import 'package:secret_mission/features/training/models/exercise_guide.dart';
import 'package:secret_mission/features/training/models/exercise_mistake.dart';
import 'package:secret_mission/features/training/models/exercise_muscle.dart';

const plankGuide = ExerciseGuide(
  exerciseName: 'Plank',
  whyThisExercise:
      'Develops core endurance and full-body stability by teaching the torso to resist unwanted movement.',
  muscles: [
    ExerciseMuscle(
      name: 'Core',
      role: MuscleRole.primary,
    ),
    ExerciseMuscle(
      name: 'Obliques',
      role: MuscleRole.secondary,
    ),
    ExerciseMuscle(
      name: 'Glutes',
      role: MuscleRole.stabilizer,
    ),
    ExerciseMuscle(
      name: 'Shoulders',
      role: MuscleRole.stabilizer,
    ),
  ],
  commanderInsight:
      'Think about keeping your body in one straight line while actively bracing your abs and squeezing your glutes.',
  setupSteps: [
    'Place your forearms on the floor with your elbows under your shoulders.',
    'Extend your legs behind you.',
    'Support your body on your forearms and toes.',
    'Brace your abdomen and squeeze your glutes.',
  ],
  executionSteps: [
    'Keep your head, shoulders, hips, and heels aligned.',
    'Maintain steady abdominal tension.',
    'Keep your shoulders stable above your elbows.',
    'Breathe normally while holding the position.',
  ],
  returnSteps: [
    'Maintain your position for the planned duration.',
    'Lower your knees to the floor when the hold is complete.',
    'Relax gradually instead of collapsing out of the position.',
  ],
  commonMistakes: [
    ExerciseMistake(
      title: 'Hips sagging',
      description:
          'Allowing the hips to drop reduces core control and may increase stress on the lower back.',
    ),
    ExerciseMistake(
      title: 'Hips too high',
      description:
          'Raising the hips excessively reduces the demand placed on the core.',
    ),
    ExerciseMistake(
      title: 'Holding the breath',
      description:
          'Breath holding makes it harder to maintain a controlled and sustainable position.',
    ),
  ],
  exerciseImagePath:
      'assets/exercises/movements/plank.png',
  frontMuscleImagePath:
      'assets/exercises/muscles/plank_front.png',
  backMuscleImagePath:
      'assets/exercises/muscles/plank_back.png',
  difficulty: ExerciseDifficulty.beginner,
  category: 'Full Body',
  equipment: 'Bodyweight',
);

class FullBodyGuides {
  static const exercises = [
    plankGuide,
  ];
}