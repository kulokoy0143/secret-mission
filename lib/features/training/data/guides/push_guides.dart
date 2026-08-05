import 'package:secret_mission/features/training/models/exercise_difficulty.dart';
import 'package:secret_mission/features/training/models/exercise_guide.dart';
import 'package:secret_mission/features/training/models/exercise_mistake.dart';
import 'package:secret_mission/features/training/models/exercise_muscle.dart';

const inclineBenchGuide = ExerciseGuide(
  exerciseName: 'Incline Bench Press',

  whyThisExercise:
      'Builds the upper chest while strengthening the shoulders and triceps.',

  muscles: [
    ExerciseMuscle(
      name: 'Upper Chest',
      role: MuscleRole.primary,
    ),
    ExerciseMuscle(
      name: 'Front Deltoids',
      role: MuscleRole.secondary,
    ),
    ExerciseMuscle(
      name: 'Triceps',
      role: MuscleRole.secondary,
    ),
  ],

  commanderInsight:
      'Keep your shoulder blades locked down throughout every repetition. '
      'Press with your chest—not your shoulders.',

  setupSteps: [
    'Set the bench between 30° and 45°.',
    'Plant both feet firmly.',
    'Retract your shoulder blades.',
    'Grip slightly wider than shoulder width.',
  ],

  executionSteps: [
    'Lower the weight toward the upper chest.',
    'Pause briefly.',
    'Press upward until your arms are almost straight.',
  ],

  returnSteps: [
    'Lower slowly.',
    'Keep your upper back tight.',
    'Repeat with full control.',
  ],

  commonMistakes: [
    ExerciseMistake(
      title: 'Bench too steep',
      description:
          'Turns the movement into more of a shoulder press.',
    ),
    ExerciseMistake(
      title: 'Elbows flaring',
      description:
          'Places unnecessary stress on the shoulders.',
    ),
    ExerciseMistake(
      title: 'Bouncing the bar',
      description:
          'Removes muscle tension and reduces control.',
    ),
    ExerciseMistake(
      title: 'Lifting hips',
      description:
          'Reduces stability and proper chest engagement.',
    ),
  ],

  exerciseImagePath:
      'assets/exercises/movements/incline_bench_press.png',

  frontMuscleImagePath:
      'assets/exercises/muscles/incline_bench_press_front.png',

  backMuscleImagePath:
      'assets/exercises/muscles/incline_bench_press_back.png',

  difficulty: ExerciseDifficulty.intermediate,

  category: 'Push',

  equipment: 'Barbell / Dumbbell',
);

const machineChestPressGuide = ExerciseGuide(
  exerciseName: 'Machine Chest Press',
  whyThisExercise:
      'Provides a stable pressing movement that lets you focus on the chest '
      'without needing to balance a free weight.',

  muscles: [
    ExerciseMuscle(
      name: 'Chest',
      role: MuscleRole.primary,
    ),
    ExerciseMuscle(
      name: 'Front Deltoids',
      role: MuscleRole.secondary,
    ),
    ExerciseMuscle(
      name: 'Triceps',
      role: MuscleRole.secondary,
    ),
  ],

  commanderInsight:
      'Keep your shoulder blades against the pad and imagine bringing your '
      'upper arms toward each other as you press.',

  setupSteps: [
    'Adjust the seat so the handles align around the middle of your chest.',
    'Place your back and head firmly against the pad.',
    'Plant both feet flat on the floor.',
    'Grip the handles with your wrists straight.',
  ],

  executionSteps: [
    'Press the handles forward under control.',
    'Keep your shoulders down instead of shrugging.',
    'Stop when your arms are nearly straight.',
  ],

  returnSteps: [
    'Allow the handles to return slowly.',
    'Stop when you feel a comfortable stretch across the chest.',
    'Maintain contact with the back pad before beginning the next repetition.',
  ],

  commonMistakes: [
    ExerciseMistake(
      title: 'Seat positioned incorrectly',
      description:
          'Handles that are too high or too low can shift tension away from '
          'the chest and place the shoulders in an uncomfortable position.',
    ),
    ExerciseMistake(
      title: 'Shoulders rolling forward',
      description:
          'Letting the shoulders leave the pad reduces chest stability and '
          'can increase shoulder stress.',
    ),
    ExerciseMistake(
      title: 'Using momentum',
      description:
          'Driving the body into the pad removes control and reduces muscular '
          'tension.',
    ),
  ],

  exerciseImagePath:
      'assets/exercises/movements/machine_chest_press.png',
  frontMuscleImagePath:
      'assets/exercises/muscles/machine_chest_press_front.png',
  backMuscleImagePath:
      'assets/exercises/muscles/machine_chest_press_back.png',

  difficulty: ExerciseDifficulty.beginner,
  category: 'Push',
  equipment: 'Chest Press Machine',
);

const seatedShoulderPressGuide = ExerciseGuide(
  exerciseName: 'Seated Shoulder Press',
  whyThisExercise:
      'Builds overhead pressing strength and develops the shoulders while '
      'also training the triceps.',

  muscles: [
    ExerciseMuscle(
      name: 'Front Deltoids',
      role: MuscleRole.primary,
    ),
    ExerciseMuscle(
      name: 'Side Deltoids',
      role: MuscleRole.secondary,
    ),
    ExerciseMuscle(
      name: 'Triceps',
      role: MuscleRole.secondary,
    ),
    ExerciseMuscle(
      name: 'Upper Chest',
      role: MuscleRole.stabilizer,
    ),
  ],

  commanderInsight:
      'Brace your abdomen and press the weight upward without turning the '
      'movement into a standing backbend.',

  setupSteps: [
    'Set the bench upright with firm back support.',
    'Plant your feet flat on the floor.',
    'Hold the weights beside your shoulders.',
    'Brace your core and keep your ribs controlled.',
  ],

  executionSteps: [
    'Press the weights upward in a smooth path.',
    'Keep your forearms roughly vertical.',
    'Bring the weights overhead without aggressively locking the elbows.',
  ],

  returnSteps: [
    'Lower the weights slowly toward shoulder level.',
    'Keep your back against the support.',
    'Reset your brace before the next repetition.',
  ],

  commonMistakes: [
    ExerciseMistake(
      title: 'Excessive lower-back arch',
      description:
          'Overarching shifts the load away from the shoulders and can place '
          'unnecessary stress on the lower back.',
    ),
    ExerciseMistake(
      title: 'Shrugging upward',
      description:
          'Raising the shoulders excessively can reduce control and cause '
          'neck tension.',
    ),
    ExerciseMistake(
      title: 'Lowering too deeply',
      description:
          'Forcing the elbows far below a comfortable range may irritate the '
          'shoulders.',
    ),
  ],

  exerciseImagePath:
      'assets/exercises/movements/seated_shoulder_press.png',
  frontMuscleImagePath:
      'assets/exercises/muscles/seated_shoulder_press_front.png',
  backMuscleImagePath:
      'assets/exercises/muscles/seated_shoulder_press_back.png',

  difficulty: ExerciseDifficulty.intermediate,
  category: 'Push',
  equipment: 'Dumbbells / Machine',
);

const lateralRaiseGuide = ExerciseGuide(
  exerciseName: 'Lateral Raise',
  whyThisExercise:
      'Targets the side deltoids to improve shoulder width and balanced upper-body development.',

  muscles: [
    ExerciseMuscle(
      name: 'Side Deltoids',
      role: MuscleRole.primary,
    ),
    ExerciseMuscle(
      name: 'Upper Trapezius',
      role: MuscleRole.secondary,
    ),
    ExerciseMuscle(
      name: 'Supraspinatus',
      role: MuscleRole.stabilizer,
    ),
  ],

  commanderInsight:
      'Lead with your elbows and think about moving your arms outward rather '
      'than throwing the dumbbells upward.',

  setupSteps: [
    'Stand tall with a dumbbell in each hand.',
    'Keep a slight bend in your elbows.',
    'Brace your core and keep your shoulders relaxed.',
    'Hold the weights beside your thighs.',
  ],

  executionSteps: [
    'Raise your arms outward in a controlled arc.',
    'Lead the movement with your elbows.',
    'Stop around shoulder height.',
  ],

  returnSteps: [
    'Lower the weights slowly to your sides.',
    'Avoid letting the dumbbells drop.',
    'Reset your posture before repeating.',
  ],

  commonMistakes: [
    ExerciseMistake(
      title: 'Swinging the torso',
      description:
          'Using body momentum reduces tension on the side deltoids.',
    ),
    ExerciseMistake(
      title: 'Shrugging the shoulders',
      description:
          'Shrugging allows the upper traps to dominate the movement.',
    ),
    ExerciseMistake(
      title: 'Raising too high',
      description:
          'Lifting far above shoulder height may add unnecessary shoulder '
          'stress without improving the target muscle stimulus.',
    ),
  ],

  exerciseImagePath:
      'assets/exercises/movements/lateral_raise.png',
  frontMuscleImagePath:
      'assets/exercises/muscles/lateral_raise_front.png',
  backMuscleImagePath:
      'assets/exercises/muscles/lateral_raise_back.png',

  difficulty: ExerciseDifficulty.beginner,
  category: 'Push',
  equipment: 'Dumbbells / Cable',
);

const tricepsPushdownGuide = ExerciseGuide(
  exerciseName: 'Triceps Pushdown',
  whyThisExercise:
      'Isolates the triceps and strengthens elbow extension for pressing movements.',

  muscles: [
    ExerciseMuscle(
      name: 'Triceps',
      role: MuscleRole.primary,
    ),
    ExerciseMuscle(
      name: 'Forearms',
      role: MuscleRole.secondary,
    ),
    ExerciseMuscle(
      name: 'Core',
      role: MuscleRole.stabilizer,
    ),
  ],

  commanderInsight:
      'Imagine your elbows are pinned to your ribs. Only your forearms should '
      'move during the repetition.',

  setupSteps: [
    'Attach a bar or rope to a high cable.',
    'Stand tall with a slight bend in your knees.',
    'Hold the attachment with your wrists neutral.',
    'Bring your elbows close to your sides.',
  ],

  executionSteps: [
    'Push the attachment downward by extending your elbows.',
    'Keep the upper arms still.',
    'Squeeze the triceps when the arms are straight.',
  ],

  returnSteps: [
    'Allow the attachment to rise slowly.',
    'Stop before the elbows drift forward.',
    'Maintain your posture before starting the next repetition.',
  ],

  commonMistakes: [
    ExerciseMistake(
      title: 'Elbows moving forward',
      description:
          'Moving the elbows turns the exercise into a shoulder movement and '
          'reduces triceps isolation.',
    ),
    ExerciseMistake(
      title: 'Leaning excessively',
      description:
          'Using body weight to force the cable downward usually means the '
          'selected load is too heavy.',
    ),
    ExerciseMistake(
      title: 'Uncontrolled return',
      description:
          'Letting the cable pull the arms upward removes useful tension and '
          'can disrupt elbow position.',
    ),
  ],

  exerciseImagePath:
      'assets/exercises/movements/triceps_pushdown.png',
  frontMuscleImagePath:
      'assets/exercises/muscles/triceps_pushdown_front.png',
  backMuscleImagePath:
      'assets/exercises/muscles/triceps_pushdown_back.png',

  difficulty: ExerciseDifficulty.beginner,
  category: 'Push',
  equipment: 'Cable Machine',
);

class PushGuides {
  static const exercises = [
    inclineBenchGuide,
    machineChestPressGuide,
    seatedShoulderPressGuide,
    lateralRaiseGuide,
    tricepsPushdownGuide,
  ];
}