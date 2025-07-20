import { z } from 'zod';

// Base message interface (compatible with existing ChatScreen)
export interface ChatMessage {
  id: string;
  text: string;
  isUser: boolean;
  timestamp: Date;
}

// Extended message interface for storage with metadata
export interface StoredChatMessage extends ChatMessage {
  sessionId: string;
  encryptedContent?: string; // For encrypted storage
  metadata: {
    encrypted: boolean;
    chunkIndex?: number;
    totalChunks?: number;
  };
}

// Chat session for organizing conversations
export interface ChatSession {
  id: string;
  name: string;
  createdAt: Date;
  lastMessageAt: Date;
  messageCount: number;
  archived: boolean;
}

// Storage chunk for large chat logs
export interface ChatChunk {
  id: string;
  sessionId: string;
  chunkIndex: number;
  totalChunks: number;
  encryptedMessages: string; // JSON string of encrypted messages
  timestamp: Date;
}

// Storage configuration
export interface ChatStorageConfig {
  maxMessagesPerChunk: number;
  maxSessionsToKeep: number;
  archiveAfterDays: number;
  encryptionEnabled: boolean;
}

// Zod schemas for validation
export const ChatMessageSchema = z.object({
  id: z.string(),
  text: z.string(),
  isUser: z.boolean(),
  timestamp: z.date(),
});

export const StoredChatMessageSchema = z.object({
  id: z.string(),
  text: z.string(),
  isUser: z.boolean(),
  timestamp: z.date(),
  sessionId: z.string(),
  encryptedContent: z.string().optional(),
  metadata: z.object({
    encrypted: z.boolean(),
    chunkIndex: z.number().optional(),
    totalChunks: z.number().optional(),
  }),
});

export const ChatSessionSchema = z.object({
  id: z.string(),
  name: z.string(),
  createdAt: z.date(),
  lastMessageAt: z.date(),
  messageCount: z.number(),
  archived: z.boolean(),
});

export const ChatChunkSchema = z.object({
  id: z.string(),
  sessionId: z.string(),
  chunkIndex: z.number(),
  totalChunks: z.number(),
  encryptedMessages: z.string(),
  timestamp: z.date(),
});

export const ChatStorageConfigSchema = z.object({
  maxMessagesPerChunk: z.number().min(1).max(1000),
  maxSessionsToKeep: z.number().min(1).max(100),
  archiveAfterDays: z.number().min(1).max(365),
  encryptionEnabled: z.boolean(),
});

// Default configuration
export const DEFAULT_CHAT_STORAGE_CONFIG: ChatStorageConfig = {
  maxMessagesPerChunk: 100,
  maxSessionsToKeep: 10,
  archiveAfterDays: 30,
  encryptionEnabled: true, // AES-256-CBC encryption enabled
};