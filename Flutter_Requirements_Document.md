# Flutter Requirements Document: Palmer Behavioral Health Coach

## Project Overview

**Palmer Behavioral Health Coach** is a mobile application that provides AI-powered behavioral health coaching through a secure, privacy-focused platform. The app features an on-device AI assistant named PALMER that helps users track health metrics, set goals, manage symptoms, and receive personalized behavioral health guidance.

## Core Features

### 1. Navigation & App Structure
- **Bottom Tab Navigation** with 3 main screens:
  - Health Summary (Dashboard)
  - Chat (AI Coach Interface) 
  - Debug (Development/Testing Tools)
- **Header styling** with brand colors and typography
- **SafeArea** handling for device-specific layouts

### 2. Health Summary Dashboard
- **Real-time health metrics display** with color-coded status indicators
- **Goal progress tracking** with visual progress bars
- **Suggestions and accomplishments** with completion states
- **Responsive grid layout** for metrics cards
- **Mock data structure** ready for real health data integration

### 3. AI-Powered Chat System
- **On-device AI processing** using Gemma 2B model
- **Personalized behavioral health coaching** with evidence-based responses
- **Real-time conversation** with typing indicators
- **Automatic profile updates** based on chat context
- **Fallback response system** when AI is unavailable
- **Secure message encryption** with AES-256-CBC

### 4. User Profile Management
- **Comprehensive profile system** with metadata tracking
- **Demographics**: First name, last name, sex, gender, date of birth, sexual orientation
- **Health goals**: User-defined behavioral health objectives
- **Symptoms tracking**: Current behavioral health symptoms
- **Interventions**: Active coping strategies and treatments
- **Item-level timestamp tracking** (lastChanged, lastConfirmed)
- **UUID-based identification** for array items
- **Data validation** with Zod schemas

### 5. Secure Data Storage
- **Local-only storage** (no cloud transmission)
- **Encrypted chat messages** with chunked storage
- **Profile data persistence** with singleton pattern
- **Session management** for chat organization
- **Automatic data archiving** after configurable periods

## Technical Architecture

### Flutter Dependencies Required

#### Core Flutter Packages
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # UI & Navigation
  cupertino_icons: ^1.0.2
  
  # State Management
  provider: ^6.0.5
  
  # Navigation
  go_router: ^12.0.0
  
  # Local Storage
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Encryption
  encrypt: ^5.0.1
  crypto: ^3.0.3
  
  # Data Validation
  json_annotation: ^4.8.1
  
  # AI/ML Integration
  tflite_flutter: ^0.10.4
  
  # UUID Generation
  uuid: ^4.0.0
  
  # Date/Time Utilities
  intl: ^0.18.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
  hive_generator: ^2.0.1
```

### Data Models

#### User Profile System
```dart
// Core profile field with metadata
class ProfileField<T> {
  final T value;
  final FieldMetadata metadata;
  
  ProfileField({required this.value, required this.metadata});
}

class FieldMetadata {
  final DateTime lastChanged;
  final DateTime? lastConfirmed;
  
  FieldMetadata({required this.lastChanged, this.lastConfirmed});
}

// Array items with unique IDs
class ProfileArrayItem<T> {
  final T value;
  final String id;
  final FieldMetadata metadata;
  
  ProfileArrayItem({
    required this.value, 
    required this.id, 
    required this.metadata
  });
}

// Main user profile
class UserProfile {
  ProfileField<String>? firstName;
  ProfileField<String>? lastName;
  ProfileField<String>? sex; // 'male' | 'female' | 'intersex'
  ProfileField<String>? gender;
  ProfileField<String>? dateOfBirth;
  ProfileField<String>? sexualOrientation;
  List<ProfileArrayItem<String>>? currentHealthGoals;
  List<ProfileArrayItem<String>>? currentBehavioralHealthSymptoms;
  List<ProfileArrayItem<String>>? currentInterventions;
}
```

#### Chat System Models
```dart
class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  
  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class StoredChatMessage extends ChatMessage {
  final String sessionId;
  final String? encryptedContent;
  final MessageMetadata metadata;
  
  StoredChatMessage({
    required String id,
    required String text,
    required bool isUser,
    required DateTime timestamp,
    required this.sessionId,
    this.encryptedContent,
    required this.metadata,
  }) : super(id: id, text: text, isUser: isUser, timestamp: timestamp);
}

class MessageMetadata {
  final bool encrypted;
  final int? chunkIndex;
  final int? totalChunks;
  
  MessageMetadata({
    required this.encrypted,
    this.chunkIndex,
    this.totalChunks,
  });
}
```

### Services Architecture

#### UserProfileService (Singleton)
```dart
class UserProfileService {
  static final UserProfileService _instance = UserProfileService._internal();
  factory UserProfileService() => _instance;
  UserProfileService._internal();
  
  // Core operations
  Future<UserProfile> loadProfile();
  Future<void> saveProfile();
  Future<void> clearProfile();
  
  // Simple field operations
  Future<ProfileField<T>?> getSimpleField<T>(String field);
  Future<void> updateSimpleField<T>(String field, T value, {bool confirm = false});
  Future<void> confirmSimpleField(String field);
  
  // Array field operations
  Future<List<ProfileArrayItem<String>>?> getArrayField(String field);
  Future<String> addArrayItem(String field, String value, {bool confirm = false});
  Future<void> removeArrayItem(String field, String id);
  Future<void> updateArrayItem(String field, String id, String value, {bool confirm = false});
  Future<void> confirmArrayItem(String field, String id);
}
```

#### AIService (On-Device Processing)
```dart
class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();
  
  // Core AI operations
  Future<void> initialize();
  Future<AIResponse> generateResponse(String userMessage, {List<String> conversationHistory = const []});
  Future<String> generateInitialProfileCheck();
  bool isReady();
  
  // Fallback system
  String generateFallbackResponse(String userMessage, {String userName = '', String profileSummary = ''});
}

class AIResponse {
  final String text;
  final bool profileUpdated;
  final String? error;
  
  AIResponse({required this.text, required this.profileUpdated, this.error});
}
```

#### ChatService (Encrypted Storage)
```dart
class ChatService {
  // Message operations
  Future<ChatMessage> addUserMessage(String text);
  Future<ChatMessage> addCoachResponse(String text);
  Future<List<ChatMessage>> getRecentMessages(int limit);
  
  // Session management
  Future<ChatSession> createSession(String name);
  Future<List<ChatSession>> getSessions();
  Future<void> archiveSession(String sessionId);
  
  // Encryption
  Future<String> encryptMessage(String message);
  Future<String> decryptMessage(String encryptedMessage);
}
```

## UI/UX Specifications

### Design System

#### Color Palette
- **Primary Green**: `#4CAF50` - Headers, active states, progress indicators
- **Primary Blue**: `#007AFF` - User messages, send button active
- **Background**: `#f5f5f5` - App background
- **Card Background**: `#ffffff` - Content cards
- **Text Primary**: `#333333` - Main text content
- **Text Secondary**: `#666666` - Subtitles, metadata
- **Text Muted**: `#999999` - Placeholders, timestamps
- **Border**: `#e0e0e0` - Card borders, dividers
- **Warning**: `#FF9800` - Warning status indicators
- **Error**: `#F44336` - Error status indicators

#### Typography
- **Large Title**: 28px, Bold - Screen titles
- **Title**: 24px, Bold - Section headers
- **Subtitle**: 20px, SemiBold - Subsection headers
- **Body**: 16px, Regular - Main content
- **Caption**: 14px, Regular - Secondary text
- **Small**: 12px, Regular - Metadata, timestamps
- **Tiny**: 11px, Regular - Fine print

#### Layout Specifications
- **Screen Padding**: 20px horizontal
- **Card Margin**: 10px vertical
- **Card Padding**: 15px
- **Card Border Radius**: 12px
- **Input Border Radius**: 20px
- **Button Border Radius**: 20px
- **Shadow**: Elevation 3 with blur radius 4

### Screen Layouts

#### Health Summary Screen
- **Scrollable content** with pull-to-refresh
- **Metrics grid**: 2-column layout with responsive cards
- **Progress bars**: Full-width with percentage labels
- **Status indicators**: Color-coded with icons
- **Achievement badges**: Completed items with checkmarks

#### Chat Screen
- **Fixed header** with coach name and status
- **Scrollable message list** with auto-scroll to bottom
- **Message bubbles**: User (right, blue) vs Coach (left, white)
- **Typing indicators** during AI processing
- **Input field**: Expandable multiline with character limit
- **Send button**: Disabled state and active state styling

### Responsive Design
- **iPhone SE**: Minimum supported screen size
- **Large screens**: Adaptive layouts with max-width constraints
- **Landscape orientation**: Adjusted padding and layouts
- **Accessibility**: VoiceOver support, high contrast mode

## AI Integration Requirements

### On-Device Model Setup
- **Model**: Gemma 2B IT quantized (Q4F32_1)
- **Size**: ~3GB VRAM requirement
- **Format**: TensorFlow Lite compatible
- **Performance**: Real-time inference on modern mobile devices

### System Prompt Configuration
```dart
const String behavioralHealthCoachPrompt = '''
You are an expert behavioral health coach named PALMER. 
Your primary role is to support users in their mental health 
and behavioral wellness journey through compassionate, 
evidence-based guidance.

Core responsibilities:
1. Profile management and personalization
2. Supportive engagement with empathy
3. Constructive challenge when appropriate
4. Symptom observation and pattern recognition
5. Evidence-based intervention suggestions

Communication style: Warm, professional, curious, respectful
''';
```

### Response Processing
- **Stream processing** for real-time response display
- **Context window**: Last 10 messages for conversation continuity
- **Profile integration**: Automatic updates based on conversation
- **Fallback system**: Predefined responses when AI unavailable
- **Error handling**: Graceful degradation with user feedback

## Security & Privacy Requirements

### Data Protection
- **Local-only storage**: No cloud synchronization
- **AES-256-CBC encryption** for sensitive chat data
- **Secure key derivation** using device-specific entropy
- **Automatic data expiration** after configurable periods
- **Memory protection**: Secure deletion of sensitive data

### Privacy Features
- **No analytics tracking**: Complete user privacy
- **No external API calls**: Fully offline operation
- **Biometric protection**: Optional device lock integration
- **Data export**: Allow user to export their data
- **Data deletion**: Complete profile and chat history removal

## Platform-Specific Requirements

### iOS Implementation
- **Minimum iOS**: 14.0+
- **Privacy manifest**: Required for App Store compliance
- **Keychain storage**: Secure credential management
- **Background processing**: Limited to essential tasks only
- **App Transport Security**: Enforce HTTPS (though app is offline)

### Android Implementation
- **Minimum Android**: API 21 (Android 5.0)
- **Scoped storage**: Comply with modern storage requirements
- **Foreground services**: For AI model loading if needed
- **Battery optimization**: Request exemption for consistent performance
- **Biometric authentication**: Fingerprint/face unlock support

## Development Guidelines

### Code Organization
```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   └── router.dart
├── screens/
│   ├── health_summary_screen.dart
│   ├── chat_screen.dart
│   └── debug_screen.dart
├── services/
│   ├── user_profile_service.dart
│   ├── ai_service.dart
│   ├── chat_service.dart
│   └── encryption_service.dart
├── models/
│   ├── user_profile.dart
│   ├── chat_models.dart
│   └── health_models.dart
├── widgets/
│   ├── metric_card.dart
│   ├── progress_card.dart
│   ├── message_bubble.dart
│   └── common/
├── utils/
│   ├── profile_tools.dart
│   ├── chat_tools.dart
│   └── constants.dart
└── assets/
    ├── ml_models/
    └── images/
```

### Testing Requirements
- **Unit tests**: 80%+ coverage for services and utilities
- **Widget tests**: All screens and major widgets
- **Integration tests**: End-to-end user flows
- **Performance tests**: AI response time and memory usage
- **Security tests**: Encryption and data protection validation

### Build Configuration
- **Release optimization**: Code obfuscation and dead code elimination
- **Bundle size**: Target <50MB with AI model
- **Startup time**: <3 seconds to functional interface
- **Memory usage**: <500MB peak during AI inference
- **Battery usage**: Minimal background consumption

## Implementation Notes

### Key Differences from React Native
1. **State Management**: Use Provider pattern instead of React hooks
2. **Navigation**: Use GoRouter instead of React Navigation
3. **Storage**: Use Hive instead of AsyncStorage for better performance
4. **AI Integration**: Use TensorFlow Lite instead of React Native AI
5. **Styling**: Use Flutter's widget-based styling instead of StyleSheet

### Migration Considerations
- **Data Migration**: Implement migration utilities for existing user data
- **Feature Parity**: Ensure all React Native features are replicated
- **Performance**: Optimize for Flutter's rendering pipeline
- **Platform Integration**: Leverage Flutter's platform channels for native features
- **Testing**: Adapt existing test cases to Flutter testing framework

### Development Phases
1. **Phase 1**: Core app structure and navigation
2. **Phase 2**: User profile system and data storage
3. **Phase 3**: Health summary dashboard with mock data
4. **Phase 4**: Chat interface without AI
5. **Phase 5**: AI integration and on-device model
6. **Phase 6**: Encryption and security features
7. **Phase 7**: Polish, testing, and optimization

This comprehensive requirements document provides a complete blueprint for reproducing the Palmer Behavioral Health Coach application in Flutter while maintaining feature parity and improving upon the original architecture where possible.