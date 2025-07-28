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

  // Versioned data storage for audit trails
  Future<void> storeVersionedData(String key, Map<String, dynamic> data, int version) async {
    await _ensureInitialized();
    
    try {
      final versionedKey = '${key}_v$version';
      final jsonString = jsonEncode(data);
      final encryptedData = await _encryptionService.encrypt(jsonString);
      await _prefs!.setString(versionedKey, encryptedData);
      
      // Also update the latest version pointer
      await _prefs!.setInt('${key}_latest_version', version);
    } catch (e) {
      throw Exception('Failed to store versioned data: $e');
    }
  }

  Future<Map<String, dynamic>?> getVersionedData(String key, int version) async {
    await _ensureInitialized();
    
    try {
      final versionedKey = '${key}_v$version';
      final encryptedData = _prefs!.getString(versionedKey);
      if (encryptedData == null) return null;
      
      final jsonString = await _encryptionService.decrypt(encryptedData);
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<int?> getLatestVersion(String key) async {
    await _ensureInitialized();
    return _prefs!.getInt('${key}_latest_version');
  }

  Future<List<int>> getAvailableVersions(String key) async {
    await _ensureInitialized();
    
    final allKeys = await getAllKeys();
    final versionKeys = allKeys.where((k) => k.startsWith('${key}_v')).toList();
    
    final versions = <int>[];
    for (final versionKey in versionKeys) {
      final versionStr = versionKey.substring('${key}_v'.length);
      final version = int.tryParse(versionStr);
      if (version != null) {
        versions.add(version);
      }
    }
    
    versions.sort();
    return versions;
  }

  // Backup and restore capabilities
  Future<Map<String, dynamic>> createBackup() async {
    await _ensureInitialized();
    
    final backup = <String, dynamic>{};
    final allKeys = await getAllKeys();
    
    for (final key in allKeys) {
      try {
        // Try to get as secure data first
        final secureData = await getSecure(key);
        if (secureData != null) {
          backup[key] = {
            'type': 'secure',
            'data': secureData,
          };
        } else {
          // Try to get as regular string data
          final stringData = _prefs!.getString(key);
          if (stringData != null) {
            backup[key] = {
              'type': 'string',
              'data': stringData,
            };
          }
        }
      } catch (e) {
        // Skip keys that can't be read
        continue;
      }
    }
    
    backup['backup_metadata'] = {
      'created_at': DateTime.now().toIso8601String(),
      'version': '1.0',
    };
    
    return backup;
  }

  Future<void> restoreFromBackup(Map<String, dynamic> backup) async {
    await _ensureInitialized();
    
    for (final entry in backup.entries) {
      final key = entry.key;
      if (key == 'backup_metadata') continue;
      
      try {
        final itemData = entry.value as Map<String, dynamic>;
        final type = itemData['type'] as String;
        final data = itemData['data'];
        
        if (type == 'secure' && data is Map<String, dynamic>) {
          await storeSecure(key, data);
        } else if (type == 'string' && data is String) {
          await _prefs!.setString(key, data);
        }
      } catch (e) {
        // Skip items that can't be restored
        continue;
      }
    }
  }

  // Migration utilities
  Future<bool> needsMigration() async {
    await _ensureInitialized();
    
    // Check if we have any legacy format data
    final profileData = await getSecure('user_profile');
    if (profileData == null) return false;
    
    // Check if any field metadata uses the old format
    for (final fieldData in profileData.values) {
      if (fieldData is Map<String, dynamic> && fieldData.containsKey('metadata')) {
        final metadata = fieldData['metadata'] as Map<String, dynamic>;
        if (metadata.containsKey('lastChanged') && !metadata.containsKey('createdAt')) {
          return true;
        }
      }
    }
    
    return false;
  }

  Future<void> migrateToNewFormat() async {
    await _ensureInitialized();
    
    if (!await needsMigration()) return;
    
    final profileData = await getSecure('user_profile');
    if (profileData == null) return;
    
    // Create backup before migration
    final backup = await createBackup();
    await storeSecure('user_profile_backup_pre_migration', backup);
    
    // Migrate the profile data
    final migratedData = _migrateProfileData(profileData);
    await storeSecure('user_profile', migratedData);
    
    // Store migration metadata
    await store('migration_completed', true);
    await store('migration_timestamp', DateTime.now().toIso8601String());
  }

  Map<String, dynamic> _migrateProfileData(Map<String, dynamic> profileData) {
    final migratedData = <String, dynamic>{};
    
    for (final entry in profileData.entries) {
      final key = entry.key;
      final value = entry.value;
      
      if (value is Map<String, dynamic>) {
        if (value.containsKey('metadata')) {
          // This is a ProfileField or ProfileArrayItem
          final metadata = value['metadata'] as Map<String, dynamic>;
          
          if (metadata.containsKey('lastChanged') && !metadata.containsKey('createdAt')) {
            // Migrate metadata to new format
            final lastChanged = DateTime.parse(metadata['lastChanged']);
            final migratedMetadata = {
              'createdAt': lastChanged.toIso8601String(),
              'lastModified': lastChanged.toIso8601String(),
              'lastConfirmed': metadata['lastConfirmed'],
              'deletedAt': null,
              'createdBy': 'system',
              'modifiedBy': 'system',
              'deletedBy': null,
              'reason': 'migrated_from_legacy',
              'version': 1,
              'changeContext': 'data_migration',
              'additionalMetadata': null,
            };
            
            migratedData[key] = {
              ...value,
              'metadata': migratedMetadata,
            };
          } else {
            migratedData[key] = value;
          }
        } else if (value is List) {
          // This is an array field
          final migratedArray = <Map<String, dynamic>>[];
          
          for (final item in (value as List)) {
            if (item is Map<String, dynamic> && item.containsKey('metadata')) {
              final metadata = item['metadata'] as Map<String, dynamic>;
              
              if (metadata.containsKey('lastChanged') && !metadata.containsKey('createdAt')) {
                final lastChanged = DateTime.parse(metadata['lastChanged']);
                final migratedMetadata = {
                  'createdAt': lastChanged.toIso8601String(),
                  'lastModified': lastChanged.toIso8601String(),
                  'lastConfirmed': metadata['lastConfirmed'],
                  'deletedAt': null,
                  'createdBy': 'system',
                  'modifiedBy': 'system',
                  'deletedBy': null,
                  'reason': 'migrated_from_legacy',
                  'version': 1,
                  'changeContext': 'data_migration',
                  'additionalMetadata': null,
                };
                
                migratedArray.add({
                  ...item,
                  'metadata': migratedMetadata,
                });
              } else {
                migratedArray.add(item);
              }
            } else {
              migratedArray.add(item);
            }
          }
          
          migratedData[key] = migratedArray;
        } else {
          migratedData[key] = value;
        }
      } else {
        migratedData[key] = value;
      }
    }
    
    return migratedData;
  }
}