import 'dart:async';
import '../models/chat_models.dart';
import 'chat_storage_service.dart';
import 'user_profile_service.dart';
import '../fns/legacy_palmer.dart';

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

    final String responseText = await PalmerLegacy.run({'userMessage': userMessage});
    return await _storage.addCoachResponse(responseText);
  }
  
  Future<List<ChatMessage>> getRecentMessages({int limit = 50}) async {
    await _storage.initialize();
    return await _storage.getRecentMessages(limit: limit);
  }
  
  Future<void> clearMessages() async {
    await _storage.initialize();
    await _storage.clearMessages();
  }
}