import 'package:flutter/material.dart';
import 'package:secret_mission/app/app_theme.dart';
import 'package:secret_mission/features/training/models/workout_set.dart';
import 'package:secret_mission/features/training/services/workout_storage_service.dart';

class ExerciseProgressScreen extends StatelessWidget {
  const ExerciseProgressScreen({super.key, required this.exerciseName});

  final String exerciseName;

  double _weightInKilograms(WorkoutSet set) {
    if (set.unit == 'kg') {
      return set.weight;
    }

    return set.weight / 2.20462;
  }

  double _normalizedSetVolume(WorkoutSet set) {
    return _weightInKilograms(set) * set.reps;
  }

  WorkoutSet _getBestSet(List<WorkoutSet> sets) {
    WorkoutSet bestSet = sets.first;

    for (final set in sets.skip(1)) {
      final setVolume = _normalizedSetVolume(set);
      final bestVolume = _normalizedSetVolume(bestSet);

      final volumeDifference = setVolume - bestVolume;

      if (volumeDifference > 0.0001 ||
          (volumeDifference.abs() <= 0.0001 &&
              _weightInKilograms(set) > _weightInKilograms(bestSet))) {
        bestSet = set;
      }
    }

    return bestSet;
  }

  List<_ExerciseSessionSnapshot> _buildSessions(List<WorkoutSet> sets) {
    if (sets.isEmpty) {
      return [];
    }

    final groupedSets = <String, List<WorkoutSet>>{};

    for (final set in sets) {
      final sessionId = set.sessionId;

      final normalizedDate = DateTime(
        set.completedAt.year,
        set.completedAt.month,
        set.completedAt.day,
      );

      final key = sessionId != null
          ? 'session:$sessionId'
          : 'legacy:${set.workoutName}:'
                '${normalizedDate.year}-'
                '${normalizedDate.month}-'
                '${normalizedDate.day}';

      groupedSets.putIfAbsent(key, () => []);

      groupedSets[key]!.add(set);
    }

    final sessions = <_ExerciseSessionSnapshot>[];

    for (final sessionSets in groupedSets.values) {
      sessionSets.sort(
        (first, second) => first.completedAt.compareTo(second.completedAt),
      );

      final bestSet = _getBestSet(sessionSets);

      sessions.add(
        _ExerciseSessionSnapshot(
          date: sessionSets.last.completedAt,
          workoutName: sessionSets.last.workoutName,
          setCount: sessionSets.length,
          bestSet: bestSet,
        ),
      );
    }

    sessions.sort((first, second) => first.date.compareTo(second.date));

    return sessions;
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(1);
  }

  String _formatSet(WorkoutSet set) {
    return '${_formatNumber(set.weight)} '
        '${set.unit} × '
        '${set.reps} reps';
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

  String _formatPercent(double value) {
    final prefix = value > 0 ? '+' : '';

    return '$prefix${value.toStringAsFixed(1)}%';
  }

  double _percentChange(double current, double previous) {
    if (previous == 0) {
      return 0;
    }

    return ((current - previous) / previous) * 100;
  }

  Color _trendColor(double value) {
    if (value > 5) {
      return AppColors.success;
    }

    if (value < -5) {
      return Colors.orangeAccent;
    }

    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final exerciseSets = WorkoutStorageService.getExerciseSets(exerciseName);

    final sessions = _buildSessions(exerciseSets);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Exercise Intel',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'EXERCISE PROGRESS',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              exerciseName,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 5),

            const Text(
              'Long-term best-set performance history.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),

            const SizedBox(height: 24),

            if (sessions.isEmpty)
              _buildEmptyState()
            else
              _buildProgressContent(
                sessions: sessions,
                exerciseSets: exerciseSets,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.query_stats_rounded,
            color: AppColors.textSecondary,
            size: 34,
          ),

          SizedBox(height: 12),

          Text(
            'No Performance Data Yet',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),

          SizedBox(height: 5),

          Text(
            'Save a set for this exercise to establish your progression baseline.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressContent({
    required List<_ExerciseSessionSnapshot> sessions,
    required List<WorkoutSet> exerciseSets,
  }) {
    final firstSession = sessions.first;
    final latestSession = sessions.last;

    final firstBest = firstSession.bestSet;

    final latestBest = latestSession.bestSet;

    final loadChange = _percentChange(
      _weightInKilograms(latestBest),
      _weightInKilograms(firstBest),
    );

    final volumeChange = _percentChange(
      _normalizedSetVolume(latestBest),
      _normalizedSetVolume(firstBest),
    );

    WorkoutSet peakLoadSet = exerciseSets.first;

    for (final set in exerciseSets.skip(1)) {
      if (_weightInKilograms(set) > _weightInKilograms(peakLoadSet)) {
        peakLoadSet = set;
      }
    }

    var allTimeBestSession = sessions.first;

    for (final session in sessions.skip(1)) {
      if (_normalizedSetVolume(session.bestSet) >
          _normalizedSetVolume(allTimeBestSession.bestSet)) {
        allTimeBestSession = session;
      }
    }

    final recentSessions = sessions.reversed.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLatestBestCard(latestSession),

        const SizedBox(height: 16),

        _buildProgressOverview(
          sessionCount: sessions.length,
          loadChange: loadChange,
          volumeChange: volumeChange,
          peakLoadSet: peakLoadSet,
          hasComparison: sessions.length > 1,
        ),

        const SizedBox(height: 16),

        _buildRecentPerformance(
          recentSessions: recentSessions,
          totalSessions: sessions.length,
          allTimeBestSession: allTimeBestSession,
        ),
      ],
    );
  }

  Widget _buildLatestBestCard(_ExerciseSessionSnapshot session) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.bolt_rounded, color: AppColors.primary),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LATEST BEST',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  _formatSet(session.bestSet),
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${_formatShortDate(session.date)}'
                  ' • ${session.workoutName}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressOverview({
    required int sessionCount,
    required double loadChange,
    required double volumeChange,
    required WorkoutSet peakLoadSet,
    required bool hasComparison,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PROGRESS OVERVIEW',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildOverviewStat(
                  label: 'SESSIONS',
                  value: '$sessionCount',
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _buildOverviewStat(
                  label: 'LOAD TREND',
                  value: hasComparison
                      ? _formatPercent(loadChange)
                      : 'BASELINE',
                  valueColor: hasComparison
                      ? _trendColor(loadChange)
                      : AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: _buildOverviewStat(
                  label: 'VOLUME TREND',
                  value: hasComparison
                      ? _formatPercent(volumeChange)
                      : 'BASELINE',
                  valueColor: hasComparison
                      ? _trendColor(volumeChange)
                      : AppColors.primary,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _buildOverviewStat(
                  label: 'PEAK LOAD',
                  value:
                      '${_formatNumber(peakLoadSet.weight)} '
                      '${peakLoadSet.unit}',
                ),
              ),
            ],
          ),

          if (hasComparison) ...[
            const SizedBox(height: 12),

            const Text(
              'Trend compares your latest best set with your first recorded best set.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOverviewStat({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPerformance({
    required List<_ExerciseSessionSnapshot> recentSessions,
    required int totalSessions,
    required _ExerciseSessionSnapshot allTimeBestSession,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RECENT PERFORMANCE',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            totalSessions > 10
                ? 'Latest 10 of $totalSessions sessions'
                : '$totalSessions recorded '
                      '${totalSessions == 1 ? 'session' : 'sessions'}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 16),

          ...recentSessions.map((session) {
            final isAllTimeBest = identical(session, allTimeBestSession);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildSessionRow(
                session: session,
                isAllTimeBest: isAllTimeBest,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSessionRow({
    required _ExerciseSessionSnapshot session,
    required bool isAllTimeBest,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(
              _formatShortDate(session.date),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatSet(session.bestSet),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  '${session.workoutName} • '
                  '${session.setCount} '
                  '${session.setCount == 1 ? 'set' : 'sets'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          if (isAllTimeBest) ...[
            const SizedBox(width: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.40)),
              ),
              child: const Text(
                'BEST',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExerciseSessionSnapshot {
  const _ExerciseSessionSnapshot({
    required this.date,
    required this.workoutName,
    required this.setCount,
    required this.bestSet,
  });

  final DateTime date;
  final String workoutName;
  final int setCount;
  final WorkoutSet bestSet;
}
