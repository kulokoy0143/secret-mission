import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  final TextEditingController _weightController = TextEditingController(
    text: '40',
  );

  final TextEditingController _repsController = TextEditingController(
    text: '10',
  );

  bool _usesKilograms = false;

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _toggleWeightUnit() {
    final currentWeight = double.tryParse(_weightController.text.trim()) ?? 0;

    final convertedWeight = _usesKilograms
        ? currentWeight * 2.20462
        : currentWeight / 2.20462;

    setState(() {
      _usesKilograms = !_usesKilograms;
      _weightController.text = convertedWeight.toStringAsFixed(1);
    });
  }

  void _saveSet() {
    final weight = _weightController.text.trim();
    final reps = _repsController.text.trim();
    final unit = _usesKilograms ? 'kg' : 'lb';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Set saved: $weight $unit × $reps reps')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TRAINING MISSION',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Push Day',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Chest • Shoulders • Triceps',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 28),

          _buildExerciseHeader(),

          const SizedBox(height: 16),

          _buildPreviousPerformance(),

          const SizedBox(height: 16),

          _buildSetLogger(),

          const SizedBox(height: 16),

          _buildExerciseGuideButton(),
        ],
      ),
    );
  }

  Widget _buildExerciseHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.fitness_center_rounded, color: Colors.white),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Incline Bench Press',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text(
                  'Exercise 1 of 5',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviousPerformance() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LAST SESSION',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '40 lb × 10 reps',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4),
          Text(
            'Recommended target: 42.5 lb × 8 reps',
            style: TextStyle(color: AppColors.success),
          ),
        ],
      ),
    );
  }

  Widget _buildSetLogger() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SET 1',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 18),

          const Text(
            'Weight',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.background,
                    suffixText: _usesKilograms ? 'kg' : 'lb',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                onPressed: _toggleWeightUnit,
                tooltip: 'Convert kg and lb',
                icon: const Icon(Icons.swap_horiz_rounded),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Text('Reps', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 8),

          TextField(
            controller: _repsController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.background,
              suffixText: 'reps',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _saveSet,
              icon: const Icon(Icons.check_rounded),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  'SAVE SET',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseGuideButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Exercise Academy coming next.')),
          );
        },
        icon: const Icon(Icons.menu_book_rounded),
        label: const Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Text('VIEW EXERCISE GUIDE'),
        ),
      ),
    );
  }
}
