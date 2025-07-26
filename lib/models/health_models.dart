/// Health data models for Palmer Behavioral Health Coach
class HealthMetric {
  final String title;
  final String value;
  final String subtitle;
  final HealthMetricType type;
  final double? progress; // 0.0 to 1.0 for progress metrics

  const HealthMetric({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.type,
    this.progress,
  });
}

enum HealthMetricType {
  progress,
  count,
  status,
  date,
}

/// Mock health data for Step 3
class MockHealthData {
  static List<HealthMetric> getHealthMetrics() {
    return [
      const HealthMetric(
        title: 'Goals Progress',
        value: '3/5',
        subtitle: 'Goals completed this week',
        type: HealthMetricType.progress,
        progress: 0.6,
      ),
      const HealthMetric(
        title: 'Current Symptoms',
        value: '2',
        subtitle: 'Active symptoms being tracked',
        type: HealthMetricType.count,
      ),
      const HealthMetric(
        title: 'Interventions',
        value: '4',
        subtitle: 'Active coping strategies',
        type: HealthMetricType.count,
      ),
      const HealthMetric(
        title: 'Last Check-in',
        value: 'Today',
        subtitle: 'Most recent health assessment',
        type: HealthMetricType.date,
      ),
    ];
  }
}