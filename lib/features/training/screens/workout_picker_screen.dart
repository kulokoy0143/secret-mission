import 'package:flutter/material.dart';
import 'package:secret_mission/features/training/models/active_workout.dart';
import 'package:secret_mission/features/training/services/session_manager.dart';

class WorkoutPickerScreen extends StatelessWidget {
  const WorkoutPickerScreen({
    super.key,
    required this.onWorkoutStarted,
  });

  final VoidCallback onWorkoutStarted;

  void _startWorkout(
    BuildContext context,
    WorkoutType type,
  ) {
    SessionManager.startWorkout(type: type);

    onWorkoutStarted();

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final workoutTypes = WorkoutType.values;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Workout'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: workoutTypes.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final workoutType = workoutTypes[index];

          return Card(
            child: ListTile(
              title: Text(
                workoutType.displayName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                _getWorkoutDescription(workoutType),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
              ),
              onTap: () {
                _startWorkout(
                  context,
                  workoutType,
                );
              },
            ),
          );
        },
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