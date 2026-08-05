import 'package:secret_mission/features/training/models/exercise_difficulty.dart';
import 'package:secret_mission/features/training/models/exercise_guide.dart';
import 'package:secret_mission/features/training/models/exercise_mistake.dart';
import 'package:secret_mission/features/training/models/exercise_muscle.dart';

const latPulldownGuide = ExerciseGuide(
  exerciseName: 'Lat Pulldown',
  whyThisExercise:
      'Develops the lat muscles and improves vertical pulling strength, '
      'helping create a wider and stronger back.',
  muscles: [
    ExerciseMuscle(
      name: 'Latissimus Dorsi',
      role: MuscleRole.primary,
    ),
    ExerciseMuscle(
      name: 'Biceps',
      role: MuscleRole.secondary,
    ),
    ExerciseMuscle(
      name: 'Rear Deltoids',
      role: MuscleRole.secondary,
    ),
    ExerciseMuscle(
      name: 'Upper Back',
      role: MuscleRole.stabilizer,
    ),
  ],
  commanderInsight:
      'Drive your elbows toward your hips instead of thinking about pulling '
      'the bar with your hands.',
  setupSteps: [
    'Adjust the thigh pad so your legs remain secured.',
    'Grip the bar slightly wider than shoulder width.',
    'Sit tall with your chest raised.',
    'Lean backward only slightly.',
  ],
  executionSteps: [
    'Pull the bar toward your upper chest.',
    'Drive your elbows downward and backward.',
    'Pause briefly while squeezing your back.',
  ],
  returnSteps: [
    'Allow the bar to rise slowly.',
    'Fully lengthen the lats without losing posture.',
    'Reset your shoulders before the next repetition.',
  ],
  commonMistakes: [
    ExerciseMistake(
      title: 'Pulling behind the neck',
      description:
          'This position can place unnecessary stress on the shoulders and neck.',
    ),
    ExerciseMistake(
      title: 'Excessive backward lean',
      description:
          'Turning the movement into a row reduces the intended vertical pull.',
    ),
    ExerciseMistake(
      title: 'Using momentum',
      description:
          'Swinging the torso reduces muscular control and lat engagement.',
    ),
  ],
  exerciseImagePath:
      'assets/exercises/movements/lat_pulldown.png',
  frontMuscleImagePath:
      'assets/exercises/muscles/lat_pulldown_front.png',
  backMuscleImagePath:
      'assets/exercises/muscles/lat_pulldown_back.png',
  difficulty: ExerciseDifficulty.beginner,
  category: 'Pull',
  equipment: 'Cable Machine',
);

const chestSupportedRowGuide = ExerciseGuide(
  exerciseName: 'Chest Supported Row',
  whyThisExercise:
      'Builds the middle and upper back while the chest support limits body '
      'momentum and reduces lower-back fatigue.',
  muscles: [
    ExerciseMuscle(
      name: 'Middle Back',
      role: MuscleRole.primary,
    ),
    ExerciseMuscle(
      name: 'Rhomboids',
      role: MuscleRole.primary,
    ),
    ExerciseMuscle(
      name: 'Rear Deltoids',
      role: MuscleRole.secondary,
    ),
    ExerciseMuscle(
      name: 'Biceps',
      role: MuscleRole.secondary,
    ),
  ],
  commanderInsight:
      'Keep your chest connected to the pad and pull your elbows behind your body.',
  setupSteps: [
    'Adjust the bench or machine so your chest is firmly supported.',
    'Plant your feet securely.',
    'Hold the handles with neutral wrists.',
    'Let your arms extend without rounding your upper back.',
  ],
  executionSteps: [
    'Pull the handles toward your lower chest or upper abdomen.',
    'Drive your elbows backward.',
    'Squeeze your shoulder blades together.',
  ],
  returnSteps: [
    'Extend your arms slowly.',
    'Allow the shoulder blades to separate naturally.',
    'Keep your chest against the support.',
  ],
  commonMistakes: [
    ExerciseMistake(
      title: 'Chest leaving the pad',
      description:
          'Lifting away from the support introduces momentum and reduces control.',
    ),
    ExerciseMistake(
      title: 'Shrugging',
      description:
          'Raising the shoulders can shift tension toward the upper traps.',
    ),
    ExerciseMistake(
      title: 'Short range of motion',
      description:
          'Failing to extend and retract fully limits effective back training.',
    ),
  ],
  exerciseImagePath:
      'assets/exercises/movements/chest_supported_row.png',
  frontMuscleImagePath:
      'assets/exercises/muscles/chest_supported_row_front.png',
  backMuscleImagePath:
      'assets/exercises/muscles/chest_supported_row_back.png',
  difficulty: ExerciseDifficulty.beginner,
  category: 'Pull',
  equipment: 'Machine / Dumbbells',
);

const seatedCableRowGuide = ExerciseGuide(
  exerciseName: 'Seated Cable Row',
  whyThisExercise:
      'Strengthens the lats and middle back while improving horizontal pulling '
      'strength and shoulder-blade control.',
  muscles: [
    ExerciseMuscle(
      name: 'Latissimus Dorsi',
      role: MuscleRole.primary,
    ),
    ExerciseMuscle(
      name: 'Rhomboids',
      role: MuscleRole.primary,
    ),
    ExerciseMuscle(
      name: 'Rear Deltoids',
      role: MuscleRole.secondary,
    ),
    ExerciseMuscle(
      name: 'Biceps',
      role: MuscleRole.secondary,
    ),
    ExerciseMuscle(
      name: 'Core',
      role: MuscleRole.stabilizer,
    ),
  ],
  commanderInsight:
      'Stay tall and pull the handle toward your body—do not rock your entire torso.',
  setupSteps: [
    'Sit on the machine with your feet secured.',
    'Hold the attachment with neutral wrists.',
    'Keep your chest raised and spine neutral.',
    'Begin with your arms extended.',
  ],
  executionSteps: [
    'Pull the handle toward your lower ribs.',
    'Keep your elbows close to your body.',
    'Squeeze your shoulder blades together.',
  ],
  returnSteps: [
    'Extend the arms slowly.',
    'Allow a controlled stretch through the back.',
    'Avoid rounding or collapsing forward.',
  ],
  commonMistakes: [
    ExerciseMistake(
      title: 'Rocking backward',
      description:
          'Using excessive torso movement turns the exercise into a momentum-driven pull.',
    ),
    ExerciseMistake(
      title: 'Rounded back',
      description:
          'Collapsing the spine reduces stability and may strain the lower back.',
    ),
    ExerciseMistake(
      title: 'Pulling too high',
      description:
          'Pulling toward the chest may cause the shoulders to shrug excessively.',
    ),
  ],
  exerciseImagePath:
      'assets/exercises/movements/seated_cable_row.png',
  frontMuscleImagePath:
      'assets/exercises/muscles/seated_cable_row_front.png',
  backMuscleImagePath:
      'assets/exercises/muscles/seated_cable_row_back.png',
  difficulty: ExerciseDifficulty.beginner,
  category: 'Pull',
  equipment: 'Cable Machine',
);

const facePullGuide = ExerciseGuide(
  exerciseName: 'Face Pull',
  whyThisExercise:
      'Strengthens the rear shoulders and upper back while supporting healthy '
      'shoulder positioning and posture.',
  muscles: [
    ExerciseMuscle(
      name: 'Rear Deltoids',
      role: MuscleRole.primary,
    ),
    ExerciseMuscle(
      name: 'Upper Back',
      role: MuscleRole.primary,
    ),
    ExerciseMuscle(
      name: 'Rotator Cuff',
      role: MuscleRole.secondary,
    ),
    ExerciseMuscle(
      name: 'Biceps',
      role: MuscleRole.stabilizer,
    ),
  ],
  commanderInsight:
      'Pull the rope apart as it approaches your face, finishing with your hands beside your ears.',
  setupSteps: [
    'Set a rope attachment around face height.',
    'Hold the rope with your palms facing inward.',
    'Step backward until the cable is under tension.',
    'Stand tall with your ribs controlled.',
  ],
  executionSteps: [
    'Pull the rope toward your face.',
    'Separate the rope ends as you pull.',
    'Drive your elbows outward and backward.',
  ],
  returnSteps: [
    'Extend your arms slowly.',
    'Maintain shoulder control.',
    'Do not allow the cable to pull you forward.',
  ],
  commonMistakes: [
    ExerciseMistake(
      title: 'Using too much weight',
      description:
          'Heavy loads encourage momentum and reduce proper shoulder rotation.',
    ),
    ExerciseMistake(
      title: 'Elbows dropping',
      description:
          'Low elbows shift tension away from the rear deltoids and upper back.',
    ),
    ExerciseMistake(
      title: 'Leaning excessively',
      description:
          'Using the whole body prevents controlled upper-back movement.',
    ),
  ],
  exerciseImagePath:
      'assets/exercises/movements/face_pull.png',
  frontMuscleImagePath:
      'assets/exercises/muscles/face_pull_front.png',
  backMuscleImagePath:
      'assets/exercises/muscles/face_pull_back.png',
  difficulty: ExerciseDifficulty.beginner,
  category: 'Pull',
  equipment: 'Cable Machine',
);

const hammerCurlGuide = ExerciseGuide(
  exerciseName: 'Hammer Curl',
  whyThisExercise:
      'Builds the arms and forearms using a neutral grip that strongly trains '
      'the brachialis and brachioradialis.',
  muscles: [
    ExerciseMuscle(
      name: 'Brachialis',
      role: MuscleRole.primary,
    ),
    ExerciseMuscle(
      name: 'Biceps',
      role: MuscleRole.secondary,
    ),
    ExerciseMuscle(
      name: 'Forearms',
      role: MuscleRole.secondary,
    ),
  ],
  commanderInsight:
      'Keep your thumbs pointing upward and move only at the elbow.',
  setupSteps: [
    'Stand tall with a dumbbell in each hand.',
    'Keep your palms facing your body.',
    'Brace your core.',
    'Place your elbows close to your sides.',
  ],
  executionSteps: [
    'Curl the dumbbells upward.',
    'Keep the neutral grip throughout.',
    'Squeeze briefly near the top.',
  ],
  returnSteps: [
    'Lower the dumbbells slowly.',
    'Fully extend the elbows without losing posture.',
    'Reset before the next repetition.',
  ],
  commonMistakes: [
    ExerciseMistake(
      title: 'Swinging the torso',
      description:
          'Body momentum reduces the amount of work performed by the arms.',
    ),
    ExerciseMistake(
      title: 'Elbows drifting forward',
      description:
          'Moving the upper arms reduces isolation and shortens the effective range.',
    ),
    ExerciseMistake(
      title: 'Dropping the weight',
      description:
          'An uncontrolled lowering phase removes valuable muscular tension.',
    ),
  ],
  exerciseImagePath:
      'assets/exercises/movements/hammer_curl.png',
  frontMuscleImagePath:
      'assets/exercises/muscles/hammer_curl_front.png',
  backMuscleImagePath:
      'assets/exercises/muscles/hammer_curl_back.png',
  difficulty: ExerciseDifficulty.beginner,
  category: 'Pull',
  equipment: 'Dumbbells',
);

class PullGuides {
  static const exercises = [
    latPulldownGuide,
    chestSupportedRowGuide,
    seatedCableRowGuide,
    facePullGuide,
    hammerCurlGuide,
  ];
}