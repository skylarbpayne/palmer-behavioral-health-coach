import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/user_profile_service.dart';
import '../widgets/profile_field_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserProfileService _profileService = UserProfileService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  bool _isLoading = true;
  bool _isSaving = false;
  UserProfile _profile = UserProfile.empty();

  // Form field values
  String _firstName = '';
  String _lastName = '';
  String? _sex;
  String _gender = '';
  String _dateOfBirth = '';
  String _sexualOrientation = '';
  List<String> _healthGoals = [];
  List<String> _symptoms = [];
  List<String> _interventions = [];

  final List<String> _sexOptions = ['male', 'female', 'intersex'];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      await _profileService.initialize();
      final profile = await _profileService.loadProfile();
      
      setState(() {
        _profile = profile;
        _firstName = profile.firstName?.isActive == true ? profile.firstName!.value : '';
        _lastName = profile.lastName?.isActive == true ? profile.lastName!.value : '';
        _sex = profile.sex?.isActive == true ? profile.sex!.value : null;
        _gender = profile.gender?.isActive == true ? profile.gender!.value : '';
        _dateOfBirth = profile.dateOfBirth?.isActive == true ? profile.dateOfBirth!.value : '';
        _sexualOrientation = profile.sexualOrientation?.isActive == true ? profile.sexualOrientation!.value : '';
        _healthGoals = profile.getActiveHealthGoals().map((item) => item.value).toList();
        _symptoms = profile.getActiveBehavioralHealthSymptoms().map((item) => item.value).toList();
        _interventions = profile.getActiveInterventions().map((item) => item.value).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load profile'),
            backgroundColor: Color(0xFFFF5722),
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isSaving = true;
    });

    try {
      // Update simple fields with audit context
      if (_firstName.isNotEmpty) {
        await _profileService.updateSimpleField(
          'firstName', 
          _firstName,
          userId: 'user',
          reason: 'profile_update',
          changeContext: 'profile_screen',
        );
      }
      if (_lastName.isNotEmpty) {
        await _profileService.updateSimpleField(
          'lastName', 
          _lastName,
          userId: 'user',
          reason: 'profile_update',
          changeContext: 'profile_screen',
        );
      }
      if (_sex != null) {
        await _profileService.updateSimpleField(
          'sex', 
          _sex!,
          userId: 'user',
          reason: 'profile_update',
          changeContext: 'profile_screen',
        );
      }
      if (_gender.isNotEmpty) {
        await _profileService.updateSimpleField(
          'gender', 
          _gender,
          userId: 'user',
          reason: 'profile_update',
          changeContext: 'profile_screen',
        );
      }
      if (_dateOfBirth.isNotEmpty) {
        await _profileService.updateSimpleField(
          'dateOfBirth', 
          _dateOfBirth,
          userId: 'user',
          reason: 'profile_update',
          changeContext: 'profile_screen',
        );
      }
      if (_sexualOrientation.isNotEmpty) {
        await _profileService.updateSimpleField(
          'sexualOrientation', 
          _sexualOrientation,
          userId: 'user',
          reason: 'profile_update',
          changeContext: 'profile_screen',
        );
      }

      // Update array fields - soft delete current items and add new ones
      // Health Goals
      final currentGoals = await _profileService.getActiveArrayField('currentHealthGoals') ?? [];
      for (final goal in currentGoals) {
        await _profileService.softDeleteArrayItem(
          'currentHealthGoals', 
          goal.id,
          userId: 'user',
          reason: 'profile_update_clear',
          changeContext: 'profile_screen',
        );
      }
      for (final goal in _healthGoals) {
        await _profileService.addArrayItem(
          'currentHealthGoals', 
          goal,
          userId: 'user',
          reason: 'profile_update_add',
          changeContext: 'profile_screen',
        );
      }

      // Symptoms
      final currentSymptoms = await _profileService.getActiveArrayField('currentBehavioralHealthSymptoms') ?? [];
      for (final symptom in currentSymptoms) {
        await _profileService.softDeleteArrayItem(
          'currentBehavioralHealthSymptoms', 
          symptom.id,
          userId: 'user',
          reason: 'profile_update_clear',
          changeContext: 'profile_screen',
        );
      }
      for (final symptom in _symptoms) {
        await _profileService.addArrayItem(
          'currentBehavioralHealthSymptoms', 
          symptom,
          userId: 'user',
          reason: 'profile_update_add',
          changeContext: 'profile_screen',
        );
      }

      // Interventions
      final currentInterventions = await _profileService.getActiveArrayField('currentInterventions') ?? [];
      for (final intervention in currentInterventions) {
        await _profileService.softDeleteArrayItem(
          'currentInterventions', 
          intervention.id,
          userId: 'user',
          reason: 'profile_update_clear',
          changeContext: 'profile_screen',
        );
      }
      for (final intervention in _interventions) {
        await _profileService.addArrayItem(
          'currentInterventions', 
          intervention,
          userId: 'user',
          reason: 'profile_update_add',
          changeContext: 'profile_screen',
        );
      }

      setState(() {
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile saved successfully'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save profile'),
            backgroundColor: Color(0xFFFF5722),
          ),
        );
      }
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 2,
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _isSaving ? null : _saveProfile,
              child: Text(
                _isSaving ? 'Saving...' : 'Save',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading profile...',
                    style: TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Personal Information Section
                  const Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  ProfileFieldWidget(
                    label: 'First Name',
                    value: _firstName,
                    onChanged: (value) => setState(() => _firstName = value),
                    hintText: 'Enter your first name',
                    required: true,
                    validator: _validateName,
                  ),
                  const SizedBox(height: 16),
                  
                  ProfileFieldWidget(
                    label: 'Last Name',
                    value: _lastName,
                    onChanged: (value) => setState(() => _lastName = value),
                    hintText: 'Enter your last name',
                    required: true,
                    validator: _validateName,
                  ),
                  const SizedBox(height: 16),
                  
                  ProfileDropdownWidget(
                    label: 'Sex',
                    value: _sex,
                    options: _sexOptions,
                    onChanged: (value) => setState(() => _sex = value),
                    hintText: 'Select your sex',
                  ),
                  const SizedBox(height: 16),
                  
                  ProfileFieldWidget(
                    label: 'Gender',
                    value: _gender,
                    onChanged: (value) => setState(() => _gender = value),
                    hintText: 'Enter your gender identity',
                  ),
                  const SizedBox(height: 16),
                  
                  ProfileFieldWidget(
                    label: 'Date of Birth',
                    value: _dateOfBirth,
                    onChanged: (value) => setState(() => _dateOfBirth = value),
                    hintText: 'YYYY-MM-DD',
                    keyboardType: TextInputType.datetime,
                  ),
                  const SizedBox(height: 16),
                  
                  ProfileFieldWidget(
                    label: 'Sexual Orientation',
                    value: _sexualOrientation,
                    onChanged: (value) => setState(() => _sexualOrientation = value),
                    hintText: 'Enter your sexual orientation',
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Health Information Section
                  const Text(
                    'Health Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  ProfileArrayWidget(
                    label: 'Current Health Goals',
                    items: _healthGoals,
                    onChanged: (items) => setState(() => _healthGoals = items),
                    addButtonText: 'Add Goal',
                    hintText: 'Enter a health goal',
                  ),
                  const SizedBox(height: 24),
                  
                  ProfileArrayWidget(
                    label: 'Current Symptoms',
                    items: _symptoms,
                    onChanged: (items) => setState(() => _symptoms = items),
                    addButtonText: 'Add Symptom',
                    hintText: 'Enter a symptom',
                  ),
                  const SizedBox(height: 24),
                  
                  ProfileArrayWidget(
                    label: 'Current Interventions',
                    items: _interventions,
                    onChanged: (items) => setState(() => _interventions = items),
                    addButtonText: 'Add Intervention',
                    hintText: 'Enter an intervention or coping strategy',
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Save Button (Mobile-friendly)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Save Profile'),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}