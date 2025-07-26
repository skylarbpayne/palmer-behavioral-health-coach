import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/chat_models.dart';
import 'chat_storage_service.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma/core/model.dart';
import 'package:flutter_gemma/pigeon.g.dart';

class AiChatService {
  static final AiChatService _instance = AiChatService._internal();
  factory AiChatService() => _instance;
  AiChatService._internal();

  final FlutterGemmaPlugin _gemma = FlutterGemmaPlugin.instance;
  final ChatStorageService _storage = ChatStorageService();
  InferenceChat? chat;
  bool _isInitialized = false;
  bool _isInitializing = false;

  final String _systemPrompt = """You are an expert behavioral health coach named PALMER. 
Your primary role is to support users in their mental health and behavioral wellness journey through compassionate, evidence-based guidance.

Core responsibilities:
1. Profile management and personalization
2. Supportive engagement with empathy
3. Constructive challenge when appropriate
4. Symptom observation and pattern recognition
5. Evidence-based intervention suggestions

Communication style: Warm, professional, curious, respectful. Keep responses concise but meaningful.""";

  Future<void> initialize() async {
    if (_isInitialized || _isInitializing) {
      return;
    }

    _isInitializing = true;
    
    try {
      await _storage.initialize();
      await _initializeModel();
      _isInitialized = true;
      print('✅ Gemma AI model initialized successfully');
      
    } catch (e, stackTrace) {
      print('❌ Failed to initialize Gemma AI model: $e');
      print('Stack trace:');
      print(stackTrace);
      _isInitialized = false;
      chat = null;
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> _initializeModel() async {
    print('Starting model initialization...');
    
    final completer = Completer<void>();
    
    // Install model from assets
    _gemma.modelManager.installModelFromAssetWithProgress('models/gemma-3n-E2B-it-int4.task').listen(
      (progress) {
        print('Loading progress: $progress%');
      },
      onDone: () async {
        try {
          print('Model loading complete.');
          
          // Create model with specific configurations
          print('Creating model instance...');
          print('Available memory before model creation: ${_getAvailableMemoryInfo()}');
          
          // Try different model configurations if needed
          InferenceModel? model;
          try {
            print('Attempting model creation with GPU backend...');
            model = await _gemma.createModel(
              modelType: ModelType.gemmaIt,
              preferredBackend: PreferredBackend.gpu,
              maxTokens: 512,
              supportImage: false,
            );
          } catch (e) {
            print('GPU backend failed: $e');
            print('Falling back to CPU backend...');
            try {
              model = await _gemma.createModel(
                modelType: ModelType.gemmaIt,
                preferredBackend: PreferredBackend.cpu,
                maxTokens: 256,  // Reduced tokens for CPU
                supportImage: false,
              );
            } catch (cpuError) {
              print('CPU backend also failed: $cpuError');
              print('Trying minimal model configuration...');
              model = await _gemma.createModel(
                modelType: ModelType.gemmaIt,
                maxTokens: 128,  // Minimal tokens
                supportImage: false,
              );
            }
          }
          
          print('Model created successfully.');
          print('Available memory after model creation: ${_getAvailableMemoryInfo()}');

          // Try creating chat with progressively minimal parameters
          print('Creating chat instance - attempting different configurations...');
          
          final configs = [
            {'name': 'Original', 'topK': 40, 'topP': 0.95, 'tokenBuffer': 256},
            {'name': 'Reduced', 'topK': 20, 'topP': 0.9, 'tokenBuffer': 128},
            {'name': 'Minimal', 'topK': 10, 'topP': 0.8, 'tokenBuffer': 64},
            {'name': 'Ultra-minimal', 'topK': 5, 'topP': 0.7, 'tokenBuffer': 32},
          ];
          
          Exception? lastError;
          for (final config in configs) {
            try {
              print('Trying ${config['name']} configuration: topK=${config['topK']}, topP=${config['topP']}, tokenBuffer=${config['tokenBuffer']}');
              
              chat = await model.createChat(
                temperature: 0.7,
                randomSeed: 1,
                topK: config['topK'] as int,
                topP: config['topP'] as double,
                tokenBuffer: config['tokenBuffer'] as int,
                supportImage: false,
                supportsFunctionCalls: false,
              );
              
              print('✅ Success with ${config['name']} configuration');
              break;
              
            } catch (e) {
              lastError = e is Exception ? e : Exception(e.toString());
              print('❌ Failed with ${config['name']} configuration: $e');
              
              // If this is the last config, try absolute minimum
              if (config == configs.last) {
                print('Attempting bare minimum chat creation...');
                try {
                  chat = await model.createChat();
                  print('✅ Success with default parameters');
                  break;
                } catch (finalError) {
                  print('❌ Even default parameters failed: $finalError');
                  throw Exception('All chat creation attempts failed. Last error: $lastError');
                }
              }
            }
          }
          
          print('Chat instance created successfully.');
          completer.complete();
        } catch (e, stackTrace) {
          print('Error during model/chat creation:');
          print('Error: $e');
          print('Stack trace: $stackTrace');
          completer.completeError(e);
        }
      },
      onError: (error, stackTrace) {
        print('Error loading model from assets:');
        print('Error: $error');
        if (stackTrace != null) {
          print('Stack trace: $stackTrace');
        }
        completer.completeError(Exception('Failed to load model from assets: $error'));
      },
    );
    
    return completer.future;
  }

  bool isReady() {
    return _isInitialized && chat != null;
  }

  Future<ChatMessage> generateResponse(String userMessage) async {
    // Store user message first
    await _storage.addUserMessage(userMessage);
    
    // Initialize if not ready
    if (!isReady() && !_isInitializing) {
      await initialize();
    }
    
    String responseText;
    if (!isReady()) {
      // Use fallback response if AI fails
      responseText = _generateFallbackResponse(userMessage);
    } else {
      try {
        responseText = await _generateAIResponse(userMessage);
      } catch (e) {
        print('AI response failed, using fallback: $e');
        responseText = _generateFallbackResponse(userMessage);
      }
    }

    // Store and return coach response
    return await _storage.addCoachResponse(responseText);
  }

  Future<String> _generateAIResponse(String userMessage) async {
    if (chat == null) {
      throw Exception('Chat not initialized');
    }

    try {
      // Create message with system prompt context
      final message = Message(
        text: "$_systemPrompt\n\nUser: $userMessage\nPALMER:",
        isUser: true,
      );
      
      // Add query to chat
      await chat!.addQuery(message);
      
      // Generate response stream and collect
      final responseStream = chat!.generateChatResponseAsync();
      String fullResponse = '';
      
      await for (final modelResponse in responseStream) {
        if (modelResponse is TextResponse) {
          fullResponse += modelResponse.token;
        }
      }
      
      // Clean up the response
      String cleanResponse = fullResponse.trim();
      
      // Remove any potential prompt echoing
      if (cleanResponse.startsWith('PALMER:')) {
        cleanResponse = cleanResponse.substring(7).trim();
      }
      
      // Remove system prompt if it somehow got included
      if (cleanResponse.contains(_systemPrompt)) {
        final promptIndex = cleanResponse.indexOf(_systemPrompt);
        if (promptIndex >= 0) {
          cleanResponse = cleanResponse.substring(promptIndex + _systemPrompt.length).trim();
        }
      }
      
      // Ensure we have a meaningful response
      if (cleanResponse.isEmpty || cleanResponse.length < 10) {
        throw Exception('Response too short or empty');
      }
      
      return cleanResponse;
      
    } catch (e) {
      print('❌ AI response generation error: $e');
      rethrow;
    }
  }

  String _getAvailableMemoryInfo() {
    // This is a rough estimate for debugging purposes
    if (kIsWeb) {
      return 'Web platform - memory info not available';
    }
    return 'Native platform - detailed memory info requires platform-specific implementation';
  }

  String _generateFallbackResponse(String userMessage) {
    final responses = [
      "Hello! I'm PALMER, your behavioral health coach. How are you feeling today?",
      "That's interesting. Can you tell me more about that?",
      "I understand. What would you like to work on?",
      "That sounds like a great goal. How can I help you achieve it?",
      "I hear you. How has that been affecting you lately?",
      "Thank you for sharing that with me. What support would be most helpful right now?",
      "It sounds like you're going through a challenging time. What coping strategies have you tried?",
      "I appreciate your openness. What would feel most manageable for you today?",
      "That makes sense. How do you usually handle situations like this?",
      "I'm here to support you. What's one small step you could take today?",
      "That's a lot to process. What feels most important to focus on right now?",
      "How are you taking care of yourself through all of this?",
    ];
    
    final keywords = {
      'anxious': "It sounds like you're experiencing some anxiety. What physical sensations are you noticing?",
      'depressed': "I hear that you're feeling down. When did you first notice these feelings?",
      'stressed': "Stress can be overwhelming. What are the main sources of stress in your life right now?",
      'angry': "Anger can be a valid response. What's underneath that anger for you?",
      'sad': "Sadness is a natural emotion. What's contributing to these feelings?",
      'tired': "Feeling tired can affect everything. How has your sleep been lately?",
      'overwhelmed': "Being overwhelmed is challenging. What would help you feel more manageable?",
      'lonely': "Loneliness can be difficult. What connections feel most important to you?",
      'worried': "Worry can consume a lot of energy. What specifically are you most concerned about?",
      'frustrated': "Frustration often signals something important. What's not working the way you'd like?",
    };
    
    // Check for keywords
    final lowerMessage = userMessage.toLowerCase();
    for (final entry in keywords.entries) {
      if (lowerMessage.contains(entry.key)) {
        return entry.value;
      }
    }
    
    // Return random response
    final index = DateTime.now().millisecondsSinceEpoch % responses.length;
    return responses[index];
  }
  
  Future<List<ChatMessage>> getRecentMessages({int limit = 50}) async {
    await _storage.initialize();
    return await _storage.getRecentMessages(limit: limit);
  }
  
  Future<void> clearMessages() async {
    await _storage.initialize();
    await _storage.clearMessages();
  }

  void dispose() {
    chat = null;
    _isInitialized = false;
    _isInitializing = false;
  }
}