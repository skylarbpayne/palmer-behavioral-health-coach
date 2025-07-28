import 'package:uuid/uuid.dart';
import '../models/user_profile.dart';
import 'storage_service.dart';

class UserProfileService {
  static final UserProfileService _instance = UserProfileService._internal();
  factory UserProfileService() => _instance;
  UserProfileService._internal();

  final StorageService _storage = StorageService();
  static const String _profileKey = 'user_profile';
  UserProfile? _cachedProfile;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _storage.initialize();
    
    // Check for and run migration if needed
    if (await _storage.needsMigration()) {
      await _storage.migrateToNewFormat();
    }
    
    await loadProfile();
    _isInitialized = true;
  }

  Future<UserProfile> loadProfile() async {
    if (!_isInitialized) {
      _cachedProfile = UserProfile.empty();
      return _cachedProfile!;
    }
    
    try {
      final profileData = await _storage.getSecure(_profileKey);
      if (profileData != null) {
        _cachedProfile = UserProfile.fromJson(profileData);
      } else {
        _cachedProfile = UserProfile.empty();
      }
    } catch (e) {
      print('Failed to load profile: $e');
      _cachedProfile = UserProfile.empty();
    }
    
    return _cachedProfile ?? UserProfile.empty();
  }

  Future<void> saveProfile() async {
    await _ensureInitialized();
    
    if (_cachedProfile == null) return;
    
    try {
      await _storage.storeSecure(_profileKey, _cachedProfile!.toJson());
    } catch (e) {
      print('Failed to save profile: $e');
      throw Exception('Failed to save profile');
    }
  }

  Future<void> clearProfile() async {
    await _ensureInitialized();
    
    _cachedProfile = UserProfile.empty();
    await _storage.remove(_profileKey);
  }

  UserProfile get currentProfile {
    return _cachedProfile ?? UserProfile.empty();
  }

  // Simple field operations
  Future<ProfileField<T>?> getSimpleField<T>(String field) async {
    await _ensureInitialized();
    
    switch (field) {
      case 'firstName':
        return _cachedProfile?.firstName as ProfileField<T>?;
      case 'lastName':
        return _cachedProfile?.lastName as ProfileField<T>?;
      case 'sex':
        return _cachedProfile?.sex as ProfileField<T>?;
      case 'gender':
        return _cachedProfile?.gender as ProfileField<T>?;
      case 'dateOfBirth':
        return _cachedProfile?.dateOfBirth as ProfileField<T>?;
      case 'sexualOrientation':
        return _cachedProfile?.sexualOrientation as ProfileField<T>?;
      default:
        return null;
    }
  }

  Future<void> updateSimpleField<T>(String field, T value, {
    bool confirm = false,
    String? userId,
    String? reason,
    String? changeContext,
  }) async {
    await _ensureInitialized();
    
    final currentField = await getSimpleField<T>(field);
    ProfileField<T> newField;
    
    if (currentField != null) {
      newField = currentField.withNewValue(
        value,
        userId: userId,
        reason: reason,
        changeContext: changeContext,
        confirm: confirm,
      );
    } else {
      final now = DateTime.now();
      newField = ProfileField<T>(
        value: value,
        metadata: FieldMetadata(
          createdAt: now,
          lastModified: now,
          createdBy: userId ?? 'system',
          modifiedBy: userId ?? 'system',
          reason: reason,
          changeContext: changeContext,
        ),
      );
      if (confirm) {
        newField = newField.confirmValue(
          userId: userId,
          reason: reason,
          changeContext: changeContext,
        );
      }
    }
    
    _cachedProfile ??= UserProfile.empty();
    
    switch (field) {
      case 'firstName':
        _cachedProfile = _cachedProfile!.copyWith(firstName: newField as ProfileField<String>);
        break;
      case 'lastName':
        _cachedProfile = _cachedProfile!.copyWith(lastName: newField as ProfileField<String>);
        break;
      case 'sex':
        _cachedProfile = _cachedProfile!.copyWith(sex: newField as ProfileField<String>);
        break;
      case 'gender':
        _cachedProfile = _cachedProfile!.copyWith(gender: newField as ProfileField<String>);
        break;
      case 'dateOfBirth':
        _cachedProfile = _cachedProfile!.copyWith(dateOfBirth: newField as ProfileField<String>);
        break;
      case 'sexualOrientation':
        _cachedProfile = _cachedProfile!.copyWith(sexualOrientation: newField as ProfileField<String>);
        break;
    }
    
    await saveProfile();
  }

  Future<void> confirmSimpleField(String field, {
    String? userId,
    String? reason,
    String? changeContext,
  }) async {
    final currentField = await getSimpleField<dynamic>(field);
    if (currentField != null) {
      final updatedField = currentField.confirmValue(
        userId: userId,
        reason: reason,
        changeContext: changeContext,
      );
      
      _cachedProfile ??= UserProfile.empty();
      
      switch (field) {
        case 'firstName':
          _cachedProfile = _cachedProfile!.copyWith(firstName: updatedField as ProfileField<String>);
          break;
        case 'lastName':
          _cachedProfile = _cachedProfile!.copyWith(lastName: updatedField as ProfileField<String>);
          break;
        case 'sex':
          _cachedProfile = _cachedProfile!.copyWith(sex: updatedField as ProfileField<String>);
          break;
        case 'gender':
          _cachedProfile = _cachedProfile!.copyWith(gender: updatedField as ProfileField<String>);
          break;
        case 'dateOfBirth':
          _cachedProfile = _cachedProfile!.copyWith(dateOfBirth: updatedField as ProfileField<String>);
          break;
        case 'sexualOrientation':
          _cachedProfile = _cachedProfile!.copyWith(sexualOrientation: updatedField as ProfileField<String>);
          break;
      }
      
      await saveProfile();
    }
  }

  // Array field operations
  Future<List<ProfileArrayItem<String>>?> getArrayField(String field) async {
    await _ensureInitialized();
    
    switch (field) {
      case 'currentHealthGoals':
        return _cachedProfile?.currentHealthGoals;
      case 'currentBehavioralHealthSymptoms':
        return _cachedProfile?.currentBehavioralHealthSymptoms;
      case 'currentInterventions':
        return _cachedProfile?.currentInterventions;
      default:
        return null;
    }
  }

  Future<String> addArrayItem(String field, String value, {
    bool confirm = false,
    String? userId,
    String? reason,
    String? changeContext,
  }) async {
    await _ensureInitialized();
    
    final now = DateTime.now();
    final newItem = ProfileArrayItem<String>(
      value: value,
      id: const Uuid().v4(),
      metadata: FieldMetadata(
        createdAt: now,
        lastModified: now,
        createdBy: userId ?? 'system',
        modifiedBy: userId ?? 'system',
        reason: reason,
        changeContext: changeContext,
      ),
    );
    
    final finalItem = confirm ? newItem.confirmValue(
      userId: userId,
      reason: reason,
      changeContext: changeContext,
    ) : newItem;
    
    _cachedProfile ??= UserProfile.empty();
    
    switch (field) {
      case 'currentHealthGoals':
        final currentList = _cachedProfile!.currentHealthGoals ?? [];
        _cachedProfile = _cachedProfile!.copyWith(
          currentHealthGoals: [...currentList, finalItem],
        );
        break;
      case 'currentBehavioralHealthSymptoms':
        final currentList = _cachedProfile!.currentBehavioralHealthSymptoms ?? [];
        _cachedProfile = _cachedProfile!.copyWith(
          currentBehavioralHealthSymptoms: [...currentList, finalItem],
        );
        break;
      case 'currentInterventions':
        final currentList = _cachedProfile!.currentInterventions ?? [];
        _cachedProfile = _cachedProfile!.copyWith(
          currentInterventions: [...currentList, finalItem],
        );
        break;
    }
    
    await saveProfile();
    return finalItem.id;
  }

  // Soft delete array item
  Future<void> softDeleteArrayItem(String field, String id, {
    String? userId,
    String? reason,
    String? changeContext,
  }) async {
    await _ensureInitialized();
    
    _cachedProfile ??= UserProfile.empty();
    
    switch (field) {
      case 'currentHealthGoals':
        final currentList = _cachedProfile!.currentHealthGoals ?? [];
        final updatedList = currentList.map((item) {
          if (item.id == id) {
            return item.markDeleted(
              userId: userId,
              reason: reason,
              changeContext: changeContext,
            );
          }
          return item;
        }).toList();
        _cachedProfile = _cachedProfile!.copyWith(currentHealthGoals: updatedList);
        break;
      case 'currentBehavioralHealthSymptoms':
        final currentList = _cachedProfile!.currentBehavioralHealthSymptoms ?? [];
        final updatedList = currentList.map((item) {
          if (item.id == id) {
            return item.markDeleted(
              userId: userId,
              reason: reason,
              changeContext: changeContext,
            );
          }
          return item;
        }).toList();
        _cachedProfile = _cachedProfile!.copyWith(currentBehavioralHealthSymptoms: updatedList);
        break;
      case 'currentInterventions':
        final currentList = _cachedProfile!.currentInterventions ?? [];
        final updatedList = currentList.map((item) {
          if (item.id == id) {
            return item.markDeleted(
              userId: userId,
              reason: reason,
              changeContext: changeContext,
            );
          }
          return item;
        }).toList();
        _cachedProfile = _cachedProfile!.copyWith(currentInterventions: updatedList);
        break;
    }
    
    await saveProfile();
  }

  // Restore soft deleted array item
  Future<void> restoreArrayItem(String field, String id, {
    String? userId,
    String? reason,
    String? changeContext,
  }) async {
    await _ensureInitialized();
    
    _cachedProfile ??= UserProfile.empty();
    
    switch (field) {
      case 'currentHealthGoals':
        final currentList = _cachedProfile!.currentHealthGoals ?? [];
        final updatedList = currentList.map((item) {
          if (item.id == id) {
            return item.restore(
              userId: userId,
              reason: reason,
              changeContext: changeContext,
            );
          }
          return item;
        }).toList();
        _cachedProfile = _cachedProfile!.copyWith(currentHealthGoals: updatedList);
        break;
      case 'currentBehavioralHealthSymptoms':
        final currentList = _cachedProfile!.currentBehavioralHealthSymptoms ?? [];
        final updatedList = currentList.map((item) {
          if (item.id == id) {
            return item.restore(
              userId: userId,
              reason: reason,
              changeContext: changeContext,
            );
          }
          return item;
        }).toList();
        _cachedProfile = _cachedProfile!.copyWith(currentBehavioralHealthSymptoms: updatedList);
        break;
      case 'currentInterventions':
        final currentList = _cachedProfile!.currentInterventions ?? [];
        final updatedList = currentList.map((item) {
          if (item.id == id) {
            return item.restore(
              userId: userId,
              reason: reason,
              changeContext: changeContext,
            );
          }
          return item;
        }).toList();
        _cachedProfile = _cachedProfile!.copyWith(currentInterventions: updatedList);
        break;
    }
    
    await saveProfile();
  }

  // Hard delete for backward compatibility (now deprecated)
  @Deprecated('Use softDeleteArrayItem instead for audit trail compliance')
  Future<void> removeArrayItem(String field, String id) async {
    await softDeleteArrayItem(field, id, reason: 'legacy_hard_delete');
  }

  Future<void> updateArrayItem(String field, String id, String value, {
    bool confirm = false,
    String? userId,
    String? reason,
    String? changeContext,
  }) async {
    await _ensureInitialized();
    
    _cachedProfile ??= UserProfile.empty();
    
    switch (field) {
      case 'currentHealthGoals':
        final currentList = _cachedProfile!.currentHealthGoals ?? [];
        final updatedList = currentList.map((item) {
          if (item.id == id) {
            return item.withNewValue(
              value,
              userId: userId,
              reason: reason,
              changeContext: changeContext,
              confirm: confirm,
            );
          }
          return item;
        }).toList();
        _cachedProfile = _cachedProfile!.copyWith(currentHealthGoals: updatedList);
        break;
      case 'currentBehavioralHealthSymptoms':
        final currentList = _cachedProfile!.currentBehavioralHealthSymptoms ?? [];
        final updatedList = currentList.map((item) {
          if (item.id == id) {
            return item.withNewValue(
              value,
              userId: userId,
              reason: reason,
              changeContext: changeContext,
              confirm: confirm,
            );
          }
          return item;
        }).toList();
        _cachedProfile = _cachedProfile!.copyWith(currentBehavioralHealthSymptoms: updatedList);
        break;
      case 'currentInterventions':
        final currentList = _cachedProfile!.currentInterventions ?? [];
        final updatedList = currentList.map((item) {
          if (item.id == id) {
            return item.withNewValue(
              value,
              userId: userId,
              reason: reason,
              changeContext: changeContext,
              confirm: confirm,
            );
          }
          return item;
        }).toList();
        _cachedProfile = _cachedProfile!.copyWith(currentInterventions: updatedList);
        break;
    }
    
    await saveProfile();
  }

  Future<void> confirmArrayItem(String field, String id, {
    String? userId,
    String? reason,
    String? changeContext,
  }) async {
    await _ensureInitialized();
    
    _cachedProfile ??= UserProfile.empty();
    
    switch (field) {
      case 'currentHealthGoals':
        final currentList = _cachedProfile!.currentHealthGoals ?? [];
        final updatedList = currentList.map((item) {
          if (item.id == id) {
            return item.confirmValue(
              userId: userId,
              reason: reason,
              changeContext: changeContext,
            );
          }
          return item;
        }).toList();
        _cachedProfile = _cachedProfile!.copyWith(currentHealthGoals: updatedList);
        break;
      case 'currentBehavioralHealthSymptoms':
        final currentList = _cachedProfile!.currentBehavioralHealthSymptoms ?? [];
        final updatedList = currentList.map((item) {
          if (item.id == id) {
            return item.confirmValue(
              userId: userId,
              reason: reason,
              changeContext: changeContext,
            );
          }
          return item;
        }).toList();
        _cachedProfile = _cachedProfile!.copyWith(currentBehavioralHealthSymptoms: updatedList);
        break;
      case 'currentInterventions':
        final currentList = _cachedProfile!.currentInterventions ?? [];
        final updatedList = currentList.map((item) {
          if (item.id == id) {
            return item.confirmValue(
              userId: userId,
              reason: reason,
              changeContext: changeContext,
            );
          }
          return item;
        }).toList();
        _cachedProfile = _cachedProfile!.copyWith(currentInterventions: updatedList);
        break;
    }
    
    await saveProfile();
  }

  // Get active array items (filtering out soft deleted)
  Future<List<ProfileArrayItem<String>>?> getActiveArrayField(String field) async {
    final items = await getArrayField(field);
    return items?.where((item) => item.isActive).toList();
  }

  // Get deleted array items
  Future<List<ProfileArrayItem<String>>?> getDeletedArrayField(String field) async {
    final items = await getArrayField(field);
    return items?.where((item) => item.isDeleted).toList();
  }

  // Soft delete a simple field
  Future<void> softDeleteSimpleField(String field, {
    String? userId,
    String? reason,
    String? changeContext,
  }) async {
    await _ensureInitialized();
    
    final currentField = await getSimpleField<dynamic>(field);
    if (currentField != null) {
      final deletedField = currentField.markDeleted(
        userId: userId,
        reason: reason,
        changeContext: changeContext,
      );
      
      _cachedProfile ??= UserProfile.empty();
      
      switch (field) {
        case 'firstName':
          _cachedProfile = _cachedProfile!.copyWith(firstName: deletedField as ProfileField<String>);
          break;
        case 'lastName':
          _cachedProfile = _cachedProfile!.copyWith(lastName: deletedField as ProfileField<String>);
          break;
        case 'sex':
          _cachedProfile = _cachedProfile!.copyWith(sex: deletedField as ProfileField<String>);
          break;
        case 'gender':
          _cachedProfile = _cachedProfile!.copyWith(gender: deletedField as ProfileField<String>);
          break;
        case 'dateOfBirth':
          _cachedProfile = _cachedProfile!.copyWith(dateOfBirth: deletedField as ProfileField<String>);
          break;
        case 'sexualOrientation':
          _cachedProfile = _cachedProfile!.copyWith(sexualOrientation: deletedField as ProfileField<String>);
          break;
      }
      
      await saveProfile();
    }
  }

  // Restore a soft deleted simple field
  Future<void> restoreSimpleField(String field, {
    String? userId,
    String? reason,
    String? changeContext,
  }) async {
    await _ensureInitialized();
    
    final currentField = await getSimpleField<dynamic>(field);
    if (currentField != null && currentField.isDeleted) {
      final restoredField = currentField.restore(
        userId: userId,
        reason: reason,
        changeContext: changeContext,
      );
      
      _cachedProfile ??= UserProfile.empty();
      
      switch (field) {
        case 'firstName':
          _cachedProfile = _cachedProfile!.copyWith(firstName: restoredField as ProfileField<String>);
          break;
        case 'lastName':
          _cachedProfile = _cachedProfile!.copyWith(lastName: restoredField as ProfileField<String>);
          break;
        case 'sex':
          _cachedProfile = _cachedProfile!.copyWith(sex: restoredField as ProfileField<String>);
          break;
        case 'gender':
          _cachedProfile = _cachedProfile!.copyWith(gender: restoredField as ProfileField<String>);
          break;
        case 'dateOfBirth':
          _cachedProfile = _cachedProfile!.copyWith(dateOfBirth: restoredField as ProfileField<String>);
          break;
        case 'sexualOrientation':
          _cachedProfile = _cachedProfile!.copyWith(sexualOrientation: restoredField as ProfileField<String>);
          break;
      }
      
      await saveProfile();
    }
  }

  // Check if a simple field is soft deleted
  Future<bool> isSimpleFieldDeleted(String field) async {
    final currentField = await getSimpleField<dynamic>(field);
    return currentField?.isDeleted ?? false;
  }

  // Check if an array item is soft deleted
  Future<bool> isArrayItemDeleted(String field, String id) async {
    final items = await getArrayField(field);
    final item = items?.firstWhere(
      (item) => item.id == id,
      orElse: () => throw StateError('Item not found'),
    );
    return item?.isDeleted ?? false;
  }

  // Get audit information for a simple field
  Future<FieldMetadata?> getSimpleFieldMetadata(String field) async {
    final currentField = await getSimpleField<dynamic>(field);
    return currentField?.metadata;
  }

  // Get audit information for an array item
  Future<FieldMetadata?> getArrayItemMetadata(String field, String id) async {
    final items = await getArrayField(field);
    final item = items?.firstWhere(
      (item) => item.id == id,
      orElse: () => throw StateError('Item not found'),
    );
    return item?.metadata;
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  bool get isInitialized => _isInitialized;

  // Backup and restore functionality
  Future<Map<String, dynamic>> createProfileBackup() async {
    await _ensureInitialized();
    return await _storage.createBackup();
  }

  Future<void> restoreProfileFromBackup(Map<String, dynamic> backup) async {
    await _ensureInitialized();
    await _storage.restoreFromBackup(backup);
    await loadProfile();
  }

  // Check if profile data needs migration
  Future<bool> needsDataMigration() async {
    return await _storage.needsMigration();
  }

  // Manually trigger data migration
  Future<void> migrateProfileData() async {
    await _storage.migrateToNewFormat();
    await loadProfile();
  }
}