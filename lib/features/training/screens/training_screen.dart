import 'dart:async';

import 'package:flutter/material.dart';
import 'package:secret_mission/app/app_theme.dart';
import 'package:secret_mission/features/recovery/models/recovery_status.dart';
import 'package:secret_mission/features/recovery/services/recovery_service.dart';
import 'package:secret_mission/features/recovery/services/recovery_storage_service.dart';
import 'package:secret_mission/features/training/screens/exercise_guide_screen.dart';
import 'package:secret_mission/features/training/models/workout_set.dart';
import 'package:secret_mission/features/training/services/workout_storage_service.dart';
import 'package:secret_mission/features/training/services/session_manager.dart';
import 'package:secret_mission/features/training/data/workout_plans.dart';
import 'package:secret_mission/features/training/screens/workout_completion_screen.dart';

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

  WorkoutCompletionData? _completionData;

  bool _usesKilograms = false;

  Timer? _restTimer;
  int _restSeconds = 120;
  int _remainingSeconds = 120;
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
  String? _preparedSessionId;

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

    final previousSessionSets = _getPreviousExerciseSessionSets();

    final previousBest = _getPreviousBestSet(previousSessionSets);

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

    final isPersonalRecord = _isPersonalRecord(workoutSet, previousBest);

    await WorkoutStorageService.saveSet(workoutSet);

    if (!mounted) return;

    _loadWorkoutHistory();

    FocusScope.of(context).unfocus();

    if (isPersonalRecord && previousBest != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 4),
          content: Row(
            children: [
              const Icon(Icons.emoji_events_rounded, color: Colors.amber),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'NEW PERSONAL RECORD! '
                  '${_formatNumber(weight)} $unit × $reps reps\n'
                  'Previous best: '
                  '${_formatNumber(previousBest.weight)} '
                  '${previousBest.unit} × '
                  '${previousBest.reps} reps',
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Set saved: ${_formatNumber(weight)} $unit × $reps reps',
          ),
        ),
      );
    }
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

  String _formatCompletionVolume(List<WorkoutSet> sets) {
    if (sets.isEmpty) {
      return '0 ${_usesKilograms ? 'kg' : 'lb'}';
    }

    final displayUnit = sets.first.unit;

    double totalVolume = 0;

    for (final set in sets) {
      var weight = set.weight;

      if (set.unit != displayUnit) {
        weight = displayUnit == 'kg'
            ? set.weight / 2.20462
            : set.weight * 2.20462;
      }

      totalVolume += weight * set.reps;
    }

    return '${_formatNumber(totalVolume)} $displayUnit';
  }

  double _calculateVolumeInUnit(List<WorkoutSet> sets, String displayUnit) {
    double totalVolume = 0;

    for (final set in sets) {
      var weight = set.weight;

      if (set.unit != displayUnit) {
        weight = displayUnit == 'kg'
            ? set.weight / 2.20462
            : set.weight * 2.20462;
      }

      totalVolume += weight * set.reps;
    }

    return totalVolume;
  }

  List<WorkoutSet> _getPreviousMatchingMissionSets({
    required String workoutName,
    required String currentSessionId,
  }) {
    final previousSets = WorkoutStorageService.getAllSets()
        .where(
          (set) =>
              set.workoutName == workoutName &&
              set.sessionId != currentSessionId,
        )
        .toList();

    if (previousSets.isEmpty) {
      return [];
    }

    final latestPreviousSet = previousSets.last;
    final previousSessionId = latestPreviousSet.sessionId;

    if (previousSessionId != null) {
      return previousSets
          .where((set) => set.sessionId == previousSessionId)
          .toList();
    }

    final previousDate = DateTime(
      latestPreviousSet.completedAt.year,
      latestPreviousSet.completedAt.month,
      latestPreviousSet.completedAt.day,
    );

    return previousSets.where((set) {
      final setDate = DateTime(
        set.completedAt.year,
        set.completedAt.month,
        set.completedAt.day,
      );

      return set.sessionId == null &&
          set.workoutName == workoutName &&
          setDate == previousDate;
    }).toList();
  }

  WorkoutComparisonData? _buildWorkoutComparison({
    required String workoutName,
    required String currentSessionId,
    required List<WorkoutSet> currentSets,
  }) {
    final previousSets = _getPreviousMatchingMissionSets(
      workoutName: workoutName,
      currentSessionId: currentSessionId,
    );

    if (previousSets.isEmpty) {
      return null;
    }

    final displayUnit = currentSets.isNotEmpty
        ? currentSets.first.unit
        : previousSets.first.unit;

    final currentVolume = _calculateVolumeInUnit(currentSets, displayUnit);

    final previousVolume = _calculateVolumeInUnit(previousSets, displayUnit);

    final volumeChangePercent = previousVolume == 0
        ? 0.0
        : ((currentVolume - previousVolume) / previousVolume) * 100;

    return WorkoutComparisonData(
      previousDate: previousSets.last.completedAt,
      previousSetCount: previousSets.length,
      previousVolumeText: '${_formatNumber(previousVolume)} $displayUnit',
      setDifference: currentSets.length - previousSets.length,
      volumeChangePercent: volumeChangePercent,
    );
  }

  double _progressionWeightInKilograms(WorkoutSet set) {
    if (set.unit == 'kg') {
      return set.weight;
    }

    return set.weight / 2.20462;
  }

  double _progressionSetVolume(WorkoutSet set) {
    return _progressionWeightInKilograms(set) * set.reps;
  }

  double _convertProgressionWeight({
    required double weight,
    required String fromUnit,
    required String toUnit,
  }) {
    if (fromUnit == toUnit) {
      return weight;
    }

    if (fromUnit == 'kg' && toUnit == 'lb') {
      return weight * 2.20462;
    }

    return weight / 2.20462;
  }

  WorkoutSet _getProgressionBestSet(List<WorkoutSet> sets) {
    WorkoutSet bestSet = sets.first;

    for (final set in sets.skip(1)) {
      final setVolume = _progressionSetVolume(set);
      final bestVolume = _progressionSetVolume(bestSet);

      final volumeDifference = setVolume - bestVolume;

      if (volumeDifference > 0.0001 ||
          (volumeDifference.abs() <= 0.0001 &&
              _progressionWeightInKilograms(set) >
                  _progressionWeightInKilograms(bestSet))) {
        bestSet = set;
      }
    }

    return bestSet;
  }

  List<WorkoutSet> _getPreviousExerciseSetsForProgression({
    required String exerciseName,
    required String currentSessionId,
  }) {
    final previousSets =
        WorkoutStorageService.getAllSets()
            .where(
              (set) =>
                  set.exerciseName == exerciseName &&
                  set.sessionId != currentSessionId,
            )
            .toList()
          ..sort(
            (first, second) => first.completedAt.compareTo(second.completedAt),
          );

    if (previousSets.isEmpty) {
      return [];
    }

    final latestPreviousSet = previousSets.last;

    final previousSessionId = latestPreviousSet.sessionId;

    if (previousSessionId != null) {
      return previousSets
          .where((set) => set.sessionId == previousSessionId)
          .toList();
    }

    final previousDate = DateTime(
      latestPreviousSet.completedAt.year,
      latestPreviousSet.completedAt.month,
      latestPreviousSet.completedAt.day,
    );

    return previousSets.where((set) {
      final setDate = DateTime(
        set.completedAt.year,
        set.completedAt.month,
        set.completedAt.day,
      );

      return set.sessionId == null &&
          set.workoutName == latestPreviousSet.workoutName &&
          setDate == previousDate;
    }).toList();
  }

  ExerciseProgressionData _buildExerciseProgression({
    required String exerciseName,
    required List<WorkoutSet> currentSets,
    required String currentSessionId,
  }) {
    final currentBest = _getProgressionBestSet(currentSets);

    final previousSets = _getPreviousExerciseSetsForProgression(
      exerciseName: exerciseName,
      currentSessionId: currentSessionId,
    );

    if (previousSets.isEmpty) {
      return ExerciseProgressionData(
        exerciseName: exerciseName,
        currentWeight: currentBest.weight,
        currentReps: currentBest.reps,
        currentUnit: currentBest.unit,
        status: ExerciseProgressionStatus.baseline,
        changeText: 'First recorded performance.',
      );
    }

    final previousBest = _getProgressionBestSet(previousSets);

    final currentWeightKg = _progressionWeightInKilograms(currentBest);

    final previousWeightKg = _progressionWeightInKilograms(previousBest);

    final currentVolume = _progressionSetVolume(currentBest);

    final previousVolume = _progressionSetVolume(previousBest);

    final weightDifferenceKg = currentWeightKg - previousWeightKg;

    final sameLoad = weightDifferenceKg.abs() <= 0.01;

    final volumeChangePercent = previousVolume == 0
        ? 0.0
        : ((currentVolume - previousVolume) / previousVolume) * 100;

    final previousWeightInCurrentUnit = _convertProgressionWeight(
      weight: previousBest.weight,
      fromUnit: previousBest.unit,
      toUnit: currentBest.unit,
    );

    final loadDifference = currentBest.weight - previousWeightInCurrentUnit;

    ExerciseProgressionStatus status;
    String changeText;

    if (weightDifferenceKg > 0.01) {
      status = ExerciseProgressionStatus.progressed;

      changeText =
          '+${_formatNumber(loadDifference)} '
          '${currentBest.unit} load';
    } else if (sameLoad && currentBest.reps > previousBest.reps) {
      final repDifference = currentBest.reps - previousBest.reps;

      status = ExerciseProgressionStatus.progressed;

      changeText = repDifference == 1
          ? '+1 rep at the same load'
          : '+$repDifference reps at the same load';
    } else if (currentVolume > previousVolume + 0.0001) {
      status = ExerciseProgressionStatus.progressed;

      changeText =
          '+${volumeChangePercent.toStringAsFixed(1)}% '
          'best-set volume';
    } else if (volumeChangePercent.abs() <= 5) {
      status = ExerciseProgressionStatus.maintained;

      changeText = 'Best-set performance stayed within 5%.';
    } else {
      status = ExerciseProgressionStatus.lower;

      changeText =
          '${volumeChangePercent.toStringAsFixed(1)}% '
          'best-set volume';
    }

    return ExerciseProgressionData(
      exerciseName: exerciseName,
      currentWeight: currentBest.weight,
      currentReps: currentBest.reps,
      currentUnit: currentBest.unit,
      previousWeight: previousBest.weight,
      previousReps: previousBest.reps,
      previousUnit: previousBest.unit,
      status: status,
      changeText: changeText,
    );
  }

  List<ExerciseProgressionData> _buildExerciseProgressions({
    required List<WorkoutSet> currentSets,
    required String currentSessionId,
  }) {
    final exerciseNames = <String>[];

    for (final set in currentSets) {
      if (!exerciseNames.contains(set.exerciseName)) {
        exerciseNames.add(set.exerciseName);
      }
    }

    return exerciseNames.map((exerciseName) {
      final exerciseSets = currentSets
          .where((set) => set.exerciseName == exerciseName)
          .toList();

      return _buildExerciseProgression(
        exerciseName: exerciseName,
        currentSets: exerciseSets,
        currentSessionId: currentSessionId,
      );
    }).toList();
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
            'Your mission debrief will be generated next.',
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
    final activeWorkout = SessionManager.activeWorkout;

    if (activeWorkout == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('There is no active workout to finish.')),
      );
      return;
    }

    final sessionSets = WorkoutStorageService.getAllSets()
        .where((set) => set.sessionId == activeWorkout.sessionId)
        .toList();

    final exerciseCount = sessionSets
        .map((set) => set.exerciseName)
        .toSet()
        .length;

    final personalRecordSets = sessionSets
        .where(_isHistoricalPersonalRecord)
        .toList();

    final personalRecordCount = personalRecordSets.length;

    final todaySleep = RecoveryStorageService.getSleepEntry(DateTime.now());

    final recovery = todaySleep == null
        ? null
        : RecoveryService.calculateRecovery(todaySleep);

    final comparison = _buildWorkoutComparison(
      workoutName: activeWorkout.name,
      currentSessionId: activeWorkout.sessionId,
      currentSets: sessionSets,
    );

    final exerciseProgressions = _buildExerciseProgressions(
      currentSets: sessionSets,
      currentSessionId: activeWorkout.sessionId,
    );

    final completionData = WorkoutCompletionData(
      workoutName: activeWorkout.name,
      duration: DateTime.now().difference(activeWorkout.startedAt),
      exerciseCount: exerciseCount,
      setCount: sessionSets.length,
      volumeText: _formatCompletionVolume(sessionSets),
      personalRecordCount: personalRecordCount,
      personalRecords: personalRecordSets
          .map(
            (set) => WorkoutCompletionPr(
              exerciseName: set.exerciseName,
              weight: set.weight,
              reps: set.reps,
              unit: set.unit,
            ),
          )
          .toList(),
      comparison: comparison,
      exerciseProgressions: exerciseProgressions,
      recovery: recovery,
    );

    final finishedWorkout = SessionManager.finishWorkout();

    if (finishedWorkout == null) {
      return;
    }

    _restTimer?.cancel();

    setState(() {
      _isResting = false;
      _isTimerPaused = false;
      _remainingSeconds = _restSeconds;

      _completionData = completionData;
    });
  }

  void _closeWorkoutCompletion() {
    _resetWorkoutProgress();

    widget.onWorkoutFinished();
  }

  void _resetWorkoutProgress() {
    setState(() {
      _completionData = null;

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
    });

    _loadWorkoutHistory();
    _applySuggestedTargetToInputs();
  }

  void _previousExercise() {
    if (_currentExerciseIndex <= 0) {
      return;
    }

    setState(() {
      _currentExerciseIndex--;
    });

    _loadWorkoutHistory();
    _applySuggestedTargetToInputs();

    _restTimer?.cancel();

    setState(() {
      _isResting = false;
      _isTimerPaused = false;
      _remainingSeconds = _restSeconds;
    });
  }

  Color _recoveryColor(RecoveryStatus? recovery) {
    if (recovery == null) {
      return AppColors.textSecondary;
    }

    switch (recovery.level) {
      case RecoveryLevel.low:
        return Colors.redAccent;
      case RecoveryLevel.moderate:
        return Colors.orangeAccent;
      case RecoveryLevel.good:
        return AppColors.success;
      case RecoveryLevel.excellent:
        return AppColors.success;
    }
  }

  Widget _buildRecoveryGuidanceCard(RecoveryStatus? recovery) {
    final color = _recoveryColor(recovery);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RECOVERY GUIDANCE',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  recovery == null
                      ? 'AWAITING RECOVERY LOG'
                      : '${recovery.label} • ${recovery.score}%',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  recovery?.trainingPlan ??
                      'Log today\'s sleep to receive training guidance.',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completionData = _completionData;

    if (completionData != null) {
      return WorkoutCompletionScreen(
        data: completionData,
        onDone: _closeWorkoutCompletion,
      );
    }

    final activeWorkout = SessionManager.activeWorkout;

    if (activeWorkout == null) {
      _preparedSessionId = null;
    } else if (_preparedSessionId != activeWorkout.sessionId) {
      _preparedSessionId = activeWorkout.sessionId;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        _currentExerciseIndex = 0;
        _loadWorkoutHistory();
        _applySuggestedTargetToInputs();

        setState(() {});
      });
    }

    final todaySleep = RecoveryStorageService.getSleepEntry(DateTime.now());

    final todayRecovery = todaySleep == null
        ? null
        : RecoveryService.calculateRecovery(todaySleep);

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

          if (activeWorkout != null) ...[
            const SizedBox(height: 16),
            _buildRecoveryGuidanceCard(todayRecovery),
          ],

          const SizedBox(height: 28),

          _buildExerciseHeader(),
          const SizedBox(height: 16),

          _buildPreviousPerformance(todayRecovery),
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

  List<WorkoutSet> _getPreviousExerciseSessionSets() {
    final activeWorkout = SessionManager.activeWorkout;

    if (activeWorkout == null) {
      return [];
    }

    final previousSets = WorkoutStorageService.getAllSets().where((set) {
      return set.exerciseName == _currentExerciseName &&
          set.sessionId != activeWorkout.sessionId;
    }).toList();

    if (previousSets.isEmpty) {
      return [];
    }

    final latestPreviousSet = previousSets.last;
    final previousSessionId = latestPreviousSet.sessionId;

    if (previousSessionId != null) {
      return previousSets.where((set) {
        return set.sessionId == previousSessionId;
      }).toList();
    }

    final previousDate = DateTime(
      latestPreviousSet.completedAt.year,
      latestPreviousSet.completedAt.month,
      latestPreviousSet.completedAt.day,
    );

    return previousSets.where((set) {
      final setDate = DateTime(
        set.completedAt.year,
        set.completedAt.month,
        set.completedAt.day,
      );

      return set.sessionId == null &&
          set.workoutName == latestPreviousSet.workoutName &&
          setDate == previousDate;
    }).toList();
  }

  WorkoutSet? _getPreviousBestSet(List<WorkoutSet> sets) {
    if (sets.isEmpty) {
      return null;
    }

    WorkoutSet bestSet = sets.first;

    for (final set in sets.skip(1)) {
      if (set.volume > bestSet.volume ||
          (set.volume == bestSet.volume && set.weight > bestSet.weight)) {
        bestSet = set;
      }
    }

    return bestSet;
  }

  bool _isPersonalRecord(WorkoutSet newSet, WorkoutSet? previousBest) {
    if (previousBest == null) {
      return false;
    }

    if (newSet.volume > previousBest.volume) {
      return true;
    }

    if (newSet.volume == previousBest.volume &&
        newSet.weight > previousBest.weight) {
      return true;
    }

    return false;
  }

  bool _isSameStoredWorkoutSession(WorkoutSet first, WorkoutSet second) {
    if (first.sessionId != null || second.sessionId != null) {
      return first.sessionId != null &&
          second.sessionId != null &&
          first.sessionId == second.sessionId;
    }

    return first.workoutName == second.workoutName &&
        first.completedAt.year == second.completedAt.year &&
        first.completedAt.month == second.completedAt.month &&
        first.completedAt.day == second.completedAt.day;
  }

  bool _isHistoricalPersonalRecord(WorkoutSet targetSet) {
    final allSets = WorkoutStorageService.getAllSets();

    final previousSets = allSets.where((set) {
      return set.exerciseName == targetSet.exerciseName &&
          set.completedAt.isBefore(targetSet.completedAt) &&
          !_isSameStoredWorkoutSession(set, targetSet);
    }).toList();

    if (previousSets.isEmpty) {
      return false;
    }

    final latestPreviousSet = previousSets.last;

    final previousSessionSets = previousSets.where((set) {
      return _isSameStoredWorkoutSession(set, latestPreviousSet);
    }).toList();

    if (previousSessionSets.isEmpty) {
      return false;
    }

    WorkoutSet previousBest = previousSessionSets.first;

    for (final set in previousSessionSets.skip(1)) {
      if (set.volume > previousBest.volume ||
          (set.volume == previousBest.volume &&
              set.weight > previousBest.weight)) {
        previousBest = set;
      }
    }

    if (targetSet.volume > previousBest.volume) {
      return true;
    }

    return targetSet.volume == previousBest.volume &&
        targetSet.weight > previousBest.weight;
  }

  ({double weight, int reps})? _getSuggestedInputTarget(
    WorkoutSet previousSet,
    RecoveryStatus? recovery,
  ) {
    if (recovery == null) {
      return (weight: previousSet.weight, reps: previousSet.reps);
    }

    switch (recovery.level) {
      case RecoveryLevel.low:
        return (
          weight: previousSet.weight * 0.9,
          reps: (previousSet.reps - 2).clamp(6, 10).toInt(),
        );

      case RecoveryLevel.moderate:
        return (
          weight: previousSet.weight,
          reps: previousSet.reps.clamp(6, 10).toInt(),
        );

      case RecoveryLevel.good:
      case RecoveryLevel.excellent:
        if (previousSet.reps >= 10) {
          return (
            weight: previousSet.weight + (previousSet.unit == 'kg' ? 1.0 : 2.5),
            reps: 8,
          );
        }

        return (
          weight: previousSet.weight,
          reps: (previousSet.reps + 1).clamp(1, 10).toInt(),
        );
    }
  }

  void _applySuggestedTargetToInputs() {
    final activeWorkout = SessionManager.activeWorkout;

    if (activeWorkout == null) {
      return;
    }

    final allSets = WorkoutStorageService.getAllSets();

    final currentSessionSets = allSets.where((set) {
      return set.sessionId == activeWorkout.sessionId &&
          set.exerciseName == _currentExerciseName;
    }).toList();

    if (currentSessionSets.isNotEmpty) {
      final latestSet = currentSessionSets.last;

      _usesKilograms = latestSet.unit == 'kg';
      _weightController.text = _formatNumber(latestSet.weight);
      _repsController.text = '${latestSet.reps}';
      return;
    }

    final previousSets = _getPreviousExerciseSessionSets();
    final bestSet = _getPreviousBestSet(previousSets);

    if (bestSet == null) {
      _usesKilograms = false;
      _weightController.text = '40';
      _repsController.text = '10';
      return;
    }

    final todaySleep = RecoveryStorageService.getSleepEntry(DateTime.now());

    final recovery = todaySleep == null
        ? null
        : RecoveryService.calculateRecovery(todaySleep);

    final target = _getSuggestedInputTarget(bestSet, recovery);

    if (target == null) {
      return;
    }

    _usesKilograms = bestSet.unit == 'kg';
    _weightController.text = _formatNumber(target.weight);
    _repsController.text = '${target.reps}';
  }

  String _buildPreviousTarget(
    WorkoutSet previousSet,
    RecoveryStatus? recovery,
  ) {
    if (recovery == null) {
      return 'Suggested target: '
          '${_formatNumber(previousSet.weight)} ${previousSet.unit} × '
          '${previousSet.reps} reps';
    }

    switch (recovery.level) {
      case RecoveryLevel.low:
        final reducedWeight = previousSet.weight * 0.9;
        final targetReps = (previousSet.reps - 2).clamp(6, 10);

        return 'Recovery target: '
            '${_formatNumber(reducedWeight)} ${previousSet.unit} × '
            '$targetReps reps';

      case RecoveryLevel.moderate:
        final targetReps = previousSet.reps.clamp(6, 10);

        return 'Light target: '
            '${_formatNumber(previousSet.weight)} ${previousSet.unit} × '
            '$targetReps reps';

      case RecoveryLevel.good:
      case RecoveryLevel.excellent:
        if (previousSet.reps >= 10) {
          final increase = previousSet.unit == 'kg' ? 1.0 : 2.5;

          final targetWeight = previousSet.weight + increase;

          return 'Suggested target: '
              '${_formatNumber(targetWeight)} ${previousSet.unit} × '
              '8–10 reps';
        }

        final targetReps = (previousSet.reps + 1).clamp(1, 10);

        return 'Suggested target: '
            '${_formatNumber(previousSet.weight)} ${previousSet.unit} × '
            '$targetReps reps';
    }
  }

  String _formatShortDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}';
  }

  Widget _buildPreviousSetRow(WorkoutSet set) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${set.setNumber}',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              '${_formatNumber(set.weight)} ${set.unit} × '
              '${set.reps} reps',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),

          Text(
            _formatNumber(set.volume),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviousPerformance(RecoveryStatus? recovery) {
    final previousSets = _getPreviousExerciseSessionSets();

    final bestSet = _getPreviousBestSet(previousSets);

    if (bestSet == null) {
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
              'No previous performance',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),

            SizedBox(height: 4),

            Text(
              'Complete this exercise to establish your baseline.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LAST SESSION',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '${bestSet.workoutName} • '
            '${_formatShortDate(bestSet.completedAt)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 16),

          const Text(
            'PREVIOUS SETS',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),

          const SizedBox(height: 10),

          ...previousSets.map(_buildPreviousSetRow),

          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BEST SET',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '${_formatNumber(bestSet.weight)} '
                  '${bestSet.unit} × '
                  '${bestSet.reps} reps',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Text(
            _buildPreviousTarget(bestSet, recovery),
            style: TextStyle(
              color: _recoveryColor(recovery),
              fontWeight: FontWeight.w600,
            ),
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
              builder: (_) =>
                  ExerciseGuideScreen(exerciseName: _currentExerciseName),
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
