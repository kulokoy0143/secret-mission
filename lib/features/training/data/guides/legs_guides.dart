import 'package:secret_mission/features/training/models/exercise_difficulty.dart';
import 'package:secret_mission/features/training/models/exercise_guide.dart';
import 'package:secret_mission/features/training/models/exercise_mistake.dart';
import 'package:secret_mission/features/training/models/exercise_muscle.dart';

const barbellSquatGuide = ExerciseGuide(
  exerciseName: 'Barbell Squat',
  whyThisExercise:
      'Develops total lower-body strength and trains the legs, hips, and core '
      'through a large coordinated movement.',
  muscles: [
    ExerciseMuscle(name: 'Quadriceps', role: MuscleRole.primary),
    ExerciseMuscle(name: 'Glutes', role: MuscleRole.primary),
    ExerciseMuscle(name: 'Hamstrings', role: MuscleRole.secondary),
    ExerciseMuscle(name: 'Core', role: MuscleRole.stabilizer),
  ],
  commanderInsight:
      'Brace before descending and keep your entire foot firmly connected to the floor.',
  setupSteps: [
    'Position the bar securely across your upper back.',
    'Stand with your feet around shoulder width.',
    'Point your toes slightly outward.',
    'Brace your abdomen before unracking.',
  ],
  executionSteps: [
    'Bend your knees and hips together.',
    'Keep your knees tracking in the direction of your toes.',
    'Descend as deeply as your mobility and control allow.',
    'Drive through the whole foot to stand.',
  ],
  returnSteps: [
    'Finish with the hips and knees extended.',
    'Reset your breath and brace.',
    'Maintain control before the next repetition.',
  ],
  commonMistakes: [
    ExerciseMistake(
      title: 'Knees collapsing inward',
      description:
          'Allowing the knees to cave inward reduces stability and control.',
    ),
    ExerciseMistake(
      title: 'Heels lifting',
      description:
          'Losing heel contact shifts balance forward and weakens the base.',
    ),
    ExerciseMistake(
      title: 'Losing the brace',
      description:
          'A relaxed torso may cause the spine to lose its stable position.',
    ),
  ],
  exerciseImagePath:
      'assets/exercises/movements/barbell_squat.png',
  frontMuscleImagePath:
      'assets/exercises/muscles/barbell_squat_front.png',
  backMuscleImagePath:
      'assets/exercises/muscles/barbell_squat_back.png',
  difficulty: ExerciseDifficulty.intermediate,
  category: 'Legs',
  equipment: 'Barbell / Squat Rack',
);

const romanianDeadliftGuide = ExerciseGuide(
  exerciseName: 'Romanian Deadlift',
  whyThisExercise:
      'Strengthens the hamstrings and glutes while teaching a controlled hip-hinge pattern.',
  muscles: [
    ExerciseMuscle(name: 'Hamstrings', role: MuscleRole.primary),
    ExerciseMuscle(name: 'Glutes', role: MuscleRole.primary),
    ExerciseMuscle(name: 'Lower Back', role: MuscleRole.secondary),
    ExerciseMuscle(name: 'Core', role: MuscleRole.stabilizer),
  ],
  commanderInsight:
      'Push your hips backward as though you are closing a door behind you.',
  setupSteps: [
    'Stand tall while holding the weight in front of your thighs.',
    'Keep your feet around hip width.',
    'Maintain a small bend in the knees.',
    'Brace your core and keep your spine neutral.',
  ],
  executionSteps: [
    'Push your hips backward.',
    'Keep the weight close to your legs.',
    'Lower until you feel a strong hamstring stretch.',
    'Drive the hips forward to stand.',
  ],
  returnSteps: [
    'Finish tall without leaning backward.',
    'Reset your brace.',
    'Keep the knees softly bent for the next repetition.',
  ],
  commonMistakes: [
    ExerciseMistake(
      title: 'Turning it into a squat',
      description:
          'Excessive knee bending reduces the hip-hinge emphasis.',
    ),
    ExerciseMistake(
      title: 'Rounding the back',
      description:
          'Losing spinal position may increase lower-back stress.',
    ),
    ExerciseMistake(
      title: 'Weight drifting forward',
      description:
          'Keeping the load far from the legs increases the demand on the lower back.',
    ),
  ],
  exerciseImagePath:
      'assets/exercises/movements/romanian_deadlift.png',
  frontMuscleImagePath:
      'assets/exercises/muscles/romanian_deadlift_front.png',
  backMuscleImagePath:
      'assets/exercises/muscles/romanian_deadlift_back.png',
  difficulty: ExerciseDifficulty.intermediate,
  category: 'Legs',
  equipment: 'Barbell / Dumbbells',
);

const legPressGuide = ExerciseGuide(
  exerciseName: 'Leg Press',
  whyThisExercise:
      'Trains the legs with machine stability, allowing focused lower-body loading.',
  muscles: [
    ExerciseMuscle(name: 'Quadriceps', role: MuscleRole.primary),
    ExerciseMuscle(name: 'Glutes', role: MuscleRole.secondary),
    ExerciseMuscle(name: 'Hamstrings', role: MuscleRole.secondary),
  ],
  commanderInsight:
      'Keep your hips against the pad and press through the middle of your feet.',
  setupSteps: [
    'Sit with your back and hips firmly against the pad.',
    'Place your feet around shoulder width on the platform.',
    'Release the safety handles carefully.',
    'Begin with your knees comfortably bent.',
  ],
  executionSteps: [
    'Lower the platform under control.',
    'Keep your knees tracking over your toes.',
    'Press the platform away using the whole foot.',
  ],
  returnSteps: [
    'Stop before aggressively locking your knees.',
    'Lower slowly into the next repetition.',
    'Keep your hips in contact with the pad.',
  ],
  commonMistakes: [
    ExerciseMistake(
      title: 'Lower back lifting',
      description:
          'Allowing the hips to roll away from the pad may strain the lower back.',
    ),
    ExerciseMistake(
      title: 'Knees collapsing inward',
      description:
          'Poor knee tracking reduces stability and control.',
    ),
    ExerciseMistake(
      title: 'Locking the knees forcefully',
      description:
          'Aggressive lockout places unnecessary stress on the knee joints.',
    ),
  ],
  exerciseImagePath:
      'assets/exercises/movements/leg_press.png',
  frontMuscleImagePath:
      'assets/exercises/muscles/leg_press_front.png',
  backMuscleImagePath:
      'assets/exercises/muscles/leg_press_back.png',
  difficulty: ExerciseDifficulty.beginner,
  category: 'Legs',
  equipment: 'Leg Press Machine',
);

const legCurlGuide = ExerciseGuide(
  exerciseName: 'Leg Curl',
  whyThisExercise:
      'Isolates the hamstrings by directly training knee flexion.',
  muscles: [
    ExerciseMuscle(name: 'Hamstrings', role: MuscleRole.primary),
    ExerciseMuscle(name: 'Calves', role: MuscleRole.secondary),
    ExerciseMuscle(name: 'Glutes', role: MuscleRole.stabilizer),
  ],
  commanderInsight:
      'Keep your hips pressed into the pad and curl without lifting your body.',
  setupSteps: [
    'Adjust the machine so the knee joint aligns with its pivot.',
    'Place the pad just above your heels.',
    'Secure your hips and torso against the machine.',
    'Begin with the legs extended comfortably.',
  ],
  executionSteps: [
    'Curl your heels toward your body.',
    'Keep your hips against the pad.',
    'Squeeze the hamstrings at the top.',
  ],
  returnSteps: [
    'Extend the legs slowly.',
    'Avoid letting the weight stack slam down.',
    'Maintain tension before repeating.',
  ],
  commonMistakes: [
    ExerciseMistake(
      title: 'Hips lifting',
      description:
          'Lifting the hips reduces hamstring isolation and introduces momentum.',
    ),
    ExerciseMistake(
      title: 'Incorrect machine alignment',
      description:
          'Poor knee alignment can make the movement uncomfortable.',
    ),
    ExerciseMistake(
      title: 'Uncontrolled return',
      description:
          'Letting the weight pull the legs forward removes useful tension.',
    ),
  ],
  exerciseImagePath:
      'assets/exercises/movements/leg_curl.png',
  frontMuscleImagePath:
      'assets/exercises/muscles/leg_curl_front.png',
  backMuscleImagePath:
      'assets/exercises/muscles/leg_curl_back.png',
  difficulty: ExerciseDifficulty.beginner,
  category: 'Legs',
  equipment: 'Leg Curl Machine',
);

const standingCalfRaiseGuide = ExerciseGuide(
  exerciseName: 'Standing Calf Raise',
  whyThisExercise:
      'Strengthens the calf muscles and improves ankle strength and control.',
  muscles: [
    ExerciseMuscle(name: 'Gastrocnemius', role: MuscleRole.primary),
    ExerciseMuscle(name: 'Soleus', role: MuscleRole.secondary),
    ExerciseMuscle(name: 'Core', role: MuscleRole.stabilizer),
  ],
  commanderInsight:
      'Rise through the balls of your feet and pause at the top instead of bouncing.',
  setupSteps: [
    'Stand with the balls of your feet securely supported.',
    'Keep your legs mostly straight without locking the knees.',
    'Hold a stable support if needed.',
    'Allow your heels to lower comfortably.',
  ],
  executionSteps: [
    'Raise your heels as high as possible.',
    'Keep your ankles aligned.',
    'Pause briefly at the top.',
  ],
  returnSteps: [
    'Lower the heels slowly.',
    'Use a comfortable stretch at the bottom.',
    'Avoid bouncing into the next repetition.',
  ],
  commonMistakes: [
    ExerciseMistake(
      title: 'Bouncing',
      description:
          'Using momentum reduces controlled calf contraction.',
    ),
    ExerciseMistake(
      title: 'Partial range',
      description:
          'Short repetitions limit both the stretch and contraction.',
    ),
    ExerciseMistake(
      title: 'Ankles rolling outward',
      description:
          'Poor ankle alignment can reduce stability and control.',
    ),
  ],
  exerciseImagePath:
      'assets/exercises/movements/standing_calf_raise.png',
  frontMuscleImagePath:
      'assets/exercises/muscles/standing_calf_raise_front.png',
  backMuscleImagePath:
      'assets/exercises/muscles/standing_calf_raise_back.png',
  difficulty: ExerciseDifficulty.beginner,
  category: 'Legs',
  equipment: 'Machine / Bodyweight',
);

class LegsGuides {
  static const exercises = [
    barbellSquatGuide,
    romanianDeadliftGuide,
    legPressGuide,
    legCurlGuide,
    standingCalfRaiseGuide,
  ];
}