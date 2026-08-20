class SleepEntry {
  const SleepEntry({
    required this.date,
    required this.sleepMinutes,
    required this.quality,
  });

  final DateTime date;
  final int sleepMinutes;
  final int quality;

  double get sleepHours => sleepMinutes / 60.0;
}
