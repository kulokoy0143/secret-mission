import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../training/training_screen.dart';

class CommandCenterScreen extends StatefulWidget {
  const CommandCenterScreen({super.key});

  @override
  State<CommandCenterScreen> createState() => _CommandCenterScreenState();
}

class _CommandCenterScreenState extends State<CommandCenterScreen> {
  int _selectedIndex = 0;

  final List<String> _pageTitles = const [
    'Command Center',
    'Training',
    'Progress',
    'Commander',
    'Agent File',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildDashboard(),
            const TrainingScreen(),
            _buildPlaceholder('Progress'),
            _buildPlaceholder('Commander AI'),
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
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            selectedIcon: Icon(Icons.smart_toy_rounded),
            label: 'Commander',
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

  Widget _buildDashboard() {
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

          const Row(
            children: [
              Icon(Icons.circle, color: AppColors.success, size: 9),
              SizedBox(width: 8),
              Text(
                'MISSION STATUS: READY',
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          _buildMissionCard(),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.bedtime_outlined,
                  title: 'Recovery',
                  value: '91%',
                  subtitle: 'Excellent',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.local_fire_department_outlined,
                  title: 'Streak',
                  value: '12',
                  subtitle: 'Days',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildCommanderCard(),
        ],
      ),
    );
  }

  Widget _buildMissionCard() {
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
          const Text(
            "TODAY'S MISSION",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Push Day',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Chest • Shoulders • Triceps',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              setState(() {
                _selectedIndex = 1;
              });
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
            ),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text(
              'START WORKOUT',
              style: TextStyle(fontWeight: FontWeight.bold),
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
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 18),
          Text(title, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.success, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCommanderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Icon(Icons.smart_toy_rounded, color: Colors.white),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'COMMANDER',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Your recovery looks excellent. You are ready for a strong Push Day session.',
                  style: TextStyle(color: AppColors.textSecondary, height: 1.5),
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
