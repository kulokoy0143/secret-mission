import 'package:flutter/material.dart';
import 'package:secret_mission/app/app_theme.dart';
import 'package:secret_mission/features/training/data/guides/exercise_guides.dart';
import 'package:secret_mission/features/training/models/exercise_guide.dart';
import 'package:secret_mission/features/training/models/exercise_difficulty.dart';

class ExerciseGuideScreen extends StatelessWidget {
  const ExerciseGuideScreen({
    super.key,
    required this.exerciseName,
  });

  final String exerciseName;

  @override
  Widget build(BuildContext context) {
    final guide = ExerciseGuides.findByName(exerciseName);

    if (guide == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mission Briefing'),
          backgroundColor: AppColors.background,
        ),
        body: _buildMissingGuide(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mission Briefing'),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           _buildExerciseHeader(guide),
const SizedBox(height: 16),

_buildWhyThisExercise(guide),
const SizedBox(height: 16),

_buildSection(
  title: 'MUSCLES WORKED',
  icon: Icons.accessibility_new_rounded,
  children: [
    _MuscleRoleGroup(
      title: 'PRIMARY',
      muscles: guide.primaryMuscles,
      icon: Icons.bolt_rounded,
    ),

    if (guide.secondaryMuscles.isNotEmpty) ...[
      const SizedBox(height: 16),
      _MuscleRoleGroup(
        title: 'SECONDARY',
        muscles: guide.secondaryMuscles,
        icon: Icons.add_circle_outline_rounded,
      ),
    ],

    if (guide.stabilizerMuscles.isNotEmpty) ...[
      const SizedBox(height: 16),
      _MuscleRoleGroup(
        title: 'STABILIZERS',
        muscles: guide.stabilizerMuscles,
        icon: Icons.shield_outlined,
      ),
    ],
  ],
),
const SizedBox(height: 16),

_buildCommanderTip(guide),
const SizedBox(height: 16),

_buildSection(
  title: 'HOW TO PERFORM',
  icon: Icons.fitness_center_rounded,
  children: [
    _InstructionPhase(
      title: 'SETUP',
      icon: Icons.tune_rounded,
      steps: guide.setupSteps,
    ),

    const SizedBox(height: 18),

    _InstructionPhase(
      title: 'EXECUTION',
      icon: Icons.play_arrow_rounded,
      steps: guide.executionSteps,
    ),

    const SizedBox(height: 18),

    _InstructionPhase(
      title: 'RETURN',
      icon: Icons.replay_rounded,
      steps: guide.returnSteps,
    ),
  ],
),
const SizedBox(height: 16),

_buildSection(
  title: 'COMMON MISTAKES',
  icon: Icons.warning_amber_rounded,
  children: guide.commonMistakes
      .map(
        (mistake) => _MistakeCard(
          title: mistake.title,
          description: mistake.description,
        ),
      )
      .toList(),
),
const SizedBox(height: 16),

_buildMovementImage(guide),
const SizedBox(height: 16),

_buildMuscleImages(guide),
          ],
        ),
      ),
    );
  }

  Widget _buildMissingGuide() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: AppColors.primary,
                size: 46,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              exerciseName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'A detailed guide for this exercise has not been added yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseHeader(ExerciseGuide guide) {
    final muscleSummary = [
      ...guide.primaryMuscles,
      ...guide.secondaryMuscles,
    ].join(' • ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF7C4DFF),
            Color(0xFF5E35B1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.fitness_center_rounded,
            size: 42,
            color: Colors.white,
          ),
          const SizedBox(height: 20),
          Text(
            guide.exerciseName.toUpperCase(),
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            muscleSummary,
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(label: guide.difficulty.label),
              _InfoChip(label: guide.category),
              _InfoChip(label: guide.equipment),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWhyThisExercise(ExerciseGuide guide) {
    return _buildSection(
      title: 'WHY THIS EXERCISE',
      icon: Icons.lightbulb_rounded,
      children: [
        Text(
          guide.whyThisExercise,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildMovementImage(ExerciseGuide guide) {
    return _buildSection(
      title: 'MOVEMENT GUIDE',
      icon: Icons.play_circle_outline_rounded,
      children: [
        _ExerciseImageCard(
  imagePath: guide.exerciseImagePath,
  label: 'Exercise demonstration',
  fallbackIcon: Icons.fitness_center_rounded,
  imageHeight: 320,
),
      ],
    );
  }

  Widget _buildMuscleImages(ExerciseGuide guide) {
    return _buildSection(
      title: 'MUSCLE MAP',
      icon: Icons.accessibility_rounded,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _ExerciseImageCard(
                imagePath: guide.frontMuscleImagePath,
                label: 'Front',
                fallbackIcon: Icons.accessibility_new_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ExerciseImageCard(
                imagePath: guide.backMuscleImagePath,
                label: 'Back',
                fallbackIcon: Icons.accessibility_new_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Row(
          children: [
            _MuscleLegendDot(
              label: 'Primary',
              opacity: 1,
            ),
            SizedBox(width: 18),
            _MuscleLegendDot(
              label: 'Secondary',
              opacity: 0.55,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCommanderTip(ExerciseGuide guide) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "COMMANDER'S INSIGHT",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  guide.commanderInsight,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseImageCard extends StatelessWidget {
  const _ExerciseImageCard({
  required this.imagePath,
  required this.label,
  required this.fallbackIcon,
  this.imageHeight = 180,
});

  final double imageHeight;
  final String imagePath;
  final String label;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: imageHeight,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
  mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
  height: imageHeight,
  width: double.infinity,
  child: Image.asset(
    imagePath,
    fit: BoxFit.contain,
    errorBuilder: (context, error, stackTrace) {
      return _buildPlaceholder();
    },
  ),
),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            color: Colors.white.withValues(alpha: 0.03),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              fallbackIcon,
              color: AppColors.primary,
              size: 44,
            ),
            const SizedBox(height: 12),
            const Text(
              'Image coming soon',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MuscleLegendDot extends StatelessWidget {
  const _MuscleLegendDot({
    required this.label,
    required this.opacity,
  });

  final String label;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: opacity),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MuscleRoleGroup extends StatelessWidget {
  const _MuscleRoleGroup({
    required this.title,
    required this.muscles,
    required this.icon,
  });

  final String title;
  final List<String> muscles;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: muscles
                .map(
                  (muscle) => _MuscleChip(
                    label: muscle,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _MuscleChip extends StatelessWidget {
  const _MuscleChip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MistakeCard extends StatelessWidget {
  const _MistakeCard({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.close_rounded,
              color: Colors.orange,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionPhase extends StatelessWidget {
  const _InstructionPhase({
    required this.title,
    required this.icon,
    required this.steps,
  });

  final String title;
  final IconData icon;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        ...List.generate(
          steps.length,
          (index) => _PhaseStep(
            number: index + 1,
            text: steps[index],
          ),
        ),
      ],
    );
  }
}

class _PhaseStep extends StatelessWidget {
  const _PhaseStep({
    required this.number,
    required this.text,
  });

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
