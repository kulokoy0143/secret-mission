import 'package:flutter/material.dart';
import 'package:secret_mission/app/app_theme.dart';
import 'package:secret_mission/features/recovery/models/recovery_status.dart';

class WorkoutCompletionPr {
  const WorkoutCompletionPr({
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.unit,
  });

  final String exerciseName;
  final double weight;
  final int reps;
  final String unit;
}

class WorkoutComparisonData {
  const WorkoutComparisonData({
    required this.previousDate,
    required this.previousSetCount,
    required this.previousVolumeText,
    required this.setDifference,
    required this.volumeChangePercent,
  });

  final DateTime previousDate;
  final int previousSetCount;
  final String previousVolumeText;
  final int setDifference;
  final double volumeChangePercent;
}

class WorkoutCompletionData {
  const WorkoutCompletionData({
    required this.workoutName,
    required this.duration,
    required this.exerciseCount,
    required this.setCount,
    required this.volumeText,
    required this.personalRecordCount,
    required this.personalRecords,
    required this.comparison,
    required this.recovery,
  });

  final String workoutName;
  final Duration duration;
  final int exerciseCount;
  final int setCount;
  final String volumeText;
  final int personalRecordCount;
  final List<WorkoutCompletionPr> personalRecords;
  final WorkoutComparisonData? comparison;
  final RecoveryStatus? recovery;
}

class WorkoutCompletionScreen extends StatelessWidget {
  const WorkoutCompletionScreen({
    super.key,
    required this.data,
    required this.onDone,
  });

  final WorkoutCompletionData data;
  final VoidCallback onDone;

  Color _recoveryColor() {
    final recovery = data.recovery;

    if (recovery == null) {
      return AppColors.textSecondary;
    }

    switch (recovery.level) {
      case RecoveryLevel.low:
        return Colors.redAccent;
      case RecoveryLevel.moderate:
        return Colors.orangeAccent;
      case RecoveryLevel.good:
      case RecoveryLevel.excellent:
        return AppColors.success;
    }
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(1);
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

  String _formatChange(int value) {
    if (value > 0) {
      return '+$value';
    }

    return '$value';
  }

  String _formatPercentChange(double value) {
    final prefix = value > 0 ? '+' : '';

    return '$prefix${value.toStringAsFixed(1)}%';
  }

  String _performanceVerdictLabel() {
    final comparison = data.comparison;

    if (comparison == null) {
      return 'BASELINE ESTABLISHED';
    }

    final volumeChange = comparison.volumeChangePercent;

    if (volumeChange >= 5) {
      return 'PROGRESSED';
    }

    if (volumeChange <= -5) {
      final recovery = data.recovery;

      if (recovery?.level == RecoveryLevel.low ||
          recovery?.level == RecoveryLevel.moderate) {
        return 'RECOVERY SESSION';
      }

      return 'LOWER VOLUME';
    }

    return 'MAINTAINED';
  }

  String _performanceVerdictMessage() {
    final comparison = data.comparison;

    if (comparison == null) {
      return 'Your first recorded ${data.workoutName} '
          'is now ready for future comparison.';
    }

    final volumeChange = comparison.volumeChangePercent;

    if (volumeChange >= 5) {
      return 'Training volume increased '
          '${volumeChange.toStringAsFixed(1)}% '
          'from your previous ${data.workoutName}.';
    }

    if (volumeChange <= -5) {
      final recovery = data.recovery;

      if (recovery?.level == RecoveryLevel.low ||
          recovery?.level == RecoveryLevel.moderate) {
        return 'Lower workload was completed during '
            'a reduced-recovery day.';
      }

      return 'Training volume was '
          '${volumeChange.abs().toStringAsFixed(1)}% '
          'lower than your previous ${data.workoutName}.';
    }

    return 'Performance stayed within range of '
        'your previous ${data.workoutName}.';
  }

  Color _performanceVerdictColor() {
    switch (_performanceVerdictLabel()) {
      case 'PROGRESSED':
        return AppColors.success;

      case 'RECOVERY SESSION':
        return Colors.orangeAccent;

      case 'LOWER VOLUME':
        return Colors.orangeAccent;

      case 'BASELINE ESTABLISHED':
        return AppColors.primary;

      case 'MAINTAINED':
      default:
        return AppColors.primary;
    }
  }

  IconData _performanceVerdictIcon() {
    switch (_performanceVerdictLabel()) {
      case 'PROGRESSED':
        return Icons.trending_up_rounded;

      case 'RECOVERY SESSION':
        return Icons.bedtime_rounded;

      case 'LOWER VOLUME':
        return Icons.trending_down_rounded;

      case 'BASELINE ESTABLISHED':
        return Icons.flag_rounded;

      case 'MAINTAINED':
      default:
        return Icons.trending_flat_rounded;
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }

    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }

    return '${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.flag_rounded,
                color: AppColors.success,
                size: 38,
              ),
            ),
          ),

          const SizedBox(height: 18),

          const Center(
            child: Text(
              'MISSION ACCOMPLISHED',
              style: TextStyle(
                color: AppColors.success,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.6,
              ),
            ),
          ),

          const SizedBox(height: 7),

          Center(
            child: Text(
              data.workoutName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
            ),
          ),

          const SizedBox(height: 8),

          Center(
            child: Text(
              'Mission debrief and training performance',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),

          const SizedBox(height: 22),

          _buildPerformanceVerdict(),

          const SizedBox(height: 16),

          Container(
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
                  'MISSION SUMMARY',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: _buildStat(
                        icon: Icons.timer_outlined,
                        label: 'Duration',
                        value: _formatDuration(data.duration),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStat(
                        icon: Icons.fitness_center_rounded,
                        label: 'Exercises',
                        value: '${data.exerciseCount}',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: _buildStat(
                        icon: Icons.format_list_numbered_rounded,
                        label: 'Sets',
                        value: '${data.setCount}',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStat(
                        icon: Icons.monitor_weight_outlined,
                        label: 'Volume',
                        value: data.volumeText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.20)),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.amber,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PERSONAL RECORDS',
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        data.personalRecordCount == 0
                            ? 'No new PRs'
                            : data.personalRecordCount == 1
                            ? '1 new PR'
                            : '${data.personalRecordCount} new PRs',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        data.personalRecordCount == 0
                            ? 'Mission completed. Keep building the baseline.'
                            : 'New performance milestones achieved.',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      if (data.personalRecords.isNotEmpty) ...[
                        const SizedBox(height: 14),

                        ...data.personalRecords.map(
                          (record) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.emoji_events_rounded,
                                    color: Colors.amber,
                                    size: 18,
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          record.exerciseName,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),

                                        const SizedBox(height: 3),

                                        Text(
                                          '${_formatNumber(record.weight)} '
                                          '${record.unit} × '
                                          '${record.reps} reps',
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
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.18),
              ),
            ),
            child: data.comparison == null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MISSION COMPARISON',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'First recorded ${data.workoutName}.',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        'This mission becomes your comparison baseline.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MISSION COMPARISON',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        'VS ${_formatShortDate(data.comparison!.previousDate)}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildComparisonStat(
                              label: 'Previous Volume',
                              value: data.comparison!.previousVolumeText,
                            ),
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: _buildComparisonStat(
                              label: 'Sets',
                              value: _formatChange(
                                data.comparison!.setDifference,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: _buildComparisonStat(
                              label: 'Volume',
                              value: _formatPercentChange(
                                data.comparison!.volumeChangePercent,
                              ),
                              valueColor:
                                  data.comparison!.volumeChangePercent > 0
                                  ? AppColors.success
                                  : data.comparison!.volumeChangePercent < 0
                                  ? Colors.orangeAccent
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: _recoveryColor().withValues(alpha: 0.22),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.bedtime_rounded, color: _recoveryColor()),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'RECOVERY CONTEXT',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        data.recovery == null
                            ? 'No recovery log'
                            : '${data.recovery!.label} • '
                                  '${data.recovery!.score}%',
                        style: TextStyle(
                          color: _recoveryColor(),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onDone,
              icon: const Icon(Icons.home_rounded),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  'RETURN TO COMMAND CENTER',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceVerdict() {
    final color = _performanceVerdictColor();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_performanceVerdictIcon(), color: color),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PERFORMANCE VERDICT',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  _performanceVerdictLabel(),
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  _performanceVerdictMessage(),
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

  Widget _buildComparisonStat({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _buildStat({
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
          Icon(icon, color: AppColors.primary, size: 19),

          const SizedBox(height: 10),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 3),

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
}
