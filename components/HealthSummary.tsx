import React from 'react';
import { StyleSheet, Text, View, ScrollView } from 'react-native';

interface HealthMetric {
  title: string;
  value: string;
  status: 'good' | 'warning' | 'attention';
  unit?: string;
}

interface Goal {
  title: string;
  progress: number;
  target: string;
}

interface Suggestion {
  title: string;
  description: string;
  completed: boolean;
}

export default function HealthSummary() {
  const healthMetrics: HealthMetric[] = [
    { title: 'Sleep', value: '7.2', unit: 'hours', status: 'good' },
    { title: 'Steps', value: '8,432', unit: 'steps', status: 'good' },
    { title: 'Heart Rate', value: '72', unit: 'bpm', status: 'good' },
    { title: 'Stress Level', value: 'Moderate', status: 'warning' },
  ];

  const goals: Goal[] = [
    { title: 'Daily Steps', progress: 0.84, target: '10,000 steps' },
    { title: 'Sleep Duration', progress: 0.9, target: '8 hours' },
    { title: 'Water Intake', progress: 0.6, target: '8 glasses' },
  ];

  const suggestions: Suggestion[] = [
    { title: 'Take a 10-minute walk', description: 'Light exercise can help reduce stress', completed: true },
    { title: 'Deep breathing exercise', description: '5 minutes of mindful breathing', completed: false },
    { title: 'Drink water', description: 'Stay hydrated for better focus', completed: false },
  ];

  const getStatusColor = (status: HealthMetric['status']) => {
    switch (status) {
      case 'good': return '#4CAF50';
      case 'warning': return '#FF9800';
      case 'attention': return '#F44336';
    }
  };

  return (
    <ScrollView style={styles.scrollView} contentContainerStyle={styles.content}>
      <Text style={styles.title}>Health Summary</Text>
      
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Today's Metrics</Text>
        <View style={styles.metricsGrid}>
          {healthMetrics.map((metric, index) => (
            <View key={index} style={styles.metricCard}>
              <Text style={styles.metricTitle}>{metric.title}</Text>
              <Text style={[styles.metricValue, { color: getStatusColor(metric.status) }]}>
                {metric.value}
              </Text>
              {metric.unit && <Text style={styles.metricUnit}>{metric.unit}</Text>}
            </View>
          ))}
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Goals Progress</Text>
        {goals.map((goal, index) => (
          <View key={index} style={styles.goalCard}>
            <View style={styles.goalHeader}>
              <Text style={styles.goalTitle}>{goal.title}</Text>
              <Text style={styles.goalTarget}>{goal.target}</Text>
            </View>
            <View style={styles.progressBar}>
              <View style={[styles.progressFill, { width: `${goal.progress * 100}%` }]} />
            </View>
            <Text style={styles.progressText}>{Math.round(goal.progress * 100)}% complete</Text>
          </View>
        ))}
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Suggestions & Accomplishments</Text>
        {suggestions.map((suggestion, index) => (
          <View key={index} style={[styles.suggestionCard, suggestion.completed && styles.completedCard]}>
            <Text style={[styles.suggestionTitle, suggestion.completed && styles.completedText]}>
              {suggestion.completed ? '✅ ' : '• '}{suggestion.title}
            </Text>
            <Text style={[styles.suggestionDesc, suggestion.completed && styles.completedText]}>
              {suggestion.description}
            </Text>
          </View>
        ))}
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  scrollView: {
    flex: 1,
  },
  content: {
    padding: 20,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 20,
    textAlign: 'center',
  },
  section: {
    marginBottom: 30,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: '600',
    color: '#333',
    marginBottom: 15,
  },
  metricsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  metricCard: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 15,
    width: '48%',
    marginBottom: 10,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  metricTitle: {
    fontSize: 14,
    color: '#666',
    marginBottom: 5,
  },
  metricValue: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 2,
  },
  metricUnit: {
    fontSize: 12,
    color: '#999',
  },
  goalCard: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 15,
    marginBottom: 10,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  goalHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 10,
  },
  goalTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
  },
  goalTarget: {
    fontSize: 14,
    color: '#666',
  },
  progressBar: {
    height: 8,
    backgroundColor: '#e0e0e0',
    borderRadius: 4,
    marginBottom: 5,
  },
  progressFill: {
    height: '100%',
    backgroundColor: '#4CAF50',
    borderRadius: 4,
  },
  progressText: {
    fontSize: 12,
    color: '#666',
    textAlign: 'right',
  },
  suggestionCard: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 15,
    marginBottom: 10,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  completedCard: {
    backgroundColor: '#f8f9fa',
  },
  suggestionTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
    marginBottom: 5,
  },
  suggestionDesc: {
    fontSize: 14,
    color: '#666',
  },
  completedText: {
    opacity: 0.7,
  },
});