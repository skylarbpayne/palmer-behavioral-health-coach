import 'package:flutter/material.dart';
import '../models/health_models.dart';
import '../widgets/metric_card.dart';
import '../utils/constants.dart';

class HealthSummaryScreen extends StatelessWidget {
  const HealthSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final healthMetrics = MockHealthData.getHealthMetrics();
    
    return Scaffold(
      backgroundColor: AppConstants.background,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryGreen,
        title: const Text(
          'Health Summary',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            Text(
              'Your Health Overview',
              style: AppConstants.largeTitleStyle,
            ),
            const SizedBox(height: 8),
            Text(
              'Track your progress and stay motivated',
              style: AppConstants.captionStyle,
            ),
            const SizedBox(height: 20),
            
            // Metrics grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0, // More square cards for better text accommodation
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: healthMetrics.length,
                itemBuilder: (context, index) {
                  return MetricCard(metric: healthMetrics[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}