import 'dart:async';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma/core/model.dart';
import 'package:flutter_gemma/pigeon.g.dart';

/// Centralized model manager - ensures only one model is loaded at a time
class ModelManager {
  static final ModelManager _instance = ModelManager._internal();
  factory ModelManager() => _instance;
  ModelManager._internal();

  final FlutterGemmaPlugin _gemma = FlutterGemmaPlugin.instance;
  InferenceModel? _model;
  bool _isInitialized = false;
  bool _isInitializing = false;

  Future<InferenceModel> getModel() async {
    print('getting model');
    if (_model != null) return _model!;
    
    if (_isInitializing) {
      print('model is initializing');
      while (_isInitializing) {
        print('waiting for model to initialize...');
        await Future.delayed(const Duration(milliseconds: 100));
      }
      print('model is initialized');
      if (_model != null) return _model!;
    }
    print('model is not initializing');

    await _initializeModel();
    return _model!;
  }

  Future<void> _initializeModel() async {
    print('initializing model');
    if (_isInitialized || _isInitializing) return;
    
    _isInitializing = true;
    try {
      final completer = Completer<void>();
      print('installing model');
      _gemma.modelManager.installModelFromAssetWithProgress('models/gemma-3n-E2B-it-int4.task').listen(
        (progress) => print('Model loading: $progress%'),
        onDone: () async {
          try {
            print('creating model');
            _model = await _gemma.createModel(
              modelType: ModelType.gemmaIt,
              preferredBackend: PreferredBackend.gpu,
              maxTokens: 512,
              supportImage: false,
            );
            print('model created');
            _isInitialized = true;
            completer.complete();
          } catch (e) {
            completer.completeError(e);
          }
        },
        onError: (error, stackTrace) => completer.completeError(error),
      );
      print('waiting for model to install');
      await completer.future;
    } finally {
      _isInitializing = false;
    }
  }

  void dispose() {
    _model = null;
    _isInitialized = false;
  }
}

/// A tool that can be called by the LLM
class LLMTool<T> {
  final Tool tool;
  final Future<T> Function(Map<String, dynamic> args) handler;

  const LLMTool({
    required this.tool,
    required this.handler,
  });

  factory LLMTool.create({
    required String name,
    required String description,
    required Map<String, dynamic> parameters,
    required Future<T> Function(Map<String, dynamic> args) handler,
  }) {
    return LLMTool(
      tool: Tool(name: name, description: description, parameters: parameters),
      handler: handler,
    );
  }
}

/// Main LLM function class - highly ergonomic and simple to use
class LLMFunction<T> {
  final String promptTemplate;
  final T Function(String)? outputFormatter;
  final List<LLMTool> tools;
  final ModelManager _modelManager = ModelManager();
  
  LLMFunction({
    required this.promptTemplate,
    this.outputFormatter,
    this.tools = const [],
  });

  /// Run the LLM function with the given variables
  Future<T> run(Map<String, dynamic> variables) async {
    final model = await _modelManager.getModel();
    print('got model');
    final toolList = tools.map((t) => t.tool).toList();
    // TODO: support state (e.g. for conversation history)
    print('creating chat');
    final chat = await model.createChat(tools: toolList, supportsFunctionCalls: toolList.isNotEmpty);
    print('chat created');
    // Template substitution
    String prompt = promptTemplate;
    variables.forEach((key, value) {
      prompt = prompt.replaceAll('{$key}', value.toString());
    });

    // TODO: not sure how to add a system prompt.
    // TODO: support multiple messages?
    final message = Message.text(text: prompt, isUser: true);
    await chat.addQuery(message);

    String response = '';
    final responseStream = chat.generateChatResponseAsync();
    
    await for (final modelResponse in responseStream) {
      if (modelResponse is TextResponse) {
        response += modelResponse.token;
      } else if (modelResponse is FunctionCallResponse) {
        await _handleToolCall(modelResponse);
      }
    }

    await chat.session.close();
    return outputFormatter?.call(response) ?? response as T;
  }

  Future<void> _handleToolCall(FunctionCallResponse toolCall) async {
    final tool = tools.firstWhere((t) => t.tool.name == toolCall.name);
    try {
      await tool.handler(toolCall.args);
    } catch (e) {
      print('Tool execution failed for ${toolCall.name}: $e');
    }
  }
}

/// Convenient factory function for creating LLM functions
LLMFunction<T> llmfn<T>({
  required String promptTemplate,
  T Function(String)? outputFormatter,
  List<LLMTool> tools = const [],
}) {
  return LLMFunction(
    promptTemplate: promptTemplate,
    outputFormatter: outputFormatter,
    tools: tools,
  );
}