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

  @override
  void initState() {
    super.initState();

    final today = DateTime.now();
    final savedEntry = RecoveryStorageService.getSleepEntry(today);

    if (savedEntry != null) {
      _sleepMinutes = savedEntry.sleepMinutes;
      _sleepQuality = savedEntry.quality;
    } else {
      _sleepMinutes = RecoveryStorageService.getSleepMinutes();
      _sleepQuality = RecoveryStorageService.getSleepQuality();
    }
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

          _buildRecoveryCard(recovery),

          const SizedBox(height: 16),

          _buildWeeklyIntelCard(
            averageSleepMinutes: weeklyAverageSleepMinutes,
            averageQuality: weeklyAverageQuality,
            averageRecovery: weeklyAverageRecovery,
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
        ],
      ),
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

              RecoveryStorageService.saveSleepEntry(
                SleepEntry(
                  date: DateTime.now(),
                  sleepMinutes: _sleepMinutes,
                  quality: _sleepQuality,
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          const Text(
            'SLEEP QUALITY',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
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

              RecoveryStorageService.saveSleepEntry(
                SleepEntry(
                  date: DateTime.now(),
                  sleepMinutes: _sleepMinutes,
                  quality: _sleepQuality,
                ),
              );
            },
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

            return Padding(
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

                  Text(
                    '${recovery.score}%',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            );
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
