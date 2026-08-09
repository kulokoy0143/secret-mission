import 'package:secret_mission/features/training/models/exercise_difficulty.dart';
import 'package:secret_mission/features/training/models/exercise_guide.dart';
import 'package:secret_mission/features/training/models/exercise_mistake.dart';
import 'package:secret_mission/features/training/models/exercise_muscle.dart';

const squatGuide = ExerciseGuide(
  exerciseName: 'Squat',
  whyThisExercise:
      'Develops lower-body strength while training the quadriceps, glutes, and core through a coordinated movement.',
  muscles: [
    ExerciseMuscle(
      name: 'Quadriceps',
      role: MuscleRole.primary,
    ),
    ExerciseMuscle(
      name: 'Glutes',
      role: MuscleRole.primary,
    ),
    ExerciseMuscle(
      name: 'Hamstrings',
      role: MuscleRole.secondary,
    ),
    ExerciseMuscle(
      name: 'Core',
      role: MuscleRole.stabilizer,
    ),
  ],
  commanderInsight:
      'Keep your whole foot planted and let your knees track in the same direction as your toes.',
  setupSteps: [
    'Stand with your feet around shoulder width apart.',
    'Point your toes slightly outward.',
    'Keep your chest tall and spine neutral.',
    'Brace your abdomen before descending.',
  ],
  executionSteps: [
    'Bend your knees and hips together.',
    'Lower yourself under control.',
    'Keep your knees tracking over your toes.',
    'Drive through the whole foot to stand.',
  ],
  returnSteps: [
    'Finish with your hips and knees extended.',
    'Reset your breathing and brace.',
    'Maintain your stance before beginning the next repetition.',
  ],
  commonMistakes: [
    ExerciseMistake(
      title: 'Knees collapsing inward',
      description:
          'Allowing the knees to cave inward reduces lower-body stability and control.',
    ),
    ExerciseMistake(
      title: 'Heels lifting',
      description:
          'Losing heel contact shifts your balance forward and weakens your base.',
    ),
    ExerciseMistake(
      title: 'Losing torso position',
      description:
          'Excessive rounding or collapsing forward reduces stability during the squat.',
    ),
  ],
  exerciseImagePath:
      'assets/exercises/movements/squat.png',
  frontMuscleImagePath:
      'assets/exercises/muscles/squat_front.png',
  backMuscleImagePath:
      'assets/exercises/muscles/squat_back.png',
  difficulty: ExerciseDifficulty.beginner,
  category: 'Lower',
  equipment: 'Bodyweight / Barbell',
);

const walkingLungesGuide = ExerciseGuide(
  exerciseName: 'Walking Lunges',
  whyThisExercise:
      'Trains each leg individually while developing lower-body strength, balance, coordination, and hip stability.',
  muscles: [
    ExerciseMuscle(
      name: 'Quadriceps',
      role: MuscleRole.primary,
    ),
    ExerciseMuscle(
      name: 'Glutes',
      role: MuscleRole.primary,
    ),
    ExerciseMuscle(
      name: 'Hamstrings',
      role: MuscleRole.secondary,
    ),
    ExerciseMuscle(
      name: 'Calves',
      role: MuscleRole.secondary,
    ),
    ExerciseMuscle(
      name: 'Core',
      role: MuscleRole.stabilizer,
    ),
  ],
  commanderInsight:
      'Step far enough forward that you can lower vertically without your balance shifting onto your toes.',
  setupSteps: [
    'Stand tall with your feet around hip width.',
    'Brace your core.',
    'Hold dumbbells at your sides if resistance is being used.',
    'Keep your shoulders relaxed and chest tall.',
  ],
  executionSteps: [
    'Take a controlled step forward.',
    'Lower your back knee toward the floor.',
    'Keep the front knee tracking over the toes.',
    'Push through the front foot to move into the next step.',
  ],
  returnSteps: [
    'Bring the rear leg forward into the next lunge.',
    'Reestablish your balance before lowering.',
    'Continue alternating legs while maintaining control.',
  ],
  commonMistakes: [
    ExerciseMistake(
      title: 'Steps too short',
      description:
          'Very short steps can make balance difficult and place excessive emphasis on the front knee.',
    ),
    ExerciseMistake(
      title: 'Knee collapsing inward',
      description:
          'Poor knee tracking reduces stability during each step.',
    ),
    ExerciseMistake(
      title: 'Rushing the movement',
      description:
          'Moving too quickly makes it harder to maintain balance and muscular control.',
    ),
  ],
  exerciseImagePath:
      'assets/exercises/movements/walking_lunges.png',
  frontMuscleImagePath:
      'assets/exercises/muscles/walking_lunges_front.png',
  backMuscleImagePath:
      'assets/exercises/muscles/walking_lunges_back.png',
  difficulty: ExerciseDifficulty.intermediate,
  category: 'Lower',
  equipment: 'Bodyweight / Dumbbells',
);

const legExtensionGuide = ExerciseGuide(
  exerciseName: 'Leg Extension',
  whyThisExercise:
      'Directly trains the quadriceps using knee extension, making it useful for focused front-thigh development.',
  muscles: [
    ExerciseMuscle(
      name: 'Quadriceps',
      role: MuscleRole.primary,
    ),
    ExerciseMuscle(
      name: 'Core',
      role: MuscleRole.stabilizer,
    ),
  ],
  commanderInsight:
      'Control both directions of the movement and squeeze the quadriceps instead of swinging the weight.',
  setupSteps: [
    'Sit with your back firmly against the machine pad.',
    'Adjust the machine so your knees align with its pivot point.',
    'Position the lower pad above your ankles.',
    'Hold the handles and keep your hips against the seat.',
  ],
  executionSteps: [
    'Extend your knees to raise the pad.',
    'Keep your hips and back against the machine.',
    'Squeeze your quadriceps near the top.',
  ],
  returnSteps: [
    'Lower the weight slowly.',
    'Bend the knees through a comfortable range.',
    'Maintain tension before beginning the next repetition.',
  ],
  commonMistakes: [
    ExerciseMistake(
      title: 'Using momentum',
      description:
          'Swinging the weight reduces controlled quadriceps tension.',
    ),
    ExerciseMistake(
      title: 'Hips leaving the seat',
      description:
          'Allowing the hips to lift reduces stability and proper machine positioning.',
    ),
    ExerciseMistake(
      title: 'Dropping the weight',
      description:
          'An uncontrolled lowering phase removes muscular tension and control.',
    ),
  ],
  exerciseImagePath:
      'assets/exercises/movements/leg_extension.png',
  frontMuscleImagePath:
      'assets/exercises/muscles/leg_extension_front.png',
  backMuscleImagePath:
      'assets/exercises/muscles/leg_extension_back.png',
  difficulty: ExerciseDifficulty.beginner,
  category: 'Lower',
  equipment: 'Leg Extension Machine',
);

const seatedCalfRaiseGuide = ExerciseGuide(
  exerciseName: 'Seated Calf Raise',
  whyThisExercise:
      'Trains the calf muscles with the knees bent, placing strong emphasis on the soleus.',
  muscles: [
    ExerciseMuscle(
      name: 'Soleus',
      role: MuscleRole.primary,
    ),
    ExerciseMuscle(
      name: 'Gastrocnemius',
      role: MuscleRole.secondary,
    ),
    ExerciseMuscle(
      name: 'Core',
      role: MuscleRole.stabilizer,
    ),
  ],
  commanderInsight:
      'Use a full controlled range and pause at the top instead of bouncing through repetitions.',
  setupSteps: [
    'Sit securely in the calf raise machine.',
    'Place the balls of your feet on the platform.',
    'Position the thigh pad securely above your knees.',
    'Allow your heels to lower into a comfortable stretch.',
  ],
  executionSteps: [
    'Press through the balls of your feet.',
    'Raise your heels as high as comfortably possible.',
    'Pause briefly at the top.',
  ],
  returnSteps: [
    'Lower your heels slowly.',
    'Allow the calves to stretch at the bottom.',
    'Maintain control before beginning the next repetition.',
  ],
  commonMistakes: [
    ExerciseMistake(
      title: 'Bouncing',
      description:
          'Using momentum reduces controlled calf contraction and tension.',
    ),
    ExerciseMistake(
      title: 'Partial repetitions',
      description:
          'A short range limits both the stretch and contraction of the calves.',
    ),
    ExerciseMistake(
      title: 'Ankles rolling outward',
      description:
          'Poor ankle alignment can reduce stability during the movement.',
    ),
  ],
  exerciseImagePath:
      'assets/exercises/movements/seated_calf_raise.png',
  frontMuscleImagePath:
      'assets/exercises/muscles/seated_calf_raise_front.png',
  backMuscleImagePath:
      'assets/exercises/muscles/seated_calf_raise_back.png',
  difficulty: ExerciseDifficulty.beginner,
  category: 'Lower',
  equipment: 'Seated Calf Raise Machine',
);

class LowerGuides {
  static const exercises = [
    squatGuide,
    walkingLungesGuide,
    legExtensionGuide,
    seatedCalfRaiseGuide,
  ];
}