import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/chat_models.dart';
import 'chat_storage_service.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma/core/model.dart';
import 'package:flutter_gemma/pigeon.g.dart';
import 'user_profile_service.dart';

class AiChatService {
  static final AiChatService _instance = AiChatService._internal();
  factory AiChatService() => _instance;
  AiChatService._internal();

  final FlutterGemmaPlugin _gemma = FlutterGemmaPlugin.instance;
  final ChatStorageService _storage = ChatStorageService();
  final UserProfileService _profileService = UserProfileService();
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

Communication style: Warm, professional, curious, respectful. Keep responses concise but meaningful.

Use the following process in all your responses:
1. Extract any symptoms that are relevant
2. Remember each symptom by using the saveSymptom tool
3. Consider a set of possible interventions based on past and new symptoms
4. Remember each intervention by using the saveIntervention tool
5. Construct a concise reply recognizing the symptoms and interventions

You should always begin with your tool calls.
""";

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
          print('Attempting model creation with GPU backend...');
          model = await _gemma.createModel(
            modelType: ModelType.gemmaIt,
            preferredBackend: PreferredBackend.gpu,
            maxTokens: 512,
            supportImage: false,
          );

          chat = await model.createChat(tools: _tools, supportsFunctionCalls: true);
          
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
    
    print('Tools: ${chat!.tools}');
    print('Supports function calls: ${chat!.supportsFunctionCalls}');
    
    String responseText;
    if (!isReady()) {
      // Use fallback response if AI fails
      responseText = 'AI response failed';
    } else {
      try {
        responseText = await _generateAIResponse(userMessage);
      } catch (e) {
        print('AI response failed, using fallback: $e');
        responseText = 'AI response failed';
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
      
      // TODO: progressively show what is being typed on the screen.
      await for (final modelResponse in responseStream) {
        if (modelResponse is TextResponse) {
          fullResponse += modelResponse.token;
        }
        else if (modelResponse is FunctionCallResponse) {
          print('Calling tool: ${modelResponse.name} with args: ${modelResponse.args}');
          if (modelResponse.name == 'saveSymptom') {
            await _profileService.addArrayItem('currentBehavioralHealthSymptoms', modelResponse.args['symptom']);
          }
          else if (modelResponse.name == 'saveIntervention') {
            await _profileService.addArrayItem('currentInterventions', modelResponse.args['intervention']);
          }
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
      if (cleanResponse.isEmpty) {
        throw Exception('Response empty');
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

  final List<Tool> _tools = [
    const Tool(
      name: 'saveSymptom',
      description: 'Save a symptom to the user\'s profile',
      parameters: {
        'type': 'object',
        'properties': {
          'symptom': {'type': 'string'},
        },
      },
    ),
    const Tool(
      name: 'saveIntervention',
      description: 'Save an intervention to the user\'s profile',
      parameters: {
        'type': 'object',
        'properties': {
          'intervention': {'type': 'string'},
        },
      },
    )
  ];
}