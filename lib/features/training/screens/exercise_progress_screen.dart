import 'package:flutter/material.dart';
import 'package:secret_mission/app/app_theme.dart';
import 'package:secret_mission/features/training/models/workout_set.dart';
import 'package:secret_mission/features/training/services/workout_storage_service.dart';

enum _ExerciseTrendMetric { load, volume }

class ExerciseProgressScreen extends StatefulWidget {
  const ExerciseProgressScreen({super.key, required this.exerciseName});

  final String exerciseName;

  @override
  State<ExerciseProgressScreen> createState() => _ExerciseProgressScreenState();
}

class _ExerciseProgressScreenState extends State<ExerciseProgressScreen> {
  _ExerciseTrendMetric _trendMetric = _ExerciseTrendMetric.volume;

  int? _selectedTrendPointIndex;

  String get exerciseName => widget.exerciseName;

  double _weightInKilograms(WorkoutSet set) {
    if (set.unit == 'kg') {
      return set.weight;
    }

    return set.weight / 2.20462;
  }

  double _weightInDisplayUnit(WorkoutSet set, String displayUnit) {
    if (set.unit == displayUnit) {
      return set.weight;
    }

    if (displayUnit == 'kg') {
      return set.weight / 2.20462;
    }

    return set.weight * 2.20462;
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

  void _selectTrendPoint({
    required double tapX,
    required double chartWidth,
    required int pointCount,
  }) {
    if (pointCount <= 0 || chartWidth <= 20) {
      return;
    }

    if (pointCount == 1) {
      setState(() {
        _selectedTrendPointIndex = 0;
      });
      return;
    }

    const horizontalPadding = 10.0;

    final usableWidth = chartWidth - horizontalPadding * 2;

    final normalizedX = ((tapX - horizontalPadding) / usableWidth).clamp(
      0.0,
      1.0,
    );

    final index = (normalizedX * (pointCount - 1)).round();

    setState(() {
      _selectedTrendPointIndex = index;
    });
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

        _buildPerformanceTrend(sessions),

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

  Widget _buildTrendMetricSelector() {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<_ExerciseTrendMetric>(
        segments: const [
          ButtonSegment<_ExerciseTrendMetric>(
            value: _ExerciseTrendMetric.load,
            label: Text(
              'LOAD',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ),
          ButtonSegment<_ExerciseTrendMetric>(
            value: _ExerciseTrendMetric.volume,
            label: Text(
              'VOLUME',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
        selected: {_trendMetric},
        showSelectedIcon: false,
        onSelectionChanged: (selection) {
          if (selection.isEmpty) {
            return;
          }

          setState(() {
            _trendMetric = selection.first;
            _selectedTrendPointIndex = null;
          });
        },
      ),
    );
  }

  Widget _buildPerformanceTrend(List<_ExerciseSessionSnapshot> sessions) {
    if (sessions.length < 2) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PERFORMANCE TREND',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),

            SizedBox(height: 12),

            Text(
              'More sessions are needed to generate a performance trend.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    final chartSessions = sessions.length > 10
        ? sessions.sublist(sessions.length - 10)
        : sessions;

    final displayUnit = chartSessions.last.bestSet.unit;

    final isLoadTrend = _trendMetric == _ExerciseTrendMetric.load;

    final values = chartSessions.map((session) {
      final load = _weightInDisplayUnit(session.bestSet, displayUnit);

      if (isLoadTrend) {
        return load;
      }

      return load * session.bestSet.reps;
    }).toList();

    final firstValue = values.first;
    final latestValue = values.last;

    final trendChange = _percentChange(latestValue, firstValue);

    final trendLabel = isLoadTrend ? 'Best-set load' : 'Best-set volume';

    final selectedIndex = _selectedTrendPointIndex;

    final selectedSession =
        selectedIndex != null &&
            selectedIndex >= 0 &&
            selectedIndex < chartSessions.length
        ? chartSessions[selectedIndex]
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PERFORMANCE TREND',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 5),

          Row(
            children: [
              Expanded(
                child: Text(
                  isLoadTrend
                      ? 'Best-set load ($displayUnit)'
                      : 'Best-set volume ($displayUnit × reps)',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),

              Text(
                _formatPercent(trendChange),
                style: TextStyle(
                  color: _trendColor(trendChange),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          _buildTrendMetricSelector(),

          const SizedBox(height: 20),

          SizedBox(
            height: 180,
            width: double.infinity,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) {
                    _selectTrendPoint(
                      tapX: details.localPosition.dx,
                      chartWidth: constraints.maxWidth,
                      pointCount: values.length,
                    );
                  },
                  child: CustomPaint(
                    painter: _ExerciseTrendPainter(
                      values: values,
                      lineColor: AppColors.primary,
                      gridColor: AppColors.textSecondary.withValues(
                        alpha: 0.12,
                      ),
                      selectedIndex: _selectedTrendPointIndex,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          if (selectedSession != null) ...[
            _buildSelectedTrendSession(
              session: selectedSession,
              displayUnit: displayUnit,
            ),

            const SizedBox(height: 12),
          ] else ...[
            const Center(
              child: Text(
                'Tap a chart point to inspect that session.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
              ),
            ),

            const SizedBox(height: 10),
          ],

          Row(
            children: [
              Expanded(
                child: Text(
                  _formatShortDate(chartSessions.first.date),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              Text(
                sessions.length > 10
                    ? 'Latest 10 sessions'
                    : '${chartSessions.length} sessions',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                ),
              ),

              Expanded(
                child: Text(
                  _formatShortDate(chartSessions.last.date),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            trendChange > 5
                ? '$trendLabel has increased '
                      '${trendChange.toStringAsFixed(1)}% '
                      'across this trend.'
                : trendChange < -5
                ? '$trendLabel is '
                      '${trendChange.abs().toStringAsFixed(1)}% '
                      'below the start of this trend.'
                : '$trendLabel has remained relatively stable.',
            style: TextStyle(
              color: _trendColor(trendChange),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedTrendSession({
    required _ExerciseSessionSnapshot session,
    required String displayUnit,
  }) {
    final displayLoad = _weightInDisplayUnit(session.bestSet, displayUnit);

    final displayVolume = displayLoad * session.bestSet.reps;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SESSION INTEL',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            '${_formatShortDate(session.date)}'
            ' • ${session.workoutName}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 4),

          Text(
            'Best set: ${_formatSet(session.bestSet)}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildTrendSessionStat(
                  label: 'LOAD',
                  value:
                      '${_formatNumber(displayLoad)} '
                      '$displayUnit',
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _buildTrendSessionStat(
                  label: 'VOLUME',
                  value:
                      '${_formatNumber(displayVolume)} '
                      '$displayUnit',
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: _buildTrendSessionStat(
                  label: 'REPS',
                  value: '${session.bestSet.reps}',
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _buildTrendSessionStat(
                  label: 'SETS',
                  value: '${session.setCount}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendSessionStat({
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 3),

          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 8,
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

class _ExerciseTrendPainter extends CustomPainter {
  const _ExerciseTrendPainter({
    required this.values,
    required this.lineColor,
    required this.gridColor,
    required this.selectedIndex,
  });

  final List<double> values;
  final Color lineColor;
  final Color gridColor;
  final int? selectedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) {
      return;
    }

    const horizontalPadding = 10.0;
    const verticalPadding = 12.0;

    final chartWidth = size.width - horizontalPadding * 2;

    final chartHeight = size.height - verticalPadding * 2;

    double minValue = values.first;
    double maxValue = values.first;

    for (final value in values.skip(1)) {
      if (value < minValue) {
        minValue = value;
      }

      if (value > maxValue) {
        maxValue = value;
      }
    }

    var range = maxValue - minValue;

    if (range.abs() < 0.0001) {
      range = maxValue.abs() > 0.0001 ? maxValue.abs() * 0.10 : 1;
    }

    final chartMin = minValue - range * 0.12;

    final chartMax = maxValue + range * 0.12;

    final chartRange = chartMax - chartMin;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (var index = 0; index < 4; index++) {
      final y = verticalPadding + chartHeight * (index / 3);

      canvas.drawLine(
        Offset(horizontalPadding, y),
        Offset(size.width - horizontalPadding, y),
        gridPaint,
      );
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final pointFillPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    final pointBorderPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.28)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    final selectedHaloPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;

    final selectedPointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final selectedCenterPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    final points = <Offset>[];

    for (var index = 0; index < values.length; index++) {
      final x = values.length == 1
          ? size.width / 2
          : horizontalPadding + chartWidth * (index / (values.length - 1));

      final normalized = (values[index] - chartMin) / chartRange;

      final y = verticalPadding + chartHeight * (1 - normalized);

      points.add(Offset(x, y));
    }

    if (points.length > 1) {
      final linePath = Path()..moveTo(points.first.dx, points.first.dy);

      for (final point in points.skip(1)) {
        linePath.lineTo(point.dx, point.dy);
      }

      canvas.drawPath(linePath, linePaint);

      final fillPath = Path()
        ..moveTo(points.first.dx, size.height - verticalPadding)
        ..lineTo(points.first.dx, points.first.dy);

      for (final point in points.skip(1)) {
        fillPath.lineTo(point.dx, point.dy);
      }

      fillPath
        ..lineTo(points.last.dx, size.height - verticalPadding)
        ..close();

      canvas.drawPath(fillPath, fillPaint);

      canvas.drawPath(linePath, linePaint);
    }

    for (var index = 0; index < points.length; index++) {
      final point = points[index];

      final isSelected = selectedIndex == index;

      if (isSelected) {
        canvas.drawCircle(point, 11, selectedHaloPaint);

        canvas.drawCircle(point, 7, selectedPointPaint);

        canvas.drawCircle(point, 4, selectedCenterPaint);
      } else {
        canvas.drawCircle(point, 6, pointBorderPaint);

        canvas.drawCircle(point, 4, pointFillPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ExerciseTrendPainter oldDelegate) {
    if (oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.values.length != values.length) {
      return true;
    }

    for (var index = 0; index < values.length; index++) {
      if (oldDelegate.values[index] != values[index]) {
        return true;
      }
    }

    return false;
  }
}
