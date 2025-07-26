import 'package:flutter/material.dart';
import '../models/health_models.dart';
import '../widgets/metric_card.dart';
import '../utils/constants.dart';
import '../screens/profile_screen.dart';
import '../services/user_profile_service.dart';

class HealthSummaryScreen extends StatefulWidget {
  const HealthSummaryScreen({super.key});

  @override
  State<HealthSummaryScreen> createState() => _HealthSummaryScreenState();
}

class _HealthSummaryScreenState extends State<HealthSummaryScreen> {
  final UserProfileService _profileService = UserProfileService();
  String _userName = 'User';
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadUserName();
  }
  
  Future<void> _loadUserName() async {
    // Add a small delay to ensure the widget is fully mounted
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (!mounted) return;
    
    try {
      await _profileService.initialize();
      final profile = await _profileService.loadProfile();
      if (mounted) {
        setState(() {
          _userName = profile.displayName;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      if (mounted) {
        setState(() {
          _userName = 'User'; // Fallback
          _isLoading = false;
        });
      }
    }
  }

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
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.person_outline,
              color: Colors.white,
            ),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            _isLoading
                ? const SizedBox(
                    height: 24,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                        ),
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, $_userName!',
                        style: AppConstants.largeTitleStyle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Track your progress and stay motivated',
                        style: AppConstants.captionStyle,
                      ),
                    ],
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