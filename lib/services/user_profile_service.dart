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

  Future<void> updateSimpleField<T>(String field, T value, {bool confirm = false}) async {
    await _ensureInitialized();
    
    final now = DateTime.now();
    final newField = ProfileField<T>(
      value: value,
      metadata: FieldMetadata(
        lastChanged: now,
        lastConfirmed: confirm ? now : null,
      ),
    );
    
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

  Future<void> confirmSimpleField(String field) async {
    final currentField = await getSimpleField<dynamic>(field);
    if (currentField != null) {
      final updatedMetadata = currentField.metadata.copyWith(
        lastConfirmed: DateTime.now(),
      );
      final updatedField = currentField.copyWith(metadata: updatedMetadata);
      
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

  Future<String> addArrayItem(String field, String value, {bool confirm = false}) async {
    await _ensureInitialized();
    
    final now = DateTime.now();
    final newItem = ProfileArrayItem<String>(
      value: value,
      id: const Uuid().v4(),
      metadata: FieldMetadata(
        lastChanged: now,
        lastConfirmed: confirm ? now : null,
      ),
    );
    
    _cachedProfile ??= UserProfile.empty();
    
    switch (field) {
      case 'currentHealthGoals':
        final currentList = _cachedProfile!.currentHealthGoals ?? [];
        _cachedProfile = _cachedProfile!.copyWith(
          currentHealthGoals: [...currentList, newItem],
        );
        break;
      case 'currentBehavioralHealthSymptoms':
        final currentList = _cachedProfile!.currentBehavioralHealthSymptoms ?? [];
        _cachedProfile = _cachedProfile!.copyWith(
          currentBehavioralHealthSymptoms: [...currentList, newItem],
        );
        break;
      case 'currentInterventions':
        final currentList = _cachedProfile!.currentInterventions ?? [];
        _cachedProfile = _cachedProfile!.copyWith(
          currentInterventions: [...currentList, newItem],
        );
        break;
    }
    
    await saveProfile();
    return newItem.id;
  }

  Future<void> removeArrayItem(String field, String id) async {
    await _ensureInitialized();
    
    _cachedProfile ??= UserProfile.empty();
    
    switch (field) {
      case 'currentHealthGoals':
        final currentList = _cachedProfile!.currentHealthGoals ?? [];
        _cachedProfile = _cachedProfile!.copyWith(
          currentHealthGoals: currentList.where((item) => item.id != id).toList(),
        );
        break;
      case 'currentBehavioralHealthSymptoms':
        final currentList = _cachedProfile!.currentBehavioralHealthSymptoms ?? [];
        _cachedProfile = _cachedProfile!.copyWith(
          currentBehavioralHealthSymptoms: currentList.where((item) => item.id != id).toList(),
        );
        break;
      case 'currentInterventions':
        final currentList = _cachedProfile!.currentInterventions ?? [];
        _cachedProfile = _cachedProfile!.copyWith(
          currentInterventions: currentList.where((item) => item.id != id).toList(),
        );
        break;
    }
    
    await saveProfile();
  }

  Future<void> updateArrayItem(String field, String id, String value, {bool confirm = false}) async {
    await _ensureInitialized();
    
    _cachedProfile ??= UserProfile.empty();
    
    switch (field) {
      case 'currentHealthGoals':
        final currentList = _cachedProfile!.currentHealthGoals ?? [];
        final updatedList = currentList.map((item) {
          if (item.id == id) {
            return item.copyWith(
              value: value,
              metadata: item.metadata.copyWith(
                lastChanged: DateTime.now(),
                lastConfirmed: confirm ? DateTime.now() : item.metadata.lastConfirmed,
              ),
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
            return item.copyWith(
              value: value,
              metadata: item.metadata.copyWith(
                lastChanged: DateTime.now(),
                lastConfirmed: confirm ? DateTime.now() : item.metadata.lastConfirmed,
              ),
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
            return item.copyWith(
              value: value,
              metadata: item.metadata.copyWith(
                lastChanged: DateTime.now(),
                lastConfirmed: confirm ? DateTime.now() : item.metadata.lastConfirmed,
              ),
            );
          }
          return item;
        }).toList();
        _cachedProfile = _cachedProfile!.copyWith(currentInterventions: updatedList);
        break;
    }
    
    await saveProfile();
  }

  Future<void> confirmArrayItem(String field, String id) async {
    await updateArrayItem(field, id, (await _getArrayItemValue(field, id))!, confirm: true);
  }

  Future<String?> _getArrayItemValue(String field, String id) async {
    final items = await getArrayField(field);
    final item = items?.firstWhere((item) => item.id == id, orElse: () => throw StateError('Item not found'));
    return item?.value;
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  bool get isInitialized => _isInitialized;
}