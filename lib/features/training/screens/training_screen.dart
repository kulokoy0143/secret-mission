import 'dart:async';

import 'package:flutter/material.dart';
import 'package:secret_mission/app/app_theme.dart';
import 'package:secret_mission/features/training/screens/exercise_guide_screen.dart';
import 'package:secret_mission/features/training/models/workout_set.dart';
import 'package:secret_mission/features/training/services/workout_storage_service.dart';
import 'package:secret_mission/features/training/services/session_manager.dart';
import 'package:secret_mission/features/training/data/workout_plans.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key, required this.onWorkoutFinished});

  final VoidCallback onWorkoutFinished;

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

  List<WorkoutSet> _completedSets = [];

  bool _usesKilograms = false;

  Timer? _restTimer;
  int _restSeconds = 90;
  int _remainingSeconds = 90;
  bool _isResting = false;
  bool _isTimerPaused = false;

  int get _currentSetNumber {
    final activeWorkout = SessionManager.activeWorkout;

    if (activeWorkout == null) {
      return 1;
    }

    final currentExerciseSets = WorkoutStorageService.getAllSets().where((set) {
      return set.sessionId == activeWorkout.sessionId &&
          set.exerciseName == _currentExerciseName;
    }).length;

    return currentExerciseSets + 1;
  }

  int _currentExerciseIndex = 0;

  WorkoutPlan? get _currentPlan {
    final activeWorkout = SessionManager.activeWorkout;

    if (activeWorkout == null) return null;

    return WorkoutPlans.forType(activeWorkout.type);
  }

  String get _currentExerciseName {
    final plan = _currentPlan;

    if (plan == null || plan.exercises.isEmpty) {
      return 'No Exercise';
    }

    return plan.exercises[_currentExerciseIndex];
  }

  int get _totalExercises {
    return _currentPlan?.exercises.length ?? 0;
  }

  bool get _isLastExercise {
    if (_totalExercises == 0) {
      return false;
    }

    return _currentExerciseIndex >= _totalExercises - 1;
  }

  double get _totalVolume {
    return _completedSets.fold(
      0,
      (total, set) => total + (set.weight * set.reps),
    );
  }

  List<WorkoutSet> get _activeSessionSets {
    final activeWorkout = SessionManager.activeWorkout;

    if (activeWorkout == null) {
      return [];
    }

    return WorkoutStorageService.getAllSets().where((set) {
      return set.sessionId == activeWorkout.sessionId;
    }).toList();
  }

  int get _sessionSetCount => _activeSessionSets.length;

  double get _sessionTotalVolume {
    return _activeSessionSets.fold(0, (total, set) => total + set.volume);
  }

  @override
  void initState() {
    super.initState();
    _loadWorkoutHistory();
  }

  void _loadWorkoutHistory() {
    final activeWorkout = SessionManager.activeWorkout;

    if (activeWorkout == null) {
      setState(() {
        _completedSets = [];
      });
      return;
    }

    final allSets = WorkoutStorageService.getAllSets();

    setState(() {
      _completedSets = allSets.where((set) {
        return set.sessionId == activeWorkout.sessionId &&
            set.exerciseName == _currentExerciseName;
      }).toList();
    });
  }

  @override
  void dispose() {
    _restTimer?.cancel();
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

  Future<void> _saveSet() async {
    final weight = double.tryParse(_weightController.text.trim());
    final reps = int.tryParse(_repsController.text.trim());

    if (weight == null || weight <= 0 || reps == null || reps <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid weight and number of reps.'),
        ),
      );
      return;
    }
    final activeWorkout = SessionManager.activeWorkout;

    if (activeWorkout == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Start a workout before saving a set.')),
      );
      return;
    }

    final unit = _usesKilograms ? 'kg' : 'lb';

    final workoutSet = WorkoutSet(
      exerciseName: _currentExerciseName,
      setNumber: _currentSetNumber,
      weight: weight,
      reps: reps,
      unit: unit,
      completedAt: DateTime.now(),
      sessionId: activeWorkout.sessionId,
      workoutName: activeWorkout.name,
    );

    await WorkoutStorageService.saveSet(workoutSet);

    if (!mounted) return;

    _loadWorkoutHistory();

    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Set saved: ${_formatNumber(weight)} $unit × $reps reps'),
      ),
    );

    _startRestTimer();
  }

  void _startRestTimer() {
    _restTimer?.cancel();

    setState(() {
      _remainingSeconds = _restSeconds;
      _isResting = true;
      _isTimerPaused = false;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isTimerPaused) return;

      if (_remainingSeconds <= 1) {
        timer.cancel();

        if (!mounted) return;

        setState(() {
          _remainingSeconds = 0;
          _isResting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rest complete. Begin your next set.')),
        );
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  void _toggleTimerPause() {
    setState(() {
      _isTimerPaused = !_isTimerPaused;
    });
  }

  void _changeRestTime(int seconds) {
    setState(() {
      _remainingSeconds = (_remainingSeconds + seconds).clamp(0, 600);

      _restSeconds = (_restSeconds + seconds).clamp(15, 600);
    });
  }

  void _skipRest() {
    _restTimer?.cancel();

    setState(() {
      _remainingSeconds = 0;
      _isResting = false;
      _isTimerPaused = false;
    });
  }

  Future<void> _deleteSet(int index) async {
    await WorkoutStorageService.deleteSet(_completedSets[index]);

    _loadWorkoutHistory();
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(1);
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _confirmFinishWorkout() async {
    final shouldFinish = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Finish Mission?'),
          content: const Text(
            'Are you sure you are done with this workout? '
            'You will return to the Command Center.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('CANCEL'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('FINISH MISSION'),
            ),
          ],
        );
      },
    );

    if (shouldFinish == true && mounted) {
      _finishWorkout();
    }
  }

  void _finishWorkout() {
    final finishedWorkout = SessionManager.finishWorkout();

    if (finishedWorkout == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('There is no active workout to finish.')),
      );
      return;
    }
    _restTimer?.cancel();

    _resetWorkoutProgress();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${finishedWorkout.name} completed. Mission accomplished!',
        ),
      ),
    );

    widget.onWorkoutFinished();
  }

  void _resetWorkoutProgress() {
    setState(() {
      _currentExerciseIndex = 0;
      _completedSets.clear();

      _weightController.text = '40';
      _repsController.text = '10';

      _isResting = false;
      _isTimerPaused = false;
      _remainingSeconds = _restSeconds;
    });
  }

  void _nextExercise() {
    final plan = _currentPlan;

    if (plan == null) return;

    if (_currentExerciseIndex >= plan.exercises.length - 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You have reached the final exercise. Finish the mission when ready.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _currentExerciseIndex++;

      _loadWorkoutHistory();

      _weightController.text = '40';
      _repsController.text = '10';
    });
  }

  void _previousExercise() {
    if (_currentExerciseIndex <= 0) {
      return;
    }

    setState(() {
      _currentExerciseIndex--;
    });

    _loadWorkoutHistory();

    _restTimer?.cancel();

    setState(() {
      _isResting = false;
      _isTimerPaused = false;
      _remainingSeconds = _restSeconds;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeWorkout = SessionManager.activeWorkout;
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
          Text(
            activeWorkout?.name ?? 'No Active Workout',
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            activeWorkout != null
                ? 'Workout in Progress'
                : 'Press START WORKOUT to begin',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 28),

          _buildExerciseHeader(),
          const SizedBox(height: 16),

          _buildPreviousPerformance(),
          const SizedBox(height: 16),

          _buildSetLogger(),

          if (_completedSets.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSetHistory(),
          ],

          if (_isResting) ...[const SizedBox(height: 16), _buildRestTimer()],

          if (_totalExercises > 0) ...[
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _currentExerciseIndex == 0
                        ? null
                        : _previousExercise,
                    icon: const Icon(Icons.skip_previous_rounded),
                    label: const Text('PREVIOUS'),
                  ),
                ),

                if (!_isLastExercise) ...[
                  const SizedBox(width: 12),

                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _nextExercise,
                      icon: const Icon(Icons.skip_next_rounded),
                      label: const Text('NEXT'),
                    ),
                  ),
                ],
              ],
            ),
          ],

          const SizedBox(height: 16),
          _buildMissionControl(),

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
      child: Row(
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
                  _currentExerciseName,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text(
                  'Exercise ${_currentExerciseIndex + 1} of $_totalExercises',
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
          Text(
            'SET $_currentSetNumber',
            style: const TextStyle(
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

  Widget _buildSetHistory() {
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
          Row(
            children: [
              const Expanded(
                child: Text(
                  'COMPLETED SETS',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.3,
                  ),
                ),
              ),
              Text(
                'Volume: ${_formatNumber(_totalVolume)}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...List.generate(_completedSets.length, (index) {
            final set = _completedSets[index];

            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.18),
                child: Text(
                  '${set.setNumber}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                '${_formatNumber(set.weight)} ${set.unit} × '
                '${set.reps} reps',
              ),
              subtitle: Text(
                'Volume: ${_formatNumber(set.weight * set.reps)} '
                '${set.unit}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              trailing: IconButton(
                onPressed: () => _deleteSet(index),
                tooltip: 'Delete set',
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRestTimer() {
    final progress = _restSeconds == 0
        ? 0.0
        : (_remainingSeconds / _restSeconds).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          const Text(
            'REST TIMER',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _formatTime(_remainingSeconds),
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(20),
            backgroundColor: AppColors.background,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _changeRestTime(-15),
                  child: const Text('-15 SEC'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _toggleTimerPause,
                tooltip: _isTimerPaused ? 'Resume' : 'Pause',
                icon: Icon(
                  _isTimerPaused
                      ? Icons.play_arrow_rounded
                      : Icons.pause_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _changeRestTime(15),
                  child: const Text('+15 SEC'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextButton(onPressed: _skipRest, child: const Text('SKIP REST')),
        ],
      ),
    );
  }

  Widget _buildMissionControl() {
    final activeWorkout = SessionManager.activeWorkout;
    final unit = _usesKilograms ? 'kg' : 'lb';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MISSION CONTROL',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildMissionStat(
                  icon: Icons.format_list_numbered_rounded,
                  label: 'Sets',
                  value: '$_sessionSetCount',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMissionStat(
                  icon: Icons.fitness_center_rounded,
                  label: 'Volume',
                  value: '${_formatNumber(_sessionTotalVolume)} $unit',
                ),
              ),
            ],
          ),
          if (_isLastExercise) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: activeWorkout == null ? null : _confirmFinishWorkout,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.flag_rounded),
                label: const Text(
                  'FINISH MISSION',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMissionStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          Navigator.of(context).push(
            MaterialPageRoute(
  builder: (_) => ExerciseGuideScreen(
    exerciseName: _currentExerciseName,
  ),
),
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
