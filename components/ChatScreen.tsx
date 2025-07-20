import React, { useState, useRef, useEffect } from 'react';
import { 
  StyleSheet, 
  Text, 
  View, 
  TextInput, 
  TouchableOpacity, 
  FlatList, 
  KeyboardAvoidingView,
  Platform,
  ActivityIndicator 
} from 'react-native';
import { ProfileTools } from '../utils/ProfileTools';
import { ChatTools } from '../utils/ChatTools';
import { ChatMessage } from '../types/ChatTypes';

export default function ChatScreen() {
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [inputText, setInputText] = useState('');
  const [loading, setLoading] = useState(true);
  const [initialized, setInitialized] = useState(false);
  const flatListRef = useRef<FlatList>(null);

  useEffect(() => {
    initializeChatService();
  }, []);

  const initializeChatService = async () => {
    try {
      console.log('Initializing chat service...');
      setLoading(true);
      await ChatTools.initialize();
      console.log('ChatTools initialized successfully');
      await loadMessages();
      console.log('Messages loaded successfully');
      setInitialized(true);
      console.log('Chat service fully initialized');
    } catch (error) {
      console.error('Error initializing chat service:', error);
      // Add default welcome message if initialization fails
      setMessages([{
        id: '1',
        text: "Hello! I'm your personal health coach. How can I help you today?",
        isUser: false,
        timestamp: new Date(),
      }]);
      console.log('Added fallback welcome message');
    } finally {
      setLoading(false);
      console.log('Loading complete, initialized:', initialized);
    }
  };

  const loadMessages = async () => {
    try {
      const existingMessages = await ChatTools.getRecentMessages(100);
      
      if (existingMessages.length === 0) {
        // Add welcome message for new conversations
        const welcomeMessage = await ChatTools.addCoachResponse(
          "Hello! I'm your personal health coach. How can I help you today?"
        );
        setMessages([welcomeMessage]);
      } else {
        setMessages(existingMessages);
      }
    } catch (error) {
      console.error('Error loading messages:', error);
      setMessages([{
        id: '1',
        text: "Hello! I'm your personal health coach. How can I help you today?",
        isUser: false,
        timestamp: new Date(),
      }]);
    }
  };

  const getHardcodedResponse = (userMessage: string): string => {
    const message = userMessage.toLowerCase();
    
    if (message.includes('hello') || message.includes('hi')) {
      return "Hello! I'm here to help you with your health journey. What would you like to discuss?";
    } else if (message.includes('goal') || message.includes('goals')) {
      return "Setting health goals is important! I can help you track and achieve your goals. What specific goal would you like to work on?";
    } else if (message.includes('symptom') || message.includes('symptoms')) {
      return "I understand you want to discuss symptoms. I'm here to listen and provide support. Can you tell me more about what you're experiencing?";
    } else if (message.includes('help')) {
      return "I'm here to support your health journey! I can help with goal setting, tracking symptoms, discussing interventions, and providing general wellness guidance.";
    } else if (message.includes('profile') || message.includes('information')) {
      return "I can access your profile information to provide personalized guidance. This helps me understand your health goals and current situation better.";
    } else {
      return "Thank you for sharing that with me. I'm here to support you on your health journey. Is there something specific you'd like to work on today?";
    }
  };

  const sendMessage = async () => {
    
    if (inputText.trim() === '') {
      console.log('Empty message, not sending');
      return;
    }
    
    if (!initialized) {
      console.log('Not initialized, falling back to simple message handling');
      // Fallback to simple message handling if encryption isn't working
      const messageText = inputText.trim();
      setInputText('');
      
      const userMessage: ChatMessage = {
        id: Date.now().toString(),
        text: messageText,
        isUser: true,
        timestamp: new Date(),
      };
      
      setMessages(prev => [...prev, userMessage]);
      
      setTimeout(() => {
        const coachResponse: ChatMessage = {
          id: (Date.now() + 1).toString(),
          text: getHardcodedResponse(messageText),
          isUser: false,
          timestamp: new Date(),
        };
        
        setMessages(prev => [...prev, coachResponse]);
        
        setTimeout(() => {
          flatListRef.current?.scrollToEnd({ animated: true });
        }, 100);
      }, 1000);
      
      return;
    }

    const messageText = inputText.trim();
    setInputText('');

    try {
      console.log('Attempting to add user message via ChatTools...');
      // Add user message to encrypted storage
      const userMessage = await ChatTools.addUserMessage(messageText);
      console.log('User message added successfully:', userMessage);
      setMessages(prev => [...prev, userMessage]);

      // Scroll to bottom after user message
      setTimeout(() => {
        flatListRef.current?.scrollToEnd({ animated: true });
      }, 100);

      // Generate and add coach response after delay
      setTimeout(async () => {
        try {
          console.log('Adding coach response...');
          const responseText = getHardcodedResponse(messageText);
          const coachResponse = await ChatTools.addCoachResponse(responseText);
          console.log('Coach response added successfully:', coachResponse);
          setMessages(prev => [...prev, coachResponse]);
          
          setTimeout(() => {
            flatListRef.current?.scrollToEnd({ animated: true });
          }, 100);
        } catch (error) {
          console.error('Error adding coach response:', error);
        }
      }, 1000);
    } catch (error) {
      console.error('Error sending message:', error);
      // Restore input text if there was an error
      setInputText(messageText);
    }
  };

  const renderMessage = ({ item }: { item: ChatMessage }) => (
    <View style={[
      styles.messageContainer,
      item.isUser ? styles.userMessage : styles.coachMessage
    ]}>
      <Text style={[
        styles.messageText,
        item.isUser ? styles.userMessageText : styles.coachMessageText
      ]}>
        {item.text}
      </Text>
      <Text style={styles.timestamp}>
        {item.timestamp.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
      </Text>
    </View>
  );

  if (loading) {
    return (
      <View style={[styles.container, styles.centered]}>
        <ActivityIndicator size="large" color="#007AFF" />
        <Text style={styles.loadingText}>Initializing secure chat...</Text>
      </View>
    );
  }

  return (
    <KeyboardAvoidingView 
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <View style={styles.header}>
        <Text style={styles.title}>Health Coach</Text>
        <Text style={styles.subtitle}>Your personal wellness companion 🔒</Text>
      </View>
      
      <FlatList
        ref={flatListRef}
        data={messages}
        renderItem={renderMessage}
        keyExtractor={(item) => item.id}
        style={styles.messagesList}
        contentContainerStyle={styles.messagesContainer}
        showsVerticalScrollIndicator={false}
        onContentSizeChange={() => flatListRef.current?.scrollToEnd({ animated: true })}
      />
      
      <View style={styles.inputContainer}>
        <TextInput
          style={styles.textInput}
          value={inputText}
          onChangeText={setInputText}
          placeholder="Type your message..."
          placeholderTextColor="#999"
          multiline
          maxLength={500}
          onSubmitEditing={sendMessage}
          blurOnSubmit={false}
        />
        <TouchableOpacity 
          style={[styles.sendButton, inputText.trim() ? styles.sendButtonActive : null]}
          onPress={sendMessage}
          disabled={inputText.trim() === ''}
        >
          <Text style={[styles.sendButtonText, inputText.trim() ? styles.sendButtonTextActive : null]}>
            Send
          </Text>
        </TouchableOpacity>
      </View>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  centered: {
    justifyContent: 'center',
    alignItems: 'center',
  },
  loadingText: {
    marginTop: 16,
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
  },
  header: {
    backgroundColor: '#fff',
    paddingTop: 50,
    paddingBottom: 15,
    paddingHorizontal: 20,
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 14,
    color: '#666',
    textAlign: 'center',
    marginTop: 2,
  },
  messagesList: {
    flex: 1,
  },
  messagesContainer: {
    padding: 20,
    paddingBottom: 10,
  },
  messageContainer: {
    marginVertical: 5,
    maxWidth: '80%',
    borderRadius: 15,
    padding: 12,
  },
  userMessage: {
    alignSelf: 'flex-end',
    backgroundColor: '#007AFF',
    marginLeft: '20%',
  },
  coachMessage: {
    alignSelf: 'flex-start',
    backgroundColor: '#fff',
    marginRight: '20%',
    borderWidth: 1,
    borderColor: '#e0e0e0',
  },
  messageText: {
    fontSize: 16,
    lineHeight: 20,
  },
  userMessageText: {
    color: '#fff',
  },
  coachMessageText: {
    color: '#333',
  },
  timestamp: {
    fontSize: 11,
    color: '#999',
    marginTop: 4,
    alignSelf: 'flex-end',
  },
  inputContainer: {
    flexDirection: 'row',
    padding: 20,
    backgroundColor: '#fff',
    borderTopWidth: 1,
    borderTopColor: '#e0e0e0',
    alignItems: 'flex-end',
  },
  textInput: {
    flex: 1,
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 20,
    paddingHorizontal: 15,
    paddingVertical: 10,
    marginRight: 10,
    maxHeight: 100,
    fontSize: 16,
    backgroundColor: '#f9f9f9',
  },
  sendButton: {
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: 20,
    backgroundColor: '#f0f0f0',
  },
  sendButtonActive: {
    backgroundColor: '#007AFF',
  },
  sendButtonText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#999',
  },
  sendButtonTextActive: {
    color: '#fff',
  },
});