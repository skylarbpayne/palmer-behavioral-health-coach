import 'package:flutter/material.dart';
import '../models/health_models.dart';
import '../utils/constants.dart';

class MetricCard extends StatelessWidget {
  final HealthMetric metric;

  const MetricCard({super.key, required this.metric});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppConstants.cardDecoration,
      margin: const EdgeInsets.all(AppConstants.cardMargin),
      padding: const EdgeInsets.all(12.0), // Reduced padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title
          Flexible(
            child: Text(
              metric.title,
              style: AppConstants.subtitleStyle.copyWith(
                fontSize: 14.0, // Reduced font size
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 6),
          
          // Value with icon
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    metric.value,
                    style: AppConstants.largeTitleStyle.copyWith(
                      color: _getValueColor(),
                      fontSize: 20.0, // Further reduced font size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _getIcon(),
              ],
            ),
          ),
          
          // Progress bar (if applicable)
          if (metric.progress != null) ...[
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: metric.progress!,
              backgroundColor: AppConstants.border,
              valueColor: AlwaysStoppedAnimation<Color>(_getValueColor()),
              minHeight: 3,
            ),
            const SizedBox(height: 4),
          ],
          
          const SizedBox(height: 6),
          
          // Subtitle
          Flexible(
            child: Text(
              metric.subtitle,
              style: AppConstants.captionStyle.copyWith(
                fontSize: 11.0, // Reduced font size
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getValueColor() {
    switch (metric.type) {
      case HealthMetricType.progress:
        return AppConstants.primaryGreen;
      case HealthMetricType.count:
        return AppConstants.primaryBlue;
      case HealthMetricType.status:
        return AppConstants.warning;
      case HealthMetricType.date:
        return AppConstants.textSecondary;
    }
  }

  Widget _getIcon() {
    IconData iconData;
    Color iconColor = _getValueColor();
    
    switch (metric.type) {
      case HealthMetricType.progress:
        iconData = Icons.trending_up;
        break;
      case HealthMetricType.count:
        iconData = Icons.assessment;
        break;
      case HealthMetricType.status:
        iconData = Icons.health_and_safety;
        break;
      case HealthMetricType.date:
        iconData = Icons.schedule;
        break;
    }
    
    return Icon(
      iconData,
      color: iconColor,
      size: 20, // Further reduced icon size
    );
  }
}