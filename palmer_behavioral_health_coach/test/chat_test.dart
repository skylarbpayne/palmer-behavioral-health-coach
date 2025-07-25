import 'package:flutter_test/flutter_test.dart';
import 'package:palmer_behavioral_health_coach/models/chat_models.dart';
import 'package:palmer_behavioral_health_coach/services/hardcoded_chat_service.dart';

void main() {
  group('Chat Models', () {
    test('ChatMessage creation and JSON serialization', () {
      final message = ChatMessage(
        id: 'test_id',
        text: 'Hello world',
        isUser: true,
        timestamp: DateTime(2024, 1, 1, 12, 0, 0),
      );

      expect(message.id, 'test_id');
      expect(message.text, 'Hello world');
      expect(message.isUser, true);
      expect(message.timestamp, DateTime(2024, 1, 1, 12, 0, 0));

      final json = message.toJson();
      expect(json['id'], 'test_id');
      expect(json['text'], 'Hello world');
      expect(json['isUser'], true);

      final fromJson = ChatMessage.fromJson(json);
      expect(fromJson.id, message.id);
      expect(fromJson.text, message.text);
      expect(fromJson.isUser, message.isUser);
    });
  });

  group('Hardcoded Chat Service', () {
    test('Service generates responses', () async {
      final service = HardcodedChatService();
      
      final response = await service.generateResponse('Hello');
      
      expect(response.text.isNotEmpty, true);
      expect(response.isUser, false);
      expect(response.id.isNotEmpty, true);
    });

    test('Service provides contextual responses', () async {
      final service = HardcodedChatService();
      
      final sadResponse = await service.generateResponse('I feel sad');
      expect(sadResponse.text.toLowerCase().contains('sorry'), true);
      
      final anxiousResponse = await service.generateResponse('I am anxious');
      expect(anxiousResponse.text.toLowerCase().contains('anxiety'), true);
    });
  });
}