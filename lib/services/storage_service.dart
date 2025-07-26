import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'encryption_service.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final EncryptionService _encryptionService = EncryptionService();
  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _encryptionService.initialize();
  }

  Future<void> storeSecure(String key, Map<String, dynamic> data) async {
    await _ensureInitialized();
    
    try {
      final jsonString = jsonEncode(data);
      final encryptedData = await _encryptionService.encrypt(jsonString);
      await _prefs!.setString(key, encryptedData);
    } catch (e) {
      throw Exception('Failed to store secure data: $e');
    }
  }

  Future<Map<String, dynamic>?> getSecure(String key) async {
    await _ensureInitialized();
    
    try {
      final encryptedData = _prefs!.getString(key);
      if (encryptedData == null) return null;
      
      final jsonString = await _encryptionService.decrypt(encryptedData);
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<void> store(String key, dynamic value) async {
    await _ensureInitialized();
    
    if (value is String) {
      await _prefs!.setString(key, value);
    } else if (value is int) {
      await _prefs!.setInt(key, value);
    } else if (value is double) {
      await _prefs!.setDouble(key, value);
    } else if (value is bool) {
      await _prefs!.setBool(key, value);
    } else if (value is List<String>) {
      await _prefs!.setStringList(key, value);
    } else {
      final jsonString = jsonEncode(value);
      await _prefs!.setString(key, jsonString);
    }
  }

  Future<T?> get<T>(String key, {T? defaultValue}) async {
    await _ensureInitialized();
    
    try {
      if (T == String) {
        return _prefs!.getString(key) as T? ?? defaultValue;
      } else if (T == int) {
        return _prefs!.getInt(key) as T? ?? defaultValue;
      } else if (T == double) {
        return _prefs!.getDouble(key) as T? ?? defaultValue;
      } else if (T == bool) {
        return _prefs!.getBool(key) as T? ?? defaultValue;
      } else {
        final value = _prefs!.getString(key);
        if (value == null) return defaultValue;
        return jsonDecode(value) as T;
      }
    } catch (e) {
      return defaultValue;
    }
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

  bool get isInitialized => _prefs != null && _encryptionService.isInitialized;
}