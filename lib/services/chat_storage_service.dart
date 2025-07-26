import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/chat_models.dart';
import 'storage_service.dart';
import 'encryption_service.dart';

class ChatStorageService {
  static final ChatStorageService _instance = ChatStorageService._internal();
  factory ChatStorageService() => _instance;
  ChatStorageService._internal();

  final StorageService _storage = StorageService();
  final EncryptionService _encryption = EncryptionService();
  
  static const String _messagesKey = 'chat_messages';
  static const String _currentSessionKey = 'current_session_id';
  static const String _sessionsKey = 'chat_sessions';
  static const String _sessionPrefix = 'session_';
  
  String _currentSessionId = 'default';
  List<ChatMessage> _cachedMessages = [];
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _storage.initialize();
    
    // Get or create current session
    _currentSessionId = await _storage.get<String>(_currentSessionKey) ?? 'default';
    
    // Load cached messages for current session
    await _loadMessagesFromStorage();
    
    _isInitialized = true;
  }

  Future<ChatMessage> addUserMessage(String text) async {
    await _ensureInitialized();
    
    final message = ChatMessage(
      id: const Uuid().v4(),
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
      id: const Uuid().v4(),
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
    );
    
    await _storeMessage(message);
    return message;
  }

  Future<List<ChatMessage>> getRecentMessages({int limit = 50}) async {
    await _ensureInitialized();
    
    if (_cachedMessages.length <= limit) {
      return List.from(_cachedMessages);
    }
    
    return _cachedMessages.skip(_cachedMessages.length - limit).toList();
  }

  Future<List<ChatMessage>> getAllMessages() async {
    await _ensureInitialized();
    return List.from(_cachedMessages);
  }

  Future<void> clearMessages() async {
    await _ensureInitialized();
    
    _cachedMessages.clear();
    await _storage.remove('${_sessionPrefix}$_currentSessionId');
    await _updateSessionMessageCount(0);
  }

  Future<void> clearAllSessions() async {
    await _ensureInitialized();
    
    final sessions = await getSessions();
    for (final session in sessions) {
      await _storage.remove('${_sessionPrefix}${session.id}');
    }
    
    _cachedMessages.clear();
    await _storage.remove(_sessionsKey);
    await _storage.remove(_currentSessionKey);
    
    _currentSessionId = 'default';
  }

  Future<ChatSession> createSession(String name) async {
    await _ensureInitialized();
    
    final sessionId = const Uuid().v4();
    final session = ChatSession(
      id: sessionId,
      name: name,
      createdAt: DateTime.now(),
      lastActivity: DateTime.now(),
    );
    
    // Save session
    await _saveSession(session);
    
    // Switch to new session
    _currentSessionId = sessionId;
    await _storage.store(_currentSessionKey, sessionId);
    
    // Clear cached messages for new session
    _cachedMessages.clear();
    
    return session;
  }

  Future<List<ChatSession>> getSessions() async {
    await _ensureInitialized();
    
    final sessionsData = await _storage.get<List<dynamic>>(_sessionsKey);
    if (sessionsData == null) return [];
    
    return sessionsData
        .map((data) => ChatSession.fromJson(data as Map<String, dynamic>))
        .toList();
  }

  Future<void> switchToSession(String sessionId) async {
    await _ensureInitialized();
    
    if (_currentSessionId == sessionId) return;
    
    _currentSessionId = sessionId;
    await _storage.store(_currentSessionKey, sessionId);
    await _loadMessagesFromStorage();
  }

  String get currentSessionId => _currentSessionId;

  Future<void> _storeMessage(ChatMessage message) async {
    _cachedMessages.add(message);
    
    try {
      // Encrypt the message text
      final encryptedContent = await _encryption.encrypt(message.text);
      
      // Create stored message with encrypted content
      final storedMessage = StoredChatMessage.fromChatMessage(
        message,
        encryptedContent: encryptedContent,
        sessionId: _currentSessionId,
      );
      
      // Get existing messages for this session
      final existingMessages = await _getStoredMessagesForSession(_currentSessionId);
      existingMessages.add(storedMessage);
      
      // Store updated messages
      await _storage.storeSecure('${_sessionPrefix}$_currentSessionId', {
        'messages': existingMessages.map((m) => m.toJson()).toList(),
        'lastUpdated': DateTime.now().toIso8601String(),
      });
      
      // Update session
      await _updateSessionActivity();
      
    } catch (e) {
      // Fallback to unencrypted storage if encryption fails
      final storedMessage = StoredChatMessage.fromChatMessage(
        message,
        sessionId: _currentSessionId,
      );
      
      final existingMessages = await _getStoredMessagesForSession(_currentSessionId);
      existingMessages.add(storedMessage);
      
      await _storage.store('${_sessionPrefix}$_currentSessionId', {
        'messages': existingMessages.map((m) => m.toJson()).toList(),
        'lastUpdated': DateTime.now().toIso8601String(),
      });
      
      await _updateSessionActivity();
    }
  }

  Future<List<StoredChatMessage>> _getStoredMessagesForSession(String sessionId) async {
    try {
      // Try encrypted storage first
      final data = await _storage.getSecure('${_sessionPrefix}$sessionId');
      if (data != null && data['messages'] != null) {
        return (data['messages'] as List)
            .map((json) => StoredChatMessage.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      // Fall back to unencrypted storage
    }
    
    // Try unencrypted storage
    final data = await _storage.get<Map<String, dynamic>>('${_sessionPrefix}$sessionId');
    if (data != null && data['messages'] != null) {
      return (data['messages'] as List)
          .map((json) => StoredChatMessage.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    
    return [];
  }

  Future<void> _loadMessagesFromStorage() async {
    final storedMessages = await _getStoredMessagesForSession(_currentSessionId);
    
    _cachedMessages.clear();
    
    for (final storedMessage in storedMessages) {
      String messageText = storedMessage.text;
      
      // Try to decrypt if message was encrypted
      if (storedMessage.metadata.encrypted && storedMessage.encryptedContent != null) {
        try {
          messageText = await _encryption.decrypt(storedMessage.encryptedContent!);
        } catch (e) {
          // Use original text if decryption fails
          messageText = storedMessage.text;
        }
      }
      
      _cachedMessages.add(ChatMessage(
        id: storedMessage.id,
        text: messageText,
        isUser: storedMessage.isUser,
        timestamp: storedMessage.timestamp,
      ));
    }
  }

  Future<void> _saveSession(ChatSession session) async {
    final sessions = await getSessions();
    final existingIndex = sessions.indexWhere((s) => s.id == session.id);
    
    if (existingIndex >= 0) {
      sessions[existingIndex] = session;
    } else {
      sessions.add(session);
    }
    
    await _storage.store(_sessionsKey, sessions.map((s) => s.toJson()).toList());
  }

  Future<void> _updateSessionActivity() async {
    final sessions = await getSessions();
    final sessionIndex = sessions.indexWhere((s) => s.id == _currentSessionId);
    
    if (sessionIndex >= 0) {
      final updatedSession = sessions[sessionIndex].copyWith(
        lastActivity: DateTime.now(),
        messageCount: _cachedMessages.length,
      );
      await _saveSession(updatedSession);
    } else {
      // Create default session if it doesn't exist
      final defaultSession = ChatSession(
        id: _currentSessionId,
        name: 'Chat Session',
        createdAt: DateTime.now(),
        lastActivity: DateTime.now(),
        messageCount: _cachedMessages.length,
      );
      await _saveSession(defaultSession);
    }
  }

  Future<void> _updateSessionMessageCount(int count) async {
    final sessions = await getSessions();
    final sessionIndex = sessions.indexWhere((s) => s.id == _currentSessionId);
    
    if (sessionIndex >= 0) {
      final updatedSession = sessions[sessionIndex].copyWith(
        messageCount: count,
        lastActivity: DateTime.now(),
      );
      await _saveSession(updatedSession);
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  bool get isInitialized => _isInitialized;
}