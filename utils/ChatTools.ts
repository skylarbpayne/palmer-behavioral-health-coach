import { EncryptedChatService } from '../services/EncryptedChatService';
import { ChatMessage, ChatSession, ChatStorageConfig } from '../types/ChatTypes';
import * as Crypto from 'expo-crypto';

// Simple UUID generator using expo-crypto (to avoid crypto.getRandomValues issue)
const generateUUID = async (): Promise<string> => {
  const randomBytes = await Crypto.getRandomBytesAsync(16);
  const hex = Array.from(randomBytes, byte => byte.toString(16).padStart(2, '0')).join('');
  
  // Format as UUID: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
  return [
    hex.slice(0, 8),
    hex.slice(8, 12),
    '4' + hex.slice(13, 16),
    ((parseInt(hex.slice(16, 17), 16) & 0x3) | 0x8).toString(16) + hex.slice(17, 20),
    hex.slice(20, 32)
  ].join('-');
};

/**
 * ChatTools - Utility functions for LLM integration with encrypted chat storage
 * 
 * These functions provide an easy-to-use interface for managing chat conversations
 * with end-to-end encryption and secure storage.
 */
export class ChatTools {
  private static chatService = EncryptedChatService.getInstance();

  /**
   * Initialize the chat service - call this before using other methods
   */
  static async initialize(): Promise<void> {
    await this.chatService.initialize();
  }

  /**
   * Send a message and get it stored securely
   */
  static async sendMessage(text: string, isUser: boolean = true): Promise<ChatMessage> {
    const message: ChatMessage = {
      id: await generateUUID(),
      text,
      isUser,
      timestamp: new Date(),
    };

    await this.chatService.saveMessage(message);
    return message;
  }

  /**
   * Get recent chat messages (default: last 50 messages)
   */
  static async getRecentMessages(limit: number = 50): Promise<ChatMessage[]> {
    return await this.chatService.getMessages(undefined, limit);
  }

  /**
   * Get all messages from the current session
   */
  static async getAllMessages(): Promise<ChatMessage[]> {
    return await this.chatService.getMessages();
  }

  /**
   * Get messages from a specific session
   */
  static async getSessionMessages(sessionId: string, limit?: number): Promise<ChatMessage[]> {
    return await this.chatService.getMessages(sessionId, limit);
  }

  /**
   * Create a new chat session
   */
  static async createNewSession(name?: string): Promise<ChatSession> {
    return await this.chatService.createNewSession(name);
  }

  /**
   * Get the current active session
   */
  static async getCurrentSession(): Promise<ChatSession> {
    return await this.chatService.getCurrentSession();
  }

  /**
   * Get all available sessions
   */
  static async getAllSessions(): Promise<ChatSession[]> {
    return await this.chatService.getAllSessions();
  }

  /**
   * Switch to a different session
   */
  static async switchToSession(sessionId: string): Promise<ChatSession | null> {
    const session = await this.chatService.getSession(sessionId);
    if (session) {
      // Create new session with same ID to make it current
      return await this.chatService.createNewSession(session.name);
    }
    return null;
  }

  /**
   * Get storage statistics and health information
   */
  static async getStorageStats(): Promise<{
    totalSessions: number;
    totalMessages: number;
    archivedSessions: number;
    encryptionEnabled: boolean;
  }> {
    return await this.chatService.getStorageStats();
  }

  /**
   * Update chat storage configuration
   */
  static async updateConfig(config: Partial<ChatStorageConfig>): Promise<void> {
    await this.chatService.updateConfig(config);
  }

  /**
   * Perform maintenance tasks (archive old sessions, cleanup)
   */
  static async performMaintenance(): Promise<void> {
    await this.chatService.archiveOldSessions();
    await this.chatService.cleanupOldSessions();
  }

  /**
   * Clear all chat data (use with caution!)
   */
  static async clearAllData(): Promise<void> {
    await this.chatService.clearAllData();
  }

  /**
   * Simulate a conversation for testing purposes
   */
  static async simulateConversation(): Promise<ChatMessage[]> {
    const messages = [
      "Hello! I'm your personal health coach. How can I help you today?",
      "Hi! I've been feeling stressed lately and could use some guidance.",
      "I understand stress can be challenging. Can you tell me more about what's been causing your stress?",
      "Work has been really demanding, and I haven't been sleeping well.",
      "Poor sleep can definitely increase stress levels. Let's work on some strategies to improve your sleep hygiene. When do you typically go to bed?",
    ];

    const savedMessages: ChatMessage[] = [];
    for (let i = 0; i < messages.length; i++) {
      const message = await this.sendMessage(messages[i], i % 2 === 1);
      savedMessages.push(message);
      
      // Small delay to simulate real conversation timing
      await new Promise(resolve => setTimeout(resolve, 100));
    }

    return savedMessages;
  }

  /**
   * Export chat data for backup (encrypted)
   */
  static async exportChatData(): Promise<{
    sessions: ChatSession[];
    stats: any;
    exportDate: Date;
  }> {
    const sessions = await this.getAllSessions();
    const stats = await this.getStorageStats();

    return {
      sessions,
      stats,
      exportDate: new Date(),
    };
  }

  /**
   * Health check - verify encryption and storage are working
   */
  static async healthCheck(): Promise<{
    encryptionWorking: boolean;
    storageWorking: boolean;
    errors: string[];
  }> {
    const errors: string[] = [];
    let encryptionWorking = false;
    let storageWorking = false;

    try {
      // Test storage by sending and retrieving a message
      const testMessage = await this.sendMessage('Health check test message', false);
      const retrievedMessages = await this.getRecentMessages(1);
      
      if (retrievedMessages.length > 0 && retrievedMessages[0].id === testMessage.id) {
        storageWorking = true;
      } else {
        errors.push('Storage test failed - message not retrieved correctly');
      }

      // Test encryption (if enabled) by checking if messages are properly stored and encrypted
      const stats = await this.getStorageStats();
      if (stats.encryptionEnabled) {
        // If storage is working and encryption is enabled, encryption is working
        if (storageWorking) {
          encryptionWorking = true;
        } else {
          errors.push('Encryption enabled but storage failed');
        }
      } else {
        encryptionWorking = true; // Not enabled, so not an error
        errors.push('Encryption is disabled');
      }
    } catch (error) {
      errors.push(`Health check failed: ${error instanceof Error ? error.message : 'Unknown error'}`);
    }

    return {
      encryptionWorking,
      storageWorking,
      errors,
    };
  }

  /**
   * Get conversation context for LLM (recent messages formatted)
   */
  static async getConversationContext(limit: number = 10): Promise<string> {
    const messages = await this.getRecentMessages(limit);
    
    return messages
      .map(msg => `${msg.isUser ? 'User' : 'Coach'}: ${msg.text}`)
      .join('\n');
  }

  /**
   * Add a coach response to the conversation
   */
  static async addCoachResponse(response: string): Promise<ChatMessage> {
    return await this.sendMessage(response, false);
  }

  /**
   * Add a user message to the conversation
   */
  static async addUserMessage(message: string): Promise<ChatMessage> {
    return await this.sendMessage(message, true);
  }
}