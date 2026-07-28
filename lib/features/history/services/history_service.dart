import 'package:secret_mission/features/history/models/workout_session.dart';
import 'package:secret_mission/features/training/models/workout_set.dart';
import 'package:secret_mission/features/training/services/workout_storage_service.dart';

class HistoryService {
  static List<WorkoutSession> getWorkoutHistory() {
    final allSets = WorkoutStorageService.getAllSets();

    if (allSets.isEmpty) {
      return [];
    }

    final Map<String, List<WorkoutSet>> groupedSessions = {};

    for (final set in allSets) {
      final sessionId = set.sessionId ?? 'legacy';

      groupedSessions.putIfAbsent(sessionId, () => []);
      groupedSessions[sessionId]!.add(set);
    }

    final sessions = groupedSessions.entries.map((entry) {
      final sets = [...entry.value];

      sets.sort(
        (a, b) => a.completedAt.compareTo(b.completedAt),
      );

      return WorkoutSession(
        sessionId: entry.key,
        startedAt: sets.first.completedAt,
        sets: sets,
      );
    }).toList();

    sessions.sort(
      (a, b) => b.startedAt.compareTo(a.startedAt),
    );

    return sessions;
  }
}