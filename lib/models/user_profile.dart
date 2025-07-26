import 'package:uuid/uuid.dart';

class FieldMetadata {
  final DateTime lastChanged;
  final DateTime? lastConfirmed;

  FieldMetadata({
    required this.lastChanged,
    this.lastConfirmed,
  });

  Map<String, dynamic> toJson() {
    return {
      'lastChanged': lastChanged.toIso8601String(),
      'lastConfirmed': lastConfirmed?.toIso8601String(),
    };
  }

  factory FieldMetadata.fromJson(Map<String, dynamic> json) {
    return FieldMetadata(
      lastChanged: DateTime.parse(json['lastChanged']),
      lastConfirmed: json['lastConfirmed'] != null 
          ? DateTime.parse(json['lastConfirmed']) 
          : null,
    );
  }

  FieldMetadata copyWith({
    DateTime? lastChanged,
    DateTime? lastConfirmed,
  }) {
    return FieldMetadata(
      lastChanged: lastChanged ?? this.lastChanged,
      lastConfirmed: lastConfirmed ?? this.lastConfirmed,
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

  static ProfileField<T> create<T>(T value) {
    return ProfileField<T>(
      value: value,
      metadata: FieldMetadata(lastChanged: DateTime.now()),
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

  static ProfileArrayItem<T> create<T>(T value) {
    return ProfileArrayItem<T>(
      value: value,
      id: const Uuid().v4(),
      metadata: FieldMetadata(lastChanged: DateTime.now()),
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
    final first = firstName?.value ?? '';
    final last = lastName?.value ?? '';
    if (first.isEmpty && last.isEmpty) return 'User';
    return '$first $last'.trim();
  }

  bool get hasBasicInfo {
    return firstName != null || lastName != null;
  }
}