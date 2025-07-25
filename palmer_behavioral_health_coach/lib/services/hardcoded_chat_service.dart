import 'dart:async';
import 'dart:math';
import '../models/chat_models.dart';

class HardcodedChatService {
  static final HardcodedChatService _instance = HardcodedChatService._internal();
  factory HardcodedChatService() => _instance;
  HardcodedChatService._internal();

  final List<String> _responses = [
    "Hello! I'm PALMER, your behavioral health coach. How are you feeling today?",
    "That's interesting. Can you tell me more about that?",
    "I understand. What would you like to work on?",
    "That sounds like a great goal. How can I help you achieve it?",
    "I hear you. It's important to acknowledge those feelings.",
    "What strategies have you tried before in similar situations?",
    "That's a positive step forward. How did that make you feel?",
    "I'm here to support you through this journey.",
    "What would success look like to you in this situation?",
    "Let's explore that feeling a bit more. What triggered it?",
    "You're showing real strength by working on this.",
    "How has this been affecting your daily life?",
  ];

  final Random _random = Random();
  int _responseIndex = 0;

  Future<ChatMessage> generateResponse(String userMessage) async {
    // Simulate processing time
    final randomDelay = (400 * _random.nextDouble()).round();
    await Future.delayed(Duration(milliseconds: 800 + randomDelay));

    String responseText;
    
    // First message gets the welcome response
    if (_responseIndex == 0) {
      responseText = _responses[0];
    } else {
      // Use contextual responses based on user input
      responseText = _getContextualResponse(userMessage);
    }
    
    _responseIndex++;

    return ChatMessage(
      id: 'coach_${DateTime.now().millisecondsSinceEpoch}',
      text: responseText,
      isUser: false,
      timestamp: DateTime.now(),
    );
  }

  String _getContextualResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    if (message.contains('hello') || message.contains('hi')) {
      return "Hello! It's good to connect with you. How can I support you today?";
    } else if (message.contains('sad') || message.contains('down') || message.contains('depressed')) {
      return "I'm sorry you're feeling this way. It takes courage to share these feelings. What's been weighing on your mind?";
    } else if (message.contains('anxious') || message.contains('worry') || message.contains('stress')) {
      return "Anxiety can be really challenging. What situations or thoughts tend to trigger these feelings for you?";
    } else if (message.contains('goal') || message.contains('want to')) {
      return "Setting goals is a powerful step. What specific outcome are you hoping to achieve?";
    } else if (message.contains('help') || message.contains('support')) {
      return "I'm here to help. What area of your life would you like to focus on first?";
    } else if (message.contains('better') || message.contains('good') || message.contains('great')) {
      return "That's wonderful to hear! What's been contributing to these positive feelings?";
    } else if (message.contains('thank')) {
      return "You're very welcome. I'm glad I could be helpful. What else would you like to explore?";
    } else {
      // Use random response from the pool for other messages
      final availableResponses = _responses.sublist(1); // Skip the welcome message
      return availableResponses[_random.nextInt(availableResponses.length)];
    }
  }
}