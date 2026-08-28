import 'package:flutter/material.dart';
import 'package:secret_mission/app/app_theme.dart';
import 'package:secret_mission/features/training/screens/training_screen.dart';
import 'package:secret_mission/features/history/screens/workout_history_screen.dart';
import 'package:secret_mission/features/training/screens/workout_picker_screen.dart';
import 'package:secret_mission/features/recovery/screens/recovery_screen.dart';
import 'package:secret_mission/features/recovery/services/recovery_service.dart';
import 'package:secret_mission/features/recovery/services/recovery_storage_service.dart';
import 'package:secret_mission/features/recovery/models/recovery_status.dart';
import 'package:secret_mission/features/training/services/workout_storage_service.dart';
import 'package:secret_mission/features/training/services/session_manager.dart';
import 'package:secret_mission/features/training/models/active_workout.dart';

class CommandCenterScreen extends StatefulWidget {
  const CommandCenterScreen({super.key});

  @override
  State<CommandCenterScreen> createState() => _CommandCenterScreenState();
}

class _CommandCenterScreenState extends State<CommandCenterScreen> {
  int _selectedIndex = 0;

  void _openWorkoutPicker() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkoutPickerScreen(
          onWorkoutStarted: () {
            setState(() {
              _selectedIndex = 1;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildDashboard(),
            TrainingScreen(
              onWorkoutFinished: () {
                setState(() {
                  _selectedIndex = 0;
                });
              },
            ),
            const WorkoutHistoryScreen(),
            const RecoveryScreen(),
            _buildPlaceholder('Agent File'),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.22),
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Training',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.bedtime_outlined),
            selectedIcon: Icon(Icons.bedtime_rounded),
            label: 'Recovery',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Agent',
          ),
        ],
      ),
    );
  }

  Color _missionStatusColor(RecoveryStatus? recovery) {
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

  WorkoutType? _suggestNextWorkoutType(String? lastWorkoutName) {
    switch (lastWorkoutName) {
      case 'Push Day':
        return WorkoutType.pull;
      case 'Pull Day':
        return WorkoutType.legs;
      case 'Leg Day':
        return WorkoutType.push;
      case 'Upper Body':
        return WorkoutType.lower;
      case 'Lower Body':
        return WorkoutType.upper;
      case 'Full Body':
        return WorkoutType.fullBody;
      default:
        return null;
    }
  }

  Widget _buildDashboard() {
    final todaySleep = RecoveryStorageService.getSleepEntry(DateTime.now());

    final todayRecovery = todaySleep == null
        ? null
        : RecoveryService.calculateRecovery(todaySleep);

    final workoutStreak = WorkoutStorageService.getCurrentWorkoutStreak();

    final activeWorkout = SessionManager.activeWorkout;

    final activeWorkoutFocus = activeWorkout?.type.muscleFocus;

    final lastCompletedWorkoutName =
        WorkoutStorageService.getLastCompletedWorkoutName();
    final suggestedWorkoutType = activeWorkout == null
        ? _suggestNextWorkoutType(lastCompletedWorkoutName)
        : null;

    final suggestedWorkoutName = suggestedWorkoutType?.displayName;
    final suggestedWorkoutFocus = suggestedWorkoutType?.muscleFocus;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WELCOME BACK,',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.8,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Agent Rogelio',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_none_rounded),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Icon(
                Icons.circle,
                color: _missionStatusColor(todayRecovery),
                size: 9,
              ),
              const SizedBox(width: 8),
              Text(
                todayRecovery == null
                    ? 'MISSION STATUS: AWAITING RECOVERY LOG'
                    : 'MISSION STATUS: ${todayRecovery.label}',
                style: TextStyle(
                  color: _missionStatusColor(todayRecovery),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          _buildMissionCard(
            todayRecovery,
            activeWorkout?.name,
            activeWorkoutFocus,
            lastCompletedWorkoutName,
            suggestedWorkoutName,
            suggestedWorkoutFocus,
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.bedtime_outlined,
                  title: 'Recovery',
                  value: todayRecovery == null
                      ? '--'
                      : '${todayRecovery.score}%',
                  subtitle: todayRecovery == null
                      ? 'No log today'
                      : todayRecovery.label,
                  subtitleColor: _missionStatusColor(todayRecovery),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.local_fire_department_outlined,
                  title: 'Streak',
                  value: '$workoutStreak',
                  subtitle: workoutStreak == 0
                      ? 'Start a streak'
                      : workoutStreak == 1
                      ? 'Day'
                      : 'Days',
                  iconColor: workoutStreak > 0
                      ? Colors.orangeAccent
                      : AppColors.textSecondary,
                  subtitleColor: workoutStreak > 0
                      ? Colors.orangeAccent
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildCommanderCard(
            todayRecovery?.trainingGuidance ??
                'Log today\'s sleep to receive recovery guidance.',
          ),
        ],
      ),
    );
  }

  String _missionBadgeLabel(RecoveryStatus? recovery) {
    if (recovery == null) {
      return 'AWAITING RECOVERY';
    }

    switch (recovery.level) {
      case RecoveryLevel.low:
        return 'RECOVERY PRIORITY';
      case RecoveryLevel.moderate:
        return 'CAUTION';
      case RecoveryLevel.good:
        return 'READY';
      case RecoveryLevel.excellent:
        return 'MISSION READY';
    }
  }

  Widget _buildMissionCard(
    RecoveryStatus? recovery,
    String? workoutName,
    String? workoutFocus,
    String? lastCompletedWorkoutName,
    String? suggestedWorkoutName,
    String? suggestedWorkoutFocus,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C4DFF), Color(0xFF5E35B1)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "TODAY'S MISSION",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _missionStatusColor(recovery).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _missionStatusColor(
                      recovery,
                    ).withValues(alpha: 0.55),
                  ),
                ),
                child: Text(
                  _missionBadgeLabel(recovery),
                  style: TextStyle(
                    color: _missionStatusColor(recovery),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            workoutName ??
                (suggestedWorkoutName != null
                    ? 'Suggested: $suggestedWorkoutName'
                    : lastCompletedWorkoutName == null
                    ? 'Choose Your Mission'
                    : 'Last Mission: $lastCompletedWorkoutName'),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 6),

          Text(
            workoutFocus ??
                suggestedWorkoutFocus ??
                (lastCompletedWorkoutName == null
                    ? 'Choose a workout to see its muscle focus.'
                    : 'Choose your next training mission.'),
            style: const TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 24),

          FilledButton.icon(
            onPressed: workoutName == null
                ? _openWorkoutPicker
                : () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
            ),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(
              workoutName == null ? 'START WORKOUT' : 'RESUME WORKOUT',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    Color? subtitleColor,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor ?? AppColors.primary),

          const SizedBox(height: 18),

          Text(title, style: const TextStyle(color: AppColors.textSecondary)),

          const SizedBox(height: 4),

          Text(
            value,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),

          Text(
            subtitle,
            style: TextStyle(
              color: subtitleColor ?? AppColors.success,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommanderCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Icon(Icons.smart_toy_rounded, color: Colors.white),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'COMMANDER',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  message,
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

  Widget _buildPlaceholder(String title) {
    return Center(
      child: Text(
        '$title\nComing soon',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 22,
          height: 1.5,
        ),
      ),
    );
  }
}
