import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class ExerciseGuideScreen extends StatelessWidget {
  const ExerciseGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Guide'),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExerciseHeader(),
            const SizedBox(height: 16),
            _buildSection(
              title: 'MUSCLES WORKED',
              icon: Icons.accessibility_new_rounded,
              children: const [
                _GuidePoint(text: 'Upper chest — primary muscle'),
                _GuidePoint(text: 'Front shoulders — secondary muscle'),
                _GuidePoint(text: 'Triceps — assists during pressing'),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'HOW TO PERFORM',
              icon: Icons.format_list_numbered_rounded,
              children: const [
                _NumberedStep(
                  number: 1,
                  text: 'Set the bench angle between 30° and 45°.',
                ),
                _NumberedStep(
                  number: 2,
                  text: 'Plant both feet firmly on the floor.',
                ),
                _NumberedStep(
                  number: 3,
                  text:
                      'Pull your shoulder blades back and keep your chest raised.',
                ),
                _NumberedStep(
                  number: 4,
                  text:
                      'Lower the weight under control toward your upper chest.',
                ),
                _NumberedStep(
                  number: 5,
                  text: 'Press upward without excessively flaring your elbows.',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'BREATHING AND TEMPO',
              icon: Icons.air_rounded,
              children: const [
                _GuidePoint(text: 'Inhale while lowering the weight.'),
                _GuidePoint(text: 'Exhale while pressing upward.'),
                _GuidePoint(
                  text: 'Recommended tempo: 3 seconds down, 1 second up.',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'COMMON MISTAKES',
              icon: Icons.warning_amber_rounded,
              children: const [
                _WarningPoint(text: 'Using a bench angle that is too steep.'),
                _WarningPoint(text: 'Flaring the elbows directly outward.'),
                _WarningPoint(text: 'Bouncing the weight off the chest.'),
                _WarningPoint(text: 'Lifting the feet or hips excessively.'),
                _WarningPoint(
                  text: 'Using weight that prevents controlled movement.',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'ALTERNATIVES',
              icon: Icons.swap_horiz_rounded,
              children: const [
                _GuidePoint(text: 'Incline dumbbell press'),
                _GuidePoint(text: 'Incline chest press machine'),
                _GuidePoint(text: 'Low-to-high cable fly'),
                _GuidePoint(text: 'Feet-elevated push-up'),
              ],
            ),
            const SizedBox(height: 16),
            _buildCommanderTip(),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C4DFF), Color(0xFF5E35B1)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.fitness_center_rounded, size: 42, color: Colors.white),
          SizedBox(height: 20),
          Text(
            'INCLINE BENCH PRESS',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 6),
          Text(
            'Upper Chest • Shoulders • Triceps',
            style: TextStyle(color: Colors.white70),
          ),
          SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(label: 'Intermediate'),
              _InfoChip(label: 'Push'),
              _InfoChip(label: 'Barbell / Dumbbell'),
            ],
          ),
        ],
      ),
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
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary),
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

  Widget _buildCommanderTip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Icon(Icons.smart_toy_rounded, color: Colors.white),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'COMMANDER TIP',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Prioritize controlled repetitions. Stop the set when your shoulder position or range of motion begins to break down.',
                  style: TextStyle(color: AppColors.textSecondary, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _GuidePoint extends StatelessWidget {
  const _GuidePoint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 19,
            color: AppColors.success,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningPoint extends StatelessWidget {
  const _WarningPoint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.close_rounded, size: 20, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberedStep extends StatelessWidget {
  const _NumberedStep({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: Text(
              '$number',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
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
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
