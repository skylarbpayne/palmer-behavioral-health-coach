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

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      text: json['text'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class MessageMetadata {
  final bool encrypted;
  final int? chunkIndex;
  final int? totalChunks;
  final String sessionId;

  MessageMetadata({
    required this.encrypted,
    this.chunkIndex,
    this.totalChunks,
    required this.sessionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'encrypted': encrypted,
      'chunkIndex': chunkIndex,
      'totalChunks': totalChunks,
      'sessionId': sessionId,
    };
  }

  factory MessageMetadata.fromJson(Map<String, dynamic> json) {
    return MessageMetadata(
      encrypted: json['encrypted'] ?? false,
      chunkIndex: json['chunkIndex'],
      totalChunks: json['totalChunks'],
      sessionId: json['sessionId'] ?? 'default',
    );
  }
}

class StoredChatMessage extends ChatMessage {
  final String? encryptedContent;
  final MessageMetadata metadata;

  StoredChatMessage({
    required String id,
    required String text,
    required bool isUser,
    required DateTime timestamp,
    this.encryptedContent,
    required this.metadata,
  }) : super(
          id: id,
          text: text,
          isUser: isUser,
          timestamp: timestamp,
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'encryptedContent': encryptedContent,
      'metadata': metadata.toJson(),
    };
  }

  factory StoredChatMessage.fromJson(Map<String, dynamic> json) {
    return StoredChatMessage(
      id: json['id'],
      text: json['text'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
      encryptedContent: json['encryptedContent'],
      metadata: MessageMetadata.fromJson(json['metadata']),
    );
  }

  static StoredChatMessage fromChatMessage(
    ChatMessage message, {
    String? encryptedContent,
    required String sessionId,
  }) {
    return StoredChatMessage(
      id: message.id,
      text: message.text,
      isUser: message.isUser,
      timestamp: message.timestamp,
      encryptedContent: encryptedContent,
      metadata: MessageMetadata(
        encrypted: encryptedContent != null,
        sessionId: sessionId,
      ),
    );
  }
}

class ChatSession {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime lastActivity;
  final int messageCount;

  ChatSession({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.lastActivity,
    this.messageCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'lastActivity': lastActivity.toIso8601String(),
      'messageCount': messageCount,
    };
  }

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
      lastActivity: DateTime.parse(json['lastActivity']),
      messageCount: json['messageCount'] ?? 0,
    );
  }

  ChatSession copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? lastActivity,
    int? messageCount,
  }) {
    return ChatSession(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      lastActivity: lastActivity ?? this.lastActivity,
      messageCount: messageCount ?? this.messageCount,
    );
  }
}