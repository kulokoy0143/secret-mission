import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:secret_mission/app/app_theme.dart';
import 'package:secret_mission/features/history/models/workout_session.dart';
import 'package:secret_mission/features/history/services/history_service.dart';
import 'package:secret_mission/features/training/models/workout_set.dart';
import 'package:secret_mission/features/recovery/services/recovery_service.dart';
import 'package:secret_mission/features/recovery/services/recovery_storage_service.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  late DateTime _focusedMonth;
  late DateTime _selectedDate;

  bool _isSelectedDateExpanded = false;

  final Set<String> _expandedSessionIds = {};

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ValueListenableBuilder<Box<WorkoutSet>>(
        valueListenable: Hive.box<WorkoutSet>('workout_sets').listenable(),
        builder: (context, box, child) {
          final sessions = HistoryService.getWorkoutHistory();
          final selectedSessions = _sessionsForDate(sessions, _selectedDate);
          final selectedRecoveryEntry = RecoveryStorageService.getSleepEntry(
            _selectedDate,
          );

          final selectedRecovery = selectedRecoveryEntry == null
              ? null
              : RecoveryService.calculateRecovery(selectedRecoveryEntry);
          final monthlySessions = sessions.where((session) {
            return session.startedAt.year == _focusedMonth.year &&
                session.startedAt.month == _focusedMonth.month;
          }).toList();

          final monthlyMissionCount = monthlySessions.length;

          final monthlyExerciseCount = monthlySessions.fold<int>(
            0,
            (total, session) => total + session.exerciseCount,
          );

          final monthlySetCount = monthlySessions.fold<int>(
            0,
            (total, session) => total + session.totalSets,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              _buildHeader(),
              const SizedBox(height: 24),

              _buildMonthlyIntelCard(
                missions: monthlyMissionCount,
                exercises: monthlyExerciseCount,
                sets: monthlySetCount,
              ),

              const SizedBox(height: 16),

              _buildCalendar(sessions),

              AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOut,
                child: _isSelectedDateExpanded
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          _buildSelectedDateHeader(selectedSessions.length),
                          const SizedBox(height: 12),

                          if (selectedRecoveryEntry != null &&
                              selectedRecovery != null) ...[
                            _buildRecoverySummaryCard(
                              date: _selectedDate,
                              sleepMinutes: selectedRecoveryEntry.sleepMinutes,
                              quality: selectedRecoveryEntry.quality,
                              recoveryScore: selectedRecovery.score,
                              recoveryLabel: selectedRecovery.label,
                            ),

                            const SizedBox(height: 16),
                          ],

                          if (selectedSessions.isEmpty)
                            _buildNoMissionsForDay()
                          else
                            ...selectedSessions.map(
                              (session) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildSessionCard(session),
                              ),
                            ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MISSION ARCHIVE',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.8,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Workout Calendar',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 6),
        Text(
          'Select a date to review your completed training missions.',
          style: TextStyle(color: AppColors.textSecondary, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildMonthlyIntelCard({
    required int missions,
    required int exercises,
    required int sets,
  }) {
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
            'MONTHLY MISSION INTEL',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _buildIntelStat(
                  value: missions.toString(),
                  label: 'MISSIONS',
                ),
              ),
              Expanded(
                child: _buildIntelStat(
                  value: exercises.toString(),
                  label: 'EXERCISES',
                ),
              ),
              Expanded(
                child: _buildIntelStat(value: sets.toString(), label: 'SETS'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIntelStat({required String value, required String label}) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar(List<WorkoutSession> sessions) {
    const weekdayLabels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

    final firstDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    );

    final daysInMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    ).day;

    final leadingEmptyCells = firstDayOfMonth.weekday - 1;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _showPreviousMonth,
                icon: const Icon(
                  Icons.chevron_left_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      _formatMonthYear(_focusedMonth),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    TextButton(
                      onPressed: _showToday,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'TODAY',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _showNextMonth,
                icon: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: weekdayLabels
                .map(
                  (label) => Expanded(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leadingEmptyCells + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              if (index < leadingEmptyCells) {
                return const SizedBox.shrink();
              }

              final day = index - leadingEmptyCells + 1;
              final date = DateTime(
                _focusedMonth.year,
                _focusedMonth.month,
                day,
              );

              return _buildCalendarDay(
                date: date,
                hasWorkout: _hasSessionsOnDate(sessions, date),
                hasRecovery: RecoveryStorageService.getSleepEntry(date) != null,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarDay({
    required DateTime date,
    required bool hasWorkout,
    required bool hasRecovery,
  }) {
    final isSelected = _isSameDay(date, _selectedDate);

    final now = DateTime.now();
    final isToday = _isSameDay(date, DateTime(now.year, now.month, now.day));

    return InkWell(
      onTap: () {
        setState(() {
          if (_isSameDay(date, _selectedDate)) {
            _isSelectedDateExpanded = !_isSelectedDateExpanded;
          } else {
            _selectedDate = date;
            _isSelectedDateExpanded = true;
          }
        });
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : hasWorkout
              ? AppColors.primary.withValues(alpha: 0.16)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isToday && !isSelected
                ? AppColors.primary.withValues(alpha: 0.55)
                : Colors.transparent,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                '${date.day}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: isSelected || isToday
                      ? FontWeight.w800
                      : FontWeight.w500,
                ),
              ),
            ),

            if (hasRecovery)
              Positioned(
                right: 5,
                bottom: 5,
                child: Icon(
                  Icons.bedtime_rounded,
                  size: 10,
                  color: isSelected ? Colors.white : AppColors.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDateHeader(int missionCount) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.calendar_today_rounded,
            color: AppColors.primary,
            size: 19,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SELECTED DATE',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _formatDate(_selectedDate),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),

              Text(
                missionCount == 1
                    ? '1 MISSION COMPLETED'
                    : '$missionCount MISSIONS COMPLETED',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecoverySummaryCard({
    required DateTime date,
    required int sleepMinutes,
    required int quality,
    required int recoveryScore,
    required String recoveryLabel,
  }) {
    final hours = sleepMinutes ~/ 60;
    final minutes = sleepMinutes % 60;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RECOVERY INTEL: $recoveryLabel',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _buildRecoveryStat(
                  label: 'Sleep',
                  value: '${hours}h ${minutes}m',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRecoveryStat(
                  label: 'Quality',
                  value: '$quality/5',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRecoveryStat(
                  label: 'Recovery',
                  value: '$recoveryScore%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          const Text(
            '7-DAY RECOVERY CONTEXT',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),

          const SizedBox(height: 6),

          _buildHistoryRecoveryTrend(date),
        ],
      ),
    );
  }

  Widget _buildHistoryRecoveryTrend(DateTime endDate) {
    final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day);

    final days = List.generate(7, (index) {
      final date = normalizedEnd.subtract(Duration(days: 6 - index));

      final entry = RecoveryStorageService.getSleepEntry(date);

      final score = entry == null
          ? null
          : RecoveryService.calculateRecovery(entry).score;

      return (date: date, score: score);
    });

    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: days.map((day) {
        final score = day.score;

        final barHeight = score == null ? 5.0 : 6.0 + (score / 100) * 28.0;

        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 36,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 6,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: score == null
                          ? AppColors.textSecondary.withValues(alpha: 0.18)
                          : AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dayLabels[day.date.weekday - 1],
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecoveryStat({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMissionsForDay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.nights_stay_outlined,
            color: AppColors.textSecondary,
            size: 34,
          ),
          SizedBox(height: 12),
          Text(
            'No Mission Recorded',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 6),
          Text(
            'No completed workout was recorded on this date.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(WorkoutSession session) {
    final exercises = session.setsByExercise;
    final isExpanded = _expandedSessionIds.contains(session.sessionId);

    return InkWell(
      onTap: () {
        setState(() {
          if (isExpanded) {
            _expandedSessionIds.remove(session.sessionId);
          } else {
            _expandedSessionIds.add(session.sessionId);
          }
        });
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.local_fire_department_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatSessionTitle(session),
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _formatTime(session.startedAt),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 280),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                    size: 26,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _buildStat(
                    label: 'Exercises',
                    value: '${session.exerciseCount}',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStat(
                    label: 'Sets',
                    value: '${session.totalSets}',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStat(
                    label: 'Volume',
                    value: _formatVolume(session),
                  ),
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              child: isExpanded
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const Divider(height: 1, color: AppColors.background),
                        const SizedBox(height: 16),

                        ...exercises.entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildExerciseSection(
                              exerciseName: entry.key,
                              sets: entry.value,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameStoredWorkoutSession(WorkoutSet first, WorkoutSet second) {
    if (first.sessionId != null || second.sessionId != null) {
      return first.sessionId != null &&
          second.sessionId != null &&
          first.sessionId == second.sessionId;
    }

    return first.workoutName == second.workoutName &&
        _isSameDay(first.completedAt, second.completedAt);
  }

  bool _isHistoricalPersonalRecord(WorkoutSet targetSet) {
    final allSets = Hive.box<WorkoutSet>('workout_sets').values.toList()
      ..sort(
        (first, second) => first.completedAt.compareTo(second.completedAt),
      );

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

  Widget _buildExerciseSection({
    required String exerciseName,
    required List<WorkoutSet> sets,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          exerciseName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),

        const SizedBox(height: 9),

        ...sets.map((set) {
          final isPersonalRecord = _isHistoricalPersonalRecord(set);

          return Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Row(
              children: [
                SizedBox(
                  width: 55,
                  child: Text(
                    'Set ${set.setNumber}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),

                Expanded(
                  child: Text(
                    '${_formatNumber(set.weight)} '
                    '${set.unit} × ${set.reps} reps',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                if (isPersonalRecord) ...[
                  const SizedBox(width: 6),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.45),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.emoji_events_rounded,
                          color: Colors.amber,
                          size: 13,
                        ),
                        SizedBox(width: 3),
                        Text(
                          'PR',
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 7),
                ],

                Text(
                  _formatTime(set.completedAt),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  List<WorkoutSession> _sessionsForDate(
    List<WorkoutSession> sessions,
    DateTime date,
  ) {
    return sessions
        .where((session) => _isSameDay(session.startedAt, date))
        .toList();
  }

  bool _hasSessionsOnDate(List<WorkoutSession> sessions, DateTime date) {
    return sessions.any((session) => _isSameDay(session.startedAt, date));
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  void _showToday() {
    final now = DateTime.now();

    setState(() {
      _focusedMonth = DateTime(now.year, now.month);
      _selectedDate = DateTime(now.year, now.month, now.day);
      _isSelectedDateExpanded = true;
      _expandedSessionIds.clear();
    });
  }

  void _showPreviousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);

      _selectedDate = DateTime(_focusedMonth.year, _focusedMonth.month, 1);

      _isSelectedDateExpanded = false;
      _expandedSessionIds.clear();
    });
  }

  void _showNextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);

      _selectedDate = DateTime(_focusedMonth.year, _focusedMonth.month, 1);

      _isSelectedDateExpanded = false;
      _expandedSessionIds.clear();
    });
  }

  String _formatSessionTitle(WorkoutSession session) {
    if (session.sessionId == 'legacy') {
      return 'Previous Workout';
    }

    return session.workoutName;
  }

  String _formatVolume(WorkoutSession session) {
    if (session.sets.isEmpty) {
      return '0';
    }

    final unit = session.sets.first.unit;

    return '${_formatNumber(session.totalVolume)} $unit';
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(1);
  }

  String _formatMonthYear(DateTime date) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${monthNames[date.month - 1]} ${date.year}';
  }

  String _formatDate(DateTime date) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour == 0
        ? 12
        : date.hour > 12
        ? date.hour - 12
        : date.hour;

    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }
}
