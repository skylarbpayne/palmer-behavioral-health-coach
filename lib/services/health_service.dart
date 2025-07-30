import 'package:health/health.dart';

class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  Health? _health;
  bool _isAuthorized = false;

  static const List<HealthDataType> _types = [
    HealthDataType.STEPS,
    HealthDataType.SLEEP_ASLEEP,
  ];

  static const List<HealthDataAccess> _permissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  Future<bool> initialize() async {
    _health = Health();
    
    try {
      // Check if health data is supported on this device
      final isSupported = await _health!.hasPermissions(_types, permissions: _permissions);
      print('Health permissions supported: $isSupported');
      
      // Request authorization
      _isAuthorized = await _health!.requestAuthorization(_types, permissions: _permissions);
      print('Health authorization granted: $_isAuthorized');
      
      // Double-check permissions after request
      final hasPermissions = await _health!.hasPermissions(_types, permissions: _permissions);
      print('Health permissions after request: $hasPermissions');
      
      return _isAuthorized;
    } catch (e) {
      print('Health initialization error: $e');
      _isAuthorized = false;
      return false;
    }
  }

  Future<int?> getStepsForDate(DateTime date) async {
    if (!_isAuthorized || _health == null) {
      return null;
    }

    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final healthData = await _health!.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: startOfDay,
        endTime: endOfDay,
      );

      if (healthData.isEmpty) return 0;

      // Sum all step data points for the day
      int totalSteps = 0;
      for (var data in healthData) {
        if (data.type == HealthDataType.STEPS && data.value is NumericHealthValue) {
          totalSteps += (data.value as NumericHealthValue).numericValue.toInt();
        }
      }

      return totalSteps;
    } catch (e) {
      return null;
    }
  }

  Future<Duration?> getSleepForDate(DateTime date) async {
    if (!_isAuthorized || _health == null) {
      return null;
    }

    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final healthData = await _health!.getHealthDataFromTypes(
        types: [HealthDataType.SLEEP_ASLEEP],
        startTime: startOfDay,
        endTime: endOfDay,
      );

      if (healthData.isEmpty) return Duration.zero;

      // Calculate total sleep duration
      int totalMinutes = 0;
      for (var data in healthData) {
        if (data.type == HealthDataType.SLEEP_ASLEEP && data.value is NumericHealthValue) {
          totalMinutes += (data.value as NumericHealthValue).numericValue.toInt();
        }
      }

      return Duration(minutes: totalMinutes);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> getLast7DaysHealthData() async {
    if (!_isAuthorized || _health == null) {
      return {'steps': <int>[], 'sleep': <Duration>[]};
    }

    final List<int> stepsList = [];
    final List<Duration> sleepList = [];
    final DateTime today = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      
      final steps = await getStepsForDate(date);
      final sleep = await getSleepForDate(date);
      
      stepsList.add(steps ?? 0);
      sleepList.add(sleep ?? Duration.zero);
    }

    return {
      'steps': stepsList,
      'sleep': sleepList,
    };
  }

  bool get isAuthorized => _isAuthorized;
}