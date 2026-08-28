import 'package:flutter/material.dart';
import 'package:secret_mission/features/training/models/active_workout.dart';
import 'package:secret_mission/features/training/services/session_manager.dart';
import 'package:secret_mission/features/recovery/services/recovery_service.dart';
import 'package:secret_mission/features/recovery/services/recovery_storage_service.dart';
import 'package:secret_mission/features/recovery/models/recovery_status.dart';
import 'package:secret_mission/app/app_theme.dart';

class WorkoutPickerScreen extends StatelessWidget {
  const WorkoutPickerScreen({super.key, required this.onWorkoutStarted});

  final VoidCallback onWorkoutStarted;

  Color _recoveryColor(RecoveryStatus? recovery) {
    if (recovery == null) {
      return Colors.grey;
    }

    switch (recovery.level) {
      case RecoveryLevel.low:
        return Colors.redAccent;
      case RecoveryLevel.moderate:
        return Colors.orangeAccent;
      case RecoveryLevel.good:
        return Colors.greenAccent;
      case RecoveryLevel.excellent:
        return Colors.greenAccent;
    }
  }

  String _recoveryBannerLabel(RecoveryStatus? recovery) {
    if (recovery == null) {
      return 'AWAITING RECOVERY LOG';
    }

    switch (recovery.level) {
      case RecoveryLevel.low:
        return 'RECOVERY PRIORITY';
      case RecoveryLevel.moderate:
        return 'TAKE IT EASY';
      case RecoveryLevel.good:
        return 'READY TO TRAIN';
      case RecoveryLevel.excellent:
        return 'MISSION READY';
    }
  }

  Widget _buildRecoveryBanner(RecoveryStatus? recovery) {
    final color = _recoveryColor(recovery);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.35)),
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
                Text(
                  recovery == null
                      ? _recoveryBannerLabel(recovery)
                      : '${_recoveryBannerLabel(recovery)} • ${recovery.score}%',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  recovery?.trainingPlan ??
                      'Log today\'s sleep to receive workout guidance.',
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

  void _startWorkout(BuildContext context, WorkoutType type) {
    SessionManager.startWorkout(type: type);

    onWorkoutStarted();

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final workoutTypes = WorkoutType.values;

    final todaySleep = RecoveryStorageService.getSleepEntry(DateTime.now());

    final todayRecovery = todaySleep == null
        ? null
        : RecoveryService.calculateRecovery(todaySleep);

    return Scaffold(
      appBar: AppBar(title: const Text('Choose Workout')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: _buildRecoveryBanner(todayRecovery),
          ),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              itemCount: workoutTypes.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final workoutType = workoutTypes[index];

                return Card(
                  child: ListTile(
                    title: Text(
                      workoutType.displayName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(_getWorkoutDescription(workoutType)),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 18,
                    ),
                    onTap: () {
                      _startWorkout(context, workoutType);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getWorkoutDescription(WorkoutType type) {
    switch (type) {
      case WorkoutType.push:
        return 'Chest, shoulders, and triceps';
      case WorkoutType.pull:
        return 'Back, rear delts, and biceps';
      case WorkoutType.legs:
        return 'Quads, hamstrings, glutes, and calves';
      case WorkoutType.upper:
        return 'Complete upper-body workout';
      case WorkoutType.lower:
        return 'Complete lower-body workout';
      case WorkoutType.fullBody:
        return 'Train the entire body';
      case WorkoutType.custom:
        return 'Create your own workout';
    }
  }
}
