import 'package:flutter/material.dart';
import 'package:secret_mission/app/app_theme.dart';
import 'package:secret_mission/features/recovery/models/recovery_status.dart';
import 'package:secret_mission/features/recovery/models/sleep_entry.dart';
import 'package:secret_mission/features/recovery/services/recovery_service.dart';
import 'package:secret_mission/features/recovery/services/recovery_storage_service.dart';

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({super.key});

  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  int _sleepMinutes = 465;
  int _sleepQuality = 4;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);

    final savedEntry = RecoveryStorageService.getSleepEntry(_selectedDate);

    if (savedEntry != null) {
      _sleepMinutes = savedEntry.sleepMinutes;
      _sleepQuality = savedEntry.quality;
    } else {
      _sleepMinutes = RecoveryStorageService.getSleepMinutes();
      _sleepQuality = RecoveryStorageService.getSleepQuality();
    }
  }

  void _loadSelectedDateSleep() {
    final savedEntry = RecoveryStorageService.getSleepEntry(_selectedDate);

    setState(() {
      if (savedEntry != null) {
        _sleepMinutes = savedEntry.sleepMinutes;
        _sleepQuality = savedEntry.quality;
      } else {
        _sleepMinutes = 465;
        _sleepQuality = 4;
      }
    });
  }

  Future<void> _saveSelectedDateSleep() async {
    await RecoveryStorageService.saveSleepEntry(
      SleepEntry(
        date: _selectedDate,
        sleepMinutes: _sleepMinutes,
        quality: _sleepQuality,
      ),
    );

    if (!mounted) return;

    setState(() {});
  }

  Future<void> _pickRecoveryDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _selectedDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
      );
    });

    _loadSelectedDateSleep();
  }

  void _showSleepQualityGuide() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SLEEP QUALITY GUIDE',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Choose the score that best describes your overall night of sleep.',
                  style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                ),

                const SizedBox(height: 20),

                _buildQualityGuideItem(
                  score: '1/5',
                  title: 'VERY POOR',
                  description:
                      'Very restless sleep, frequent awakenings, difficulty falling asleep, or waking exhausted.',
                ),

                _buildQualityGuideItem(
                  score: '2/5',
                  title: 'POOR',
                  description:
                      'Several interruptions or restless periods, with noticeable tiredness after waking.',
                ),

                _buildQualityGuideItem(
                  score: '3/5',
                  title: 'FAIR',
                  description:
                      'Acceptable sleep with some interruptions. You feel somewhat rested, but not fully recovered.',
                ),

                _buildQualityGuideItem(
                  score: '4/5',
                  title: 'GOOD',
                  description:
                      'Mostly uninterrupted sleep, reasonable sleep onset, and you wake feeling rested.',
                ),

                _buildQualityGuideItem(
                  score: '5/5',
                  title: 'EXCELLENT',
                  description:
                      'Very restful and largely uninterrupted sleep. You wake feeling refreshed and well recovered.',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQualityGuideItem({
    required String score,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              score,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
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
    final sleep = SleepEntry(
      date: DateTime.now(),
      sleepMinutes: _sleepMinutes,
      quality: _sleepQuality,
    );

    final recovery = RecoveryService.calculateRecovery(sleep);

    final sleepHistory = RecoveryStorageService.getAllSleepEntries();

    final weeklyEntries = RecoveryStorageService.getRecentSleepEntries(days: 7);

    final weeklyAverageSleepMinutes = weeklyEntries.isEmpty
        ? 0
        : weeklyEntries
                  .map((entry) => entry.sleepMinutes)
                  .reduce((a, b) => a + b) ~/
              weeklyEntries.length;

    final weeklyAverageQuality = weeklyEntries.isEmpty
        ? 0.0
        : weeklyEntries.map((entry) => entry.quality).reduce((a, b) => a + b) /
              weeklyEntries.length;

    final weeklyAverageRecovery = weeklyEntries.isEmpty
        ? 0
        : weeklyEntries
                  .map(
                    (entry) => RecoveryService.calculateRecovery(entry).score,
                  )
                  .reduce((a, b) => a + b) ~/
              weeklyEntries.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          const Text(
            'RECOVERY INTEL',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Recovery Status',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Track sleep and readiness before your next mission.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 24),

          InkWell(
            onTap: _pickRecoveryDate,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          _buildRecoveryCard(recovery),

          const SizedBox(height: 16),

          _buildWeeklyIntelCard(
            averageSleepMinutes: weeklyAverageSleepMinutes,
            averageQuality: weeklyAverageQuality,
            averageRecovery: weeklyAverageRecovery,
            entries: weeklyEntries,
          ),

          const SizedBox(height: 16),

          _buildSleepCard(sleep),

          const SizedBox(height: 16),

          _buildRecoveryHistory(sleepHistory),
        ],
      ),
    );
  }

  Widget _buildRecoveryCard(RecoveryStatus recovery) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          const Text(
            'READINESS SCORE',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${recovery.score}%',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 42,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            recovery.label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyIntelCard({
    required int averageSleepMinutes,
    required double averageQuality,
    required int averageRecovery,
    required List<SleepEntry> entries,
  }) {
    final hours = averageSleepMinutes ~/ 60;
    final minutes = averageSleepMinutes % 60;

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
            'WEEKLY RECOVERY INTEL',
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
                child: _buildWeeklyStat(
                  value: '${hours}h ${minutes}m',
                  label: 'AVG SLEEP',
                ),
              ),
              Expanded(
                child: _buildWeeklyStat(
                  value: averageQuality.toStringAsFixed(1),
                  label: 'AVG QUALITY',
                ),
              ),
              Expanded(
                child: _buildWeeklyStat(
                  value: '$averageRecovery%',
                  label: 'AVG RECOVERY',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          const Text(
            '7-DAY RECOVERY TREND',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),

          const SizedBox(height: 8),

          _buildRecoveryTrend(entries),
        ],
      ),
    );
  }

  Widget _buildRecoveryTrend(List<SleepEntry> entries) {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);

    final days = List.generate(7, (index) {
      final date = normalizedToday.subtract(Duration(days: 6 - index));

      SleepEntry? entry;

      for (final candidate in entries) {
        if (candidate.date.year == date.year &&
            candidate.date.month == date.month &&
            candidate.date.day == date.day) {
          entry = candidate;
          break;
        }
      }

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
        final barHeight = score == null ? 6.0 : 8.0 + (score / 100) * 38.0;

        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 48,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 8,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: score == null
                          ? AppColors.textSecondary.withValues(alpha: 0.18)
                          : AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                dayLabels[day.date.weekday - 1],
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeeklyStat({required String value, required String label}) {
    return Column(
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }

  Widget _buildSleepCard(SleepEntry sleep) {
    final hours = sleep.sleepMinutes ~/ 60;
    final minutes = sleep.sleepMinutes % 60;

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
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.bedtime_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LAST NIGHT',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${hours}h ${minutes}m',
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${sleep.quality}/5',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          const Text(
            'SLEEP DURATION',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),

          Slider(
            value: _sleepMinutes.toDouble(),
            min: 240,
            max: 600,
            divisions: 24,
            onChanged: (value) {
              setState(() {
                _sleepMinutes = value.round();
              });
            },
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'SLEEP QUALITY',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              IconButton(
                onPressed: _showSleepQualityGuide,
                tooltip: 'Sleep Quality Guide',
                icon: const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ],
          ),

          Slider(
            value: _sleepQuality.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            label: '$_sleepQuality/5',
            onChanged: (value) {
              setState(() {
                _sleepQuality = value.round();
              });
            },
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveSelectedDateSleep,
              icon: const Icon(Icons.save_rounded, size: 20),
              label: const Text(
                'SAVE SLEEP LOG',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryHistory(List<SleepEntry> entries) {
    if (entries.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: const Text(
          'No recovery history yet.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

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
            'RECOVERY HISTORY',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),

          const SizedBox(height: 16),

          ...entries.map((entry) {
            final recovery = RecoveryService.calculateRecovery(entry);

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = DateTime(
                    entry.date.year,
                    entry.date.month,
                    entry.date.day,
                  );
                  _sleepMinutes = entry.sleepMinutes;
                  _sleepQuality = entry.quality;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatRecoveryDate(entry.date),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${entry.sleepHours.toStringAsFixed(1)}h • ${entry.quality}/5',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${recovery.score}%',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textSecondary,
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ), // Row
              ), // Padding
            ); // GestureDetector
          }),
        ],
      ),
    );
  }

  String _formatRecoveryDate(DateTime date) {
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

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
