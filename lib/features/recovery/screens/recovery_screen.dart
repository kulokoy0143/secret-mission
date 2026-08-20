import 'package:flutter/material.dart';
import 'package:secret_mission/app/app_theme.dart';
import 'package:secret_mission/features/recovery/models/recovery_status.dart';
import 'package:secret_mission/features/recovery/models/sleep_entry.dart';
import 'package:secret_mission/features/recovery/services/recovery_service.dart';

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({super.key});

  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  int _sleepMinutes = 465;
  int _sleepQuality = 4;

  @override
  Widget build(BuildContext context) {
    final sleep = SleepEntry(
      date: DateTime.now(),
      sleepMinutes: _sleepMinutes,
      quality: _sleepQuality,
    );

    final recovery = RecoveryService.calculateRecovery(sleep);

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

          _buildSleepCard(sleep),
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
            },
          ),
        ],
      ),
    );
  }
}
