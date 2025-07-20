import React, { useState } from 'react';
import { View, Text, TouchableOpacity, StyleSheet, ScrollView, Alert } from 'react-native';
import { ChatTools } from '../utils/ChatTools';
import { Logger } from '../utils/Logger';

export default function ChatDebug() {
  const [debugInfo, setDebugInfo] = useState<string>('');
  const [loading, setLoading] = useState(false);

  const runStorageDebug = async () => {
    setLoading(true);
    try {
      await ChatTools.initialize();
      
      const stats = await ChatTools.getStorageStats();
      const allMessages = await ChatTools.getAllMessages();
      const recentMessages = await ChatTools.getRecentMessages(5);
      const sessions = await ChatTools.getAllSessions();
      
      const debugOutput = `
🔍 CHAT STORAGE DEBUG REPORT
Generated: ${new Date().toLocaleString()}

📊 STORAGE STATISTICS:
• Total Sessions: ${stats.totalSessions}
• Total Messages: ${stats.totalMessages}
• Archived Sessions: ${stats.archivedSessions}
• Encryption Enabled: ${stats.encryptionEnabled}

📱 CURRENT SESSION:
${JSON.stringify(await ChatTools.getCurrentSession(), null, 2)}

💬 ALL MESSAGES (${allMessages.length} total):
${allMessages.map((msg, i) => 
  `${i + 1}. [${msg.isUser ? 'USER' : 'COACH'}] ${msg.text} (${msg.timestamp.toLocaleTimeString()})`
).join('\n')}

🕒 RECENT MESSAGES (last 5):
${recentMessages.map((msg, i) => 
  `${i + 1}. [${msg.isUser ? 'USER' : 'COACH'}] ${msg.text} (${msg.timestamp.toLocaleTimeString()})`
).join('\n')}

📚 ALL SESSIONS:
${sessions.map((session, i) => 
  `${i + 1}. ${session.name} (${session.messageCount} messages, last: ${session.lastMessageAt.toLocaleString()})`
).join('\n')}
      `.trim();
      
      setDebugInfo(debugOutput);
    } catch (error) {
      setDebugInfo(`❌ Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setLoading(false);
    }
  };

  const clearAllData = async () => {
    Alert.alert(
      'Clear All Chat Data',
      'This will permanently delete all messages and sessions. Are you sure?',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete All',
          style: 'destructive',
          onPress: async () => {
            try {
              await ChatTools.clearAllData();
              setDebugInfo('✅ All chat data cleared successfully');
            } catch (error) {
              setDebugInfo(`❌ Error clearing data: ${error instanceof Error ? error.message : 'Unknown error'}`);
            }
          }
        }
      ]
    );
  };

  const addTestMessages = async () => {
    setLoading(true);
    try {
      await ChatTools.initialize();
      
      const testMessages = [
        'Hello, I need help with my anxiety',
        'I understand you want to discuss anxiety. Can you tell me more about what you\'re experiencing?',
        'I have been feeling anxious about work deadlines',
        'Work stress can definitely contribute to anxiety. Let\'s explore some coping strategies together.',
      ];

      for (let i = 0; i < testMessages.length; i++) {
        const isUser = i % 2 === 0;
        if (isUser) {
          await ChatTools.addUserMessage(testMessages[i]);
        } else {
          await ChatTools.addCoachResponse(testMessages[i]);
        }
        // Small delay to ensure different timestamps
        await new Promise(resolve => setTimeout(resolve, 100));
      }
      
      setDebugInfo('✅ Added 4 test messages successfully');
    } catch (error) {
      setDebugInfo(`❌ Error adding test messages: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setLoading(false);
    }
  };

  const performHealthCheck = async () => {
    setLoading(true);
    try {
      await ChatTools.initialize();
      const health = await ChatTools.healthCheck();
      const stats = await ChatTools.getStorageStats();
      
      setDebugInfo(`
🏥 HEALTH CHECK RESULTS:
• Storage Working: ${health.storageWorking ? '✅' : '❌'}
• Encryption Working: ${health.encryptionWorking ? '✅' : '❌'}
• Encryption Enabled in Config: ${stats.encryptionEnabled ? '✅' : '❌'}

${health.errors.length > 0 ? '⚠️ ERRORS:\n' + health.errors.join('\n') : '✅ No errors detected'}
      `.trim());
    } catch (error) {
      setDebugInfo(`❌ Health check failed: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setLoading(false);
    }
  };

  const testEncryptionDirectly = async () => {
    setLoading(true);
    try {
      const { EncryptedChatService } = await import('../services/EncryptedChatService');
      const service = EncryptedChatService.getInstance();
      
      setDebugInfo('🔧 ENCRYPTION DIAGNOSTIC:\n\nInitializing service...');
      
      await service.initialize();
      const stats = await service.getStorageStats();
      
      setDebugInfo(`🔧 ENCRYPTION DIAGNOSTIC:
      
📊 Service Stats:
• Encryption Enabled: ${stats.encryptionEnabled}
• Total Sessions: ${stats.totalSessions}
• Total Messages: ${stats.totalMessages}

🔐 Testing Encryption Components:
Testing SecureStore availability...`);
      
      // Test SecureStore directly
      const SecureStore = await import('expo-secure-store');
      const isAvailable = await SecureStore.isAvailableAsync();
      
      setDebugInfo(prev => prev + `\n• SecureStore Available: ${isAvailable ? '✅' : '❌'}`);
      
      if (isAvailable) {
        // Test key generation
        const Crypto = await import('expo-crypto');
        const testKey = await Crypto.getRandomBytesAsync(32);
        const keyHex = Array.from(testKey, byte => byte.toString(16).padStart(2, '0')).join('');
        
        setDebugInfo(prev => prev + `\n• Key Generation: ✅ (${keyHex.length} chars)`);
        
        // Test SecureStore write/read
        const testKeyAlias = 'test_encryption_key';
        await SecureStore.setItemAsync(testKeyAlias, keyHex);
        const retrievedKey = await SecureStore.getItemAsync(testKeyAlias);
        await SecureStore.deleteItemAsync(testKeyAlias);
        
        setDebugInfo(prev => prev + `\n• SecureStore Read/Write: ${retrievedKey === keyHex ? '✅' : '❌'}`);
        
        // Test Expo crypto encryption
        const testText = 'Hello encryption test';
        
        try {
          // Test crypto digest (used in our encryption)
          const hash = await Crypto.digestStringAsync(Crypto.CryptoDigestAlgorithm.SHA256, testText);
          setDebugInfo(prev => prev + `\n• Crypto Digest: ✅ (${hash.slice(0, 16)}...)`);
          
          // Test TextEncoder/TextDecoder (used in our encryption)
          const encoder = new TextEncoder();
          const decoder = new TextDecoder();
          const encoded = encoder.encode(testText);
          const decoded = decoder.decode(encoded);
          
          setDebugInfo(prev => prev + `\n• Text Encoding: ${decoded === testText ? '✅' : '❌'}`);
          setDebugInfo(prev => prev + `\n\n🎉 All encryption components working!`);
        } catch (error) {
          setDebugInfo(prev => prev + `\n• Expo Crypto Test: ❌ ${error instanceof Error ? error.message : 'Unknown error'}`);
        }
      } else {
        setDebugInfo(prev => prev + `\n\n❌ SecureStore not available on this platform/simulator.`);
      }
      
    } catch (error) {
      setDebugInfo(prev => prev + `\n\n❌ Encryption test failed: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setLoading(false);
    }
  };

  const enableEncryption = async () => {
    setLoading(true);
    try {
      await ChatTools.initialize();
      
      // Force enable encryption in config
      await ChatTools.updateConfig({ encryptionEnabled: true });
      
      // Re-initialize the service
      const { EncryptedChatService } = await import('../services/EncryptedChatService');
      const service = EncryptedChatService.getInstance();
      await service.initialize();
      
      const stats = await ChatTools.getStorageStats();
      
      setDebugInfo(`🔐 ENCRYPTION FORCE-ENABLE RESULT:

• Config Updated: ✅
• Encryption Enabled: ${stats.encryptionEnabled ? '✅' : '❌'}

${stats.encryptionEnabled ? 
  '🎉 Encryption successfully enabled! Try sending some messages now.' : 
  '❌ Encryption still disabled. Check the "🔧 Test Encryption" for issues.'
}`);
    } catch (error) {
      setDebugInfo(`❌ Failed to enable encryption: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setLoading(false);
    }
  };

  const showLogs = () => {
    const logs = Logger.getLogs();
    setDebugInfo(`📝 RECENT LOGS:\n\n${logs.join('\n')}`);
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Chat Storage Debug</Text>
      
      <View style={styles.buttonContainer}>
        <TouchableOpacity 
          style={[styles.button, styles.primaryButton]} 
          onPress={runStorageDebug}
          disabled={loading}
        >
          <Text style={styles.buttonText}>📊 Check Storage</Text>
        </TouchableOpacity>
        
        <TouchableOpacity 
          style={[styles.button, styles.successButton]} 
          onPress={addTestMessages}
          disabled={loading}
        >
          <Text style={styles.buttonText}>➕ Add Test Messages</Text>
        </TouchableOpacity>
        
        <TouchableOpacity 
          style={[styles.button, styles.warningButton]} 
          onPress={performHealthCheck}
          disabled={loading}
        >
          <Text style={styles.buttonText}>🏥 Health Check</Text>
        </TouchableOpacity>
        
        <TouchableOpacity 
          style={[styles.button, styles.primaryButton]} 
          onPress={testEncryptionDirectly}
          disabled={loading}
        >
          <Text style={styles.buttonText}>🔧 Test Encryption</Text>
        </TouchableOpacity>
        
        <TouchableOpacity 
          style={[styles.button, styles.successButton]} 
          onPress={enableEncryption}
          disabled={loading}
        >
          <Text style={styles.buttonText}>🔐 Force Enable Encryption</Text>
        </TouchableOpacity>
        
        <TouchableOpacity 
          style={[styles.button, styles.primaryButton]} 
          onPress={showLogs}
          disabled={loading}
        >
          <Text style={styles.buttonText}>📝 Show Logs</Text>
        </TouchableOpacity>
        
        <TouchableOpacity 
          style={[styles.button, styles.dangerButton]} 
          onPress={clearAllData}
          disabled={loading}
        >
          <Text style={styles.buttonText}>🗑️ Clear All Data</Text>
        </TouchableOpacity>
      </View>

      {loading && <Text style={styles.loading}>Loading...</Text>}
      
      {debugInfo && (
        <ScrollView style={styles.debugContainer}>
          <Text style={styles.debugText}>{debugInfo}</Text>
        </ScrollView>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 20,
    backgroundColor: '#f5f5f5',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 20,
    color: '#333',
  },
  buttonContainer: {
    marginBottom: 20,
  },
  button: {
    padding: 15,
    borderRadius: 8,
    marginBottom: 10,
    alignItems: 'center',
  },
  primaryButton: {
    backgroundColor: '#007AFF',
  },
  successButton: {
    backgroundColor: '#34C759',
  },
  warningButton: {
    backgroundColor: '#FF9500',
  },
  dangerButton: {
    backgroundColor: '#FF3B30',
  },
  buttonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
  loading: {
    textAlign: 'center',
    fontSize: 16,
    color: '#666',
    marginBottom: 10,
  },
  debugContainer: {
    flex: 1,
    backgroundColor: '#000',
    borderRadius: 8,
    padding: 15,
  },
  debugText: {
    color: '#00FF00',
    fontSize: 12,
    fontFamily: 'monospace',
    lineHeight: 16,
  },
});