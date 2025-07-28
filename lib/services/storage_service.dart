import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> store(String key, Map<String, dynamic> data) async {
    await _ensureInitialized();
    
    try {
      final jsonString = jsonEncode(data);
      await _prefs!.setString(key, jsonString);
    } catch (e) {
      throw Exception('Failed to store secure data: $e');
    }
  }

  Future<Map<String, dynamic>?> get(String key) async {
    await _ensureInitialized();
    final data = _prefs!.getString(key);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  Future<void> remove(String key) async {
    await _ensureInitialized();
    await _prefs!.remove(key);
  }

  Future<void> clear() async {
    await _ensureInitialized();
    await _prefs!.clear();
  }

  Future<List<String>> getAllKeys() async {
    await _ensureInitialized();
    return _prefs!.getKeys().toList();
  }

  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await initialize();
    }
  }
}