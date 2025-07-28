import 'package:uuid/uuid.dart';

class FieldMetadata {
  final DateTime createdAt;
  final DateTime lastModified;
  final DateTime? lastConfirmed;
  final DateTime? deletedAt;
  final String? createdBy;
  final String? modifiedBy;
  final String? deletedBy;
  final String? reason;
  final int version;
  final String? changeContext;
  final Map<String, dynamic>? additionalMetadata;

  FieldMetadata({
    required this.createdAt,
    required this.lastModified,
    this.lastConfirmed,
    this.deletedAt,
    this.createdBy,
    this.modifiedBy,
    this.deletedBy,
    this.reason,
    this.version = 1,
    this.changeContext,
    this.additionalMetadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'lastConfirmed': lastConfirmed?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'createdBy': createdBy,
      'modifiedBy': modifiedBy,
      'deletedBy': deletedBy,
      'reason': reason,
      'version': version,
      'changeContext': changeContext,
      'additionalMetadata': additionalMetadata,
    };
  }

  factory FieldMetadata.fromJson(Map<String, dynamic> json) {
    return FieldMetadata(
      createdAt: DateTime.parse(json['createdAt']),
      lastModified: DateTime.parse(json['lastModified']),
      lastConfirmed: json['lastConfirmed'] != null 
          ? DateTime.parse(json['lastConfirmed']) 
          : null,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'])
          : null,
      createdBy: json['createdBy'],
      modifiedBy: json['modifiedBy'],
      deletedBy: json['deletedBy'],
      reason: json['reason'],
      version: json['version'] ?? 1,
      changeContext: json['changeContext'],
      additionalMetadata: json['additionalMetadata'] != null
          ? Map<String, dynamic>.from(json['additionalMetadata'])
          : null,
    );
  }

  FieldMetadata copyWith({
    DateTime? createdAt,
    DateTime? lastModified,
    DateTime? lastConfirmed,
    DateTime? deletedAt,
    String? createdBy,
    String? modifiedBy,
    String? deletedBy,
    String? reason,
    int? version,
    String? changeContext,
    Map<String, dynamic>? additionalMetadata,
    bool clearDeletedAt = false,
  }) {
    return FieldMetadata(
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      lastConfirmed: lastConfirmed ?? this.lastConfirmed,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      createdBy: createdBy ?? this.createdBy,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      deletedBy: deletedBy ?? this.deletedBy,
      reason: reason ?? this.reason,
      version: version ?? this.version,
      changeContext: changeContext ?? this.changeContext,
      additionalMetadata: additionalMetadata ?? this.additionalMetadata,
    );
  }

  // Convenience getters for backward compatibility
  DateTime get lastChanged => lastModified;

  // Audit helper methods
  bool get isDeleted => deletedAt != null;
  bool get isActive => !isDeleted;

  FieldMetadata markDeleted({
    String? deletedBy,
    String? reason,
    String? changeContext,
  }) {
    return copyWith(
      deletedAt: DateTime.now(),
      deletedBy: deletedBy,
      reason: reason,
      changeContext: changeContext,
      version: version + 1,
    );
  }

  FieldMetadata restore({
    String? modifiedBy,
    String? reason,
    String? changeContext,
  }) {
    return copyWith(
      lastModified: DateTime.now(),
      modifiedBy: modifiedBy,
      reason: reason,
      changeContext: changeContext,
      version: version + 1,
      clearDeletedAt: true,
      deletedBy: null,
    );
  }

  FieldMetadata updateVersion({
    String? modifiedBy,
    String? reason,
    String? changeContext,
    Map<String, dynamic>? additionalMetadata,
  }) {
    return copyWith(
      lastModified: DateTime.now(),
      modifiedBy: modifiedBy,
      reason: reason,
      changeContext: changeContext,
      version: version + 1,
      additionalMetadata: additionalMetadata,
    );
  }
}

class ProfileField<T> {
  final T value;
  final FieldMetadata metadata;

  ProfileField({
    required this.value,
    required this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'metadata': metadata.toJson(),
    };
  }

  factory ProfileField.fromJson(Map<String, dynamic> json) {
    return ProfileField<T>(
      value: json['value'] as T,
      metadata: FieldMetadata.fromJson(json['metadata']),
    );
  }

  ProfileField<T> copyWith({
    T? value,
    FieldMetadata? metadata,
  }) {
    return ProfileField<T>(
      value: value ?? this.value,
      metadata: metadata ?? this.metadata,
    );
  }

  static ProfileField<T> create<T>(T value, {
    String? createdBy,
    String? reason,
    String? changeContext,
  }) {
    final now = DateTime.now();
    return ProfileField<T>(
      value: value,
      metadata: FieldMetadata(
        createdAt: now,
        lastModified: now,
        createdBy: createdBy ?? 'system',
        modifiedBy: createdBy ?? 'system',
        reason: reason,
        changeContext: changeContext,
      ),
    );
  }

  // Soft delete support
  bool get isDeleted => metadata.isDeleted;
  bool get isActive => metadata.isActive;

  ProfileField<T> withNewValue(T newValue, {
    String? userId,
    String? reason,
    String? changeContext,
    bool confirm = false,
  }) {
    return ProfileField<T>(
      value: newValue,
      metadata: metadata.updateVersion(
        modifiedBy: userId,
        reason: reason,
        changeContext: changeContext,
      ).copyWith(
        lastConfirmed: confirm ? DateTime.now() : null,
      ),
    );
  }

  ProfileField<T> markDeleted({
    String? userId,
    String? reason,
    String? changeContext,
  }) {
    return ProfileField<T>(
      value: value,
      metadata: metadata.markDeleted(
        deletedBy: userId,
        reason: reason,
        changeContext: changeContext,
      ),
    );
  }

  ProfileField<T> restore({
    String? userId,
    String? reason,
    String? changeContext,
  }) {
    return ProfileField<T>(
      value: value,
      metadata: metadata.restore(
        modifiedBy: userId,
        reason: reason,
        changeContext: changeContext,
      ),
    );
  }

  ProfileField<T> confirmValue({
    String? userId,
    String? reason,
    String? changeContext,
  }) {
    return ProfileField<T>(
      value: value,
      metadata: metadata.copyWith(
        lastConfirmed: DateTime.now(),
        lastModified: DateTime.now(),
        modifiedBy: userId,
        reason: reason,
        changeContext: changeContext,
        version: metadata.version + 1,
      ),
    );
  }
}

class ProfileArrayItem<T> {
  final T value;
  final String id;
  final FieldMetadata metadata;

  ProfileArrayItem({
    required this.value,
    required this.id,
    required this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'id': id,
      'metadata': metadata.toJson(),
    };
  }

  factory ProfileArrayItem.fromJson(Map<String, dynamic> json) {
    return ProfileArrayItem<T>(
      value: json['value'] as T,
      id: json['id'],
      metadata: FieldMetadata.fromJson(json['metadata']),
    );
  }

  ProfileArrayItem<T> copyWith({
    T? value,
    String? id,
    FieldMetadata? metadata,
  }) {
    return ProfileArrayItem<T>(
      value: value ?? this.value,
      id: id ?? this.id,
      metadata: metadata ?? this.metadata,
    );
  }

  static ProfileArrayItem<T> create<T>(T value, {
    String? createdBy,
    String? reason,
    String? changeContext,
  }) {
    final now = DateTime.now();
    return ProfileArrayItem<T>(
      value: value,
      id: const Uuid().v7(),
      metadata: FieldMetadata(
        createdAt: now,
        lastModified: now,
        createdBy: createdBy ?? 'system',
        modifiedBy: createdBy ?? 'system',
        reason: reason,
        changeContext: changeContext,
      ),
    );
  }

  // Soft delete support
  bool get isDeleted => metadata.isDeleted;
  bool get isActive => metadata.isActive;

  ProfileArrayItem<T> withNewValue(T newValue, {
    String? userId,
    String? reason,
    String? changeContext,
    bool confirm = false,
  }) {
    return ProfileArrayItem<T>(
      value: newValue,
      id: id,
      metadata: metadata.updateVersion(
        modifiedBy: userId,
        reason: reason,
        changeContext: changeContext,
      ).copyWith(
        lastConfirmed: confirm ? DateTime.now() : null,
      ),
    );
  }

  ProfileArrayItem<T> markDeleted({
    String? userId,
    String? reason,
    String? changeContext,
  }) {
    return ProfileArrayItem<T>(
      value: value,
      id: id,
      metadata: metadata.markDeleted(
        deletedBy: userId,
        reason: reason,
        changeContext: changeContext,
      ),
    );
  }

  ProfileArrayItem<T> restore({
    String? userId,
    String? reason,
    String? changeContext,
  }) {
    return ProfileArrayItem<T>(
      value: value,
      id: id,
      metadata: metadata.restore(
        modifiedBy: userId,
        reason: reason,
        changeContext: changeContext,
      ),
    );
  }

  ProfileArrayItem<T> confirmValue({
    String? userId,
    String? reason,
    String? changeContext,
  }) {
    return ProfileArrayItem<T>(
      value: value,
      id: id,
      metadata: metadata.copyWith(
        lastConfirmed: DateTime.now(),
        lastModified: DateTime.now(),
        modifiedBy: userId,
        reason: reason,
        changeContext: changeContext,
        version: metadata.version + 1,
      ),
    );
  }
}

class UserProfile {
  ProfileField<String>? firstName;
  ProfileField<String>? lastName;
  ProfileField<String>? sex; // 'male' | 'female' | 'intersex'
  ProfileField<String>? gender;
  ProfileField<String>? dateOfBirth;
  ProfileField<String>? sexualOrientation;
  List<ProfileArrayItem<String>>? currentHealthGoals;
  List<ProfileArrayItem<String>>? currentBehavioralHealthSymptoms;
  List<ProfileArrayItem<String>>? currentInterventions;

  UserProfile({
    this.firstName,
    this.lastName,
    this.sex,
    this.gender,
    this.dateOfBirth,
    this.sexualOrientation,
    this.currentHealthGoals,
    this.currentBehavioralHealthSymptoms,
    this.currentInterventions,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName?.toJson(),
      'lastName': lastName?.toJson(),
      'sex': sex?.toJson(),
      'gender': gender?.toJson(),
      'dateOfBirth': dateOfBirth?.toJson(),
      'sexualOrientation': sexualOrientation?.toJson(),
      'currentHealthGoals': currentHealthGoals?.map((item) => item.toJson()).toList(),
      'currentBehavioralHealthSymptoms': currentBehavioralHealthSymptoms?.map((item) => item.toJson()).toList(),
      'currentInterventions': currentInterventions?.map((item) => item.toJson()).toList(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      firstName: json['firstName'] != null 
          ? ProfileField<String>.fromJson(json['firstName'])
          : null,
      lastName: json['lastName'] != null 
          ? ProfileField<String>.fromJson(json['lastName'])
          : null,
      sex: json['sex'] != null 
          ? ProfileField<String>.fromJson(json['sex'])
          : null,
      gender: json['gender'] != null 
          ? ProfileField<String>.fromJson(json['gender'])
          : null,
      dateOfBirth: json['dateOfBirth'] != null 
          ? ProfileField<String>.fromJson(json['dateOfBirth'])
          : null,
      sexualOrientation: json['sexualOrientation'] != null 
          ? ProfileField<String>.fromJson(json['sexualOrientation'])
          : null,
      currentHealthGoals: json['currentHealthGoals'] != null
          ? (json['currentHealthGoals'] as List)
              .map((item) => ProfileArrayItem<String>.fromJson(item))
              .toList()
          : null,
      currentBehavioralHealthSymptoms: json['currentBehavioralHealthSymptoms'] != null
          ? (json['currentBehavioralHealthSymptoms'] as List)
              .map((item) => ProfileArrayItem<String>.fromJson(item))
              .toList()
          : null,
      currentInterventions: json['currentInterventions'] != null
          ? (json['currentInterventions'] as List)
              .map((item) => ProfileArrayItem<String>.fromJson(item))
              .toList()
          : null,
    );
  }

  UserProfile copyWith({
    ProfileField<String>? firstName,
    ProfileField<String>? lastName,
    ProfileField<String>? sex,
    ProfileField<String>? gender,
    ProfileField<String>? dateOfBirth,
    ProfileField<String>? sexualOrientation,
    List<ProfileArrayItem<String>>? currentHealthGoals,
    List<ProfileArrayItem<String>>? currentBehavioralHealthSymptoms,
    List<ProfileArrayItem<String>>? currentInterventions,
  }) {
    return UserProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      sex: sex ?? this.sex,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      sexualOrientation: sexualOrientation ?? this.sexualOrientation,
      currentHealthGoals: currentHealthGoals ?? this.currentHealthGoals,
      currentBehavioralHealthSymptoms: currentBehavioralHealthSymptoms ?? this.currentBehavioralHealthSymptoms,
      currentInterventions: currentInterventions ?? this.currentInterventions,
    );
  }

  static UserProfile empty() {
    return UserProfile();
  }

  String get displayName {
    final first = firstName?.isActive == true ? firstName!.value : '';
    final last = lastName?.isActive == true ? lastName!.value : '';
    if (first.isEmpty && last.isEmpty) return 'User';
    return '$first $last'.trim();
  }

  bool get hasBasicInfo {
    return (firstName?.isActive == true) || (lastName?.isActive == true);
  }

  // Convenience methods for working with active array items
  List<ProfileArrayItem<String>> getActiveHealthGoals() {
    return currentHealthGoals?.where((item) => item.isActive).toList() ?? [];
  }

  List<ProfileArrayItem<String>> getActiveBehavioralHealthSymptoms() {
    return currentBehavioralHealthSymptoms?.where((item) => item.isActive).toList() ?? [];
  }

  List<ProfileArrayItem<String>> getActiveInterventions() {
    return currentInterventions?.where((item) => item.isActive).toList() ?? [];
  }

  // Convenience methods for working with deleted array items
  List<ProfileArrayItem<String>> getDeletedHealthGoals() {
    return currentHealthGoals?.where((item) => item.isDeleted).toList() ?? [];
  }

  List<ProfileArrayItem<String>> getDeletedBehavioralHealthSymptoms() {
    return currentBehavioralHealthSymptoms?.where((item) => item.isDeleted).toList() ?? [];
  }

  List<ProfileArrayItem<String>> getDeletedInterventions() {
    return currentInterventions?.where((item) => item.isDeleted).toList() ?? [];
  }

  // Helper method to check if a simple field is active
  bool isFieldActive(String fieldName) {
    switch (fieldName) {
      case 'firstName':
        return firstName?.isActive ?? false;
      case 'lastName':
        return lastName?.isActive ?? false;
      case 'sex':
        return sex?.isActive ?? false;
      case 'gender':
        return gender?.isActive ?? false;
      case 'dateOfBirth':
        return dateOfBirth?.isActive ?? false;
      case 'sexualOrientation':
        return sexualOrientation?.isActive ?? false;
      default:
        return false;
    }
  }

  // Helper method to get active value for a simple field
  T? getActiveFieldValue<T>(String fieldName) {
    switch (fieldName) {
      case 'firstName':
        return firstName?.isActive == true ? firstName!.value as T : null;
      case 'lastName':
        return lastName?.isActive == true ? lastName!.value as T : null;
      case 'sex':
        return sex?.isActive == true ? sex!.value as T : null;
      case 'gender':
        return gender?.isActive == true ? gender!.value as T : null;
      case 'dateOfBirth':
        return dateOfBirth?.isActive == true ? dateOfBirth!.value as T : null;
      case 'sexualOrientation':
        return sexualOrientation?.isActive == true ? sexualOrientation!.value as T : null;
      default:
        return null;
    }
  }
}