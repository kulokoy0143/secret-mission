import 'package:secret_mission/features/training/models/exercise_difficulty.dart';
import 'package:secret_mission/features/training/models/exercise_guide.dart';
import 'package:secret_mission/features/training/models/exercise_mistake.dart';
import 'package:secret_mission/features/training/models/exercise_muscle.dart';

const benchPressGuide = ExerciseGuide(
  exerciseName: 'Bench Press',
  whyThisExercise:
      'Builds pressing strength and muscle across the chest, shoulders, and triceps.',
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
    ExerciseMuscle(
      name: 'Upper Back',
      role: MuscleRole.stabilizer,
    ),
  ],
  commanderInsight:
      'Keep your shoulder blades pulled back and maintain a stable base before pressing.',
  setupSteps: [
    'Lie on the bench with your eyes roughly under the bar.',
    'Plant your feet firmly on the floor.',
    'Grip the bar slightly wider than shoulder width.',
    'Retract your shoulder blades and keep your upper back tight.',
  ],
  executionSteps: [
    'Unrack the bar with control.',
    'Lower the bar toward the mid-to-lower chest.',
    'Keep your elbows at a comfortable angle from your torso.',
    'Press the bar upward while maintaining your upper-back position.',
  ],
  returnSteps: [
    'Finish with the arms extended without aggressively locking the elbows.',
    'Reset your brace before the next repetition.',
    'Rack the bar carefully after completing the set.',
  ],
  commonMistakes: [
    ExerciseMistake(
      title: 'Elbows flaring excessively',
      description:
          'Allowing the elbows to move too far outward may increase shoulder stress.',
    ),
    ExerciseMistake(
      title: 'Losing upper-back tension',
      description:
          'Relaxing the shoulder blades reduces stability during the press.',
    ),
    ExerciseMistake(
      title: 'Bouncing the bar',
      description:
          'Using the chest to rebound the bar removes control from the movement.',
    ),
  ],
  exerciseImagePath:
      'assets/exercises/movements/bench_press.png',
  frontMuscleImagePath:
      'assets/exercises/muscles/bench_press_front.png',
  backMuscleImagePath:
      'assets/exercises/muscles/bench_press_back.png',
  difficulty: ExerciseDifficulty.intermediate,
  category: 'Upper',
  equipment: 'Barbell / Bench',
);

const pullUpGuide = ExerciseGuide(
  exerciseName: 'Pull-Up',
  whyThisExercise:
      'Develops upper-body pulling strength while training the back and arms using your bodyweight.',
  muscles: [
    ExerciseMuscle(
      name: 'Lats',
      role: MuscleRole.primary,
    ),
    ExerciseMuscle(
      name: 'Upper Back',
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
    ExerciseMuscle(
      name: 'Core',
      role: MuscleRole.stabilizer,
    ),
  ],
  commanderInsight:
      'Think about pulling your elbows down toward your sides instead of simply pulling with your hands.',
  setupSteps: [
    'Grip the pull-up bar slightly wider than shoulder width.',
    'Hang with your arms extended.',
    'Keep your shoulders active instead of completely relaxed.',
    'Brace your core and keep your legs controlled.',
  ],
  executionSteps: [
    'Pull your body upward by driving your elbows downward.',
    'Bring your chest toward the bar.',
    'Keep your torso controlled without excessive swinging.',
  ],
  returnSteps: [
    'Lower yourself slowly.',
    'Return to a controlled full-arm position.',
    'Reset your shoulders before the next repetition.',
  ],
  commonMistakes: [
    ExerciseMistake(
      title: 'Using momentum',
      description:
          'Swinging the body reduces control and shifts work away from the back.',
    ),
    ExerciseMistake(
      title: 'Pulling only with the arms',
      description:
          'Focusing only on elbow flexion limits effective lat and back engagement.',
    ),
    ExerciseMistake(
      title: 'Dropping quickly',
      description:
          'An uncontrolled descent reduces muscular tension and shoulder control.',
    ),
  ],
  exerciseImagePath:
      'assets/exercises/movements/pull_up.png',
  frontMuscleImagePath:
      'assets/exercises/muscles/pull_up_front.png',
  backMuscleImagePath:
      'assets/exercises/muscles/pull_up_back.png',
  difficulty: ExerciseDifficulty.intermediate,
  category: 'Upper',
  equipment: 'Pull-Up Bar',
);

const shoulderPressGuide = ExerciseGuide(
  exerciseName: 'Shoulder Press',
  whyThisExercise:
      'Builds overhead pressing strength while developing the shoulders and triceps.',
  muscles: [
    ExerciseMuscle(
      name: 'Front Deltoids',
      role: MuscleRole.primary,
    ),
    ExerciseMuscle(
      name: 'Side Deltoids',
      role: MuscleRole.primary,
    ),
    ExerciseMuscle(
      name: 'Triceps',
      role: MuscleRole.secondary,
    ),
    ExerciseMuscle(
      name: 'Core',
      role: MuscleRole.stabilizer,
    ),
  ],
  commanderInsight:
      'Keep your ribs controlled and press the weight overhead without leaning excessively backward.',
  setupSteps: [
    'Sit or stand with the weights around shoulder height.',
    'Keep your wrists stacked over your elbows.',
    'Brace your abdomen.',
    'Keep your chest tall without overextending your lower back.',
  ],
  executionSteps: [
    'Press the weights upward.',
    'Move your head slightly back as the weight passes your face.',
    'Finish with the arms overhead in a controlled position.',
  ],
  returnSteps: [
    'Lower the weights slowly toward shoulder height.',
    'Keep the elbows under control.',
    'Reset your brace before the next repetition.',
  ],
  commonMistakes: [
    ExerciseMistake(
      title: 'Excessive back arch',
      description:
          'Leaning backward too much shifts stress toward the lower back.',
    ),
    ExerciseMistake(
      title: 'Flared elbows',
      description:
          'Poor elbow positioning may reduce stability and shoulder comfort.',
    ),
    ExerciseMistake(
      title: 'Using momentum',
      description:
          'Driving aggressively with the body reduces controlled shoulder work.',
    ),
  ],
  exerciseImagePath:
      'assets/exercises/movements/shoulder_press.png',
  frontMuscleImagePath:
      'assets/exercises/muscles/shoulder_press_front.png',
  backMuscleImagePath:
      'assets/exercises/muscles/shoulder_press_back.png',
  difficulty: ExerciseDifficulty.beginner,
  category: 'Upper',
  equipment: 'Dumbbells / Machine',
);

const cableRowGuide = ExerciseGuide(
  exerciseName: 'Cable Row',
  whyThisExercise:
      'Strengthens the middle back and lats while developing controlled horizontal pulling strength.',
  muscles: [
    ExerciseMuscle(
      name: 'Middle Back',
      role: MuscleRole.primary,
    ),
    ExerciseMuscle(
      name: 'Lats',
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
      'Keep your chest tall and pull your elbows behind your body without turning the exercise into a torso swing.',
  setupSteps: [
    'Sit securely at the cable row station.',
    'Place your feet firmly against the platform.',
    'Grip the attachment with neutral wrists.',
    'Sit tall and brace your core.',
  ],
  executionSteps: [
    'Pull the handle toward your torso.',
    'Drive your elbows backward.',
    'Squeeze your shoulder blades together.',
    'Keep your torso mostly still.',
  ],
  returnSteps: [
    'Extend your arms slowly.',
    'Allow the shoulder blades to move forward naturally.',
    'Maintain your posture before beginning the next repetition.',
  ],
  commonMistakes: [
    ExerciseMistake(
      title: 'Excessive leaning',
      description:
          'Using large torso movement reduces controlled back engagement.',
    ),
    ExerciseMistake(
      title: 'Shrugging',
      description:
          'Raising the shoulders shifts tension away from the intended back muscles.',
    ),
    ExerciseMistake(
      title: 'Pulling with the hands',
      description:
          'Thinking only about the hands may reduce proper elbow and back movement.',
    ),
  ],
  exerciseImagePath:
      'assets/exercises/movements/cable_row.png',
  frontMuscleImagePath:
      'assets/exercises/muscles/cable_row_front.png',
  backMuscleImagePath:
      'assets/exercises/muscles/cable_row_back.png',
  difficulty: ExerciseDifficulty.beginner,
  category: 'Upper',
  equipment: 'Cable Machine',
);

const bicepCurlGuide = ExerciseGuide(
  exerciseName: 'Bicep Curl',
  whyThisExercise:
      'Directly trains the biceps and improves elbow-flexion strength.',
  muscles: [
    ExerciseMuscle(
      name: 'Biceps',
      role: MuscleRole.primary,
    ),
    ExerciseMuscle(
      name: 'Brachialis',
      role: MuscleRole.secondary,
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
      'Keep your upper arms still and let the elbow joint perform the movement.',
  setupSteps: [
    'Stand tall while holding the weights.',
    'Keep your elbows close to your torso.',
    'Brace your core.',
    'Begin with your arms extended.',
  ],
  executionSteps: [
    'Curl the weights upward by bending your elbows.',
    'Keep your upper arms mostly stationary.',
    'Squeeze the biceps near the top.',
  ],
  returnSteps: [
    'Lower the weights slowly.',
    'Fully extend your elbows without losing posture.',
    'Reset before beginning the next repetition.',
  ],
  commonMistakes: [
    ExerciseMistake(
      title: 'Swinging the body',
      description:
          'Using torso momentum reduces the amount of work performed by the biceps.',
    ),
    ExerciseMistake(
      title: 'Elbows moving forward',
      description:
          'Allowing the upper arms to drift forward reduces isolation.',
    ),
    ExerciseMistake(
      title: 'Dropping the weight',
      description:
          'An uncontrolled lowering phase removes valuable muscular tension.',
    ),
  ],
  exerciseImagePath:
      'assets/exercises/movements/bicep_curl.png',
  frontMuscleImagePath:
      'assets/exercises/muscles/bicep_curl_front.png',
  backMuscleImagePath:
      'assets/exercises/muscles/bicep_curl_back.png',
  difficulty: ExerciseDifficulty.beginner,
  category: 'Upper',
  equipment: 'Dumbbells / Barbell',
);

class UpperGuides {
  static const exercises = [
    benchPressGuide,
    pullUpGuide,
    shoulderPressGuide,
    cableRowGuide,
    bicepCurlGuide,
  ];
}