import 'package:uuid/uuid.dart';
import '../models/chat_models.dart';
import 'storage_service.dart';

class ChatStorageService {
  static final ChatStorageService _instance = ChatStorageService._internal();
  factory ChatStorageService() => _instance;
  ChatStorageService._internal();

  final StorageService _storage = StorageService();
  
  static const String _sessionPrefix = 'session_';
  
  final String _currentSessionId = 'default';
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _storage.initialize();
    
    _isInitialized = true;
  }

  Future<ChatMessage> addUserMessage(String text) async {
    await _ensureInitialized();
    
    final message = ChatMessage(
      id: const Uuid().v7(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    
    await _storeMessage(message);
    return message;
  }

  Future<ChatMessage> addCoachResponse(String text) async {
    await _ensureInitialized();
    
    final message = ChatMessage(
      id: const Uuid().v7(),
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
    );
    
    await _storeMessage(message);
    return message;
  }

  Future<List<ChatMessage>> getMessages() async {
    await _ensureInitialized();
    return await _getStoredMessagesForSession(_currentSessionId);
  }

  Future<void> clearMessages() async {
    await _ensureInitialized();
    
    await _storage.remove('$_sessionPrefix$_currentSessionId');
  }


  Future<void> _storeMessage(ChatMessage message) async {
    final existingMessages = await _getStoredMessagesForSession(_currentSessionId);
    existingMessages.add(message);
      
      // Store updated messages
    await _storage.store('$_sessionPrefix$_currentSessionId', {
      'messages': existingMessages.map((m) => m.toJson()).toList(),
      'lastUpdated': DateTime.now().toIso8601String(),
    });
  }

  Future<List<ChatMessage>> _getStoredMessagesForSession(String sessionId) async {
    try {
      // Try encrypted storage first
      final data = await _storage.get('$_sessionPrefix$sessionId');
      if (data != null && data['messages'] != null) {
        return (data['messages'] as List)
            .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      // Fall back to unencrypted storage
    }
    
    // Try unencrypted storage
    final data = await _storage.get('$_sessionPrefix$sessionId');
    if (data != null && data['messages'] != null) {
      return (data['messages'] as List)
          .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    
    return [];
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  bool get isInitialized => _isInitialized;
}