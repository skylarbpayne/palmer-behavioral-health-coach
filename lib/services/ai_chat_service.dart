import 'dart:async';
import '../models/chat_models.dart';
import 'chat_storage_service.dart';
import 'user_profile_service.dart';
import '../fns/extract_symptoms.dart';
import '../fns/suggest_interventions.dart';
import '../fns/reply.dart';

class AiChatService {
  static final AiChatService _instance = AiChatService._internal();
  factory AiChatService() => _instance;
  AiChatService._internal();

  final ChatStorageService _storage = ChatStorageService();
  final UserProfileService _profileService = UserProfileService();

  Future<void> initialize() async {
    try {
      await _storage.initialize();
      
    } catch (e, stackTrace) {
      print('❌ Failed to initialize Gemma AI model: $e');
      print('Stack trace:');
      print(stackTrace);
    }
  }

  Future<ChatMessage> generateResponse(String userMessage) async {
    // Store user message first
    await _storage.addUserMessage(userMessage);

    final userProfile = await _profileService.loadProfile();
  
    print('extracting symptoms');
    final symptoms = await ExtractSymptoms.run({'userMessage': userMessage});
    print('symptoms: $symptoms');
    for (var symptom in symptoms) {
      await _profileService.addArrayItem('currentBehavioralHealthSymptoms', symptom, confirm: true, userId: 'palmerai', reason: 'extracted from user message');
    }

    print('suggesting interventions');
    final interventions = await SuggestInterventions.run({'userMessage': userMessage});
    print('interventions: $interventions');
    for (var intervention in interventions) {
      await _profileService.addArrayItem('currentInterventions', intervention.name, confirm: true, userId: 'palmerai', reason: 'suggested by PALMER');
    }

    print('replying');
    final String responseText = await PalmerReply.run({
      'userMessage': userMessage,
      'userProfile': userProfile,
      'symptoms': symptoms,
      'interventions': interventions,
    });

    // TEMP for testing
    // const responseText = 'This is a test response';
    return await _storage.addCoachResponse(responseText);
  }
  
  Future<List<ChatMessage>> getMessages() async {
    await _storage.initialize();
    return await _storage.getMessages();
  }
  
  Future<void> clearMessages() async {
    await _storage.initialize();
    await _storage.clearMessages();
  }
}