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
import AIService from '../services/AIService';

export default function ChatScreen() {
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [inputText, setInputText] = useState('');
  const [loading, setLoading] = useState(true);
  const [initialized, setInitialized] = useState(false);
  const [aiLoading, setAiLoading] = useState(false);
  const flatListRef = useRef<FlatList>(null);
  const aiService = AIService.getInstance();

  useEffect(() => {
    initializeChatService();
  }, []);

  const initializeChatService = async () => {
    try {
      console.log('Initializing chat service...');
      setLoading(true);
      
      // Initialize chat tools
      await ChatTools.initialize();
      console.log('ChatTools initialized successfully');
      
      // Initialize AI service (non-blocking)
      aiService.initialize().catch(error => {
        console.log('AI service initialization failed, will use fallback responses:', error);
      });
      
      await loadMessages();
      console.log('Messages loaded successfully');
      setInitialized(true);
      console.log('Chat service fully initialized');
    } catch (error) {
      console.error('Error initializing chat service:', error);
      // Add default welcome message if initialization fails
      const welcomeMessage = await aiService.generateInitialProfileCheck();
      setMessages([{
        id: '1',
        text: welcomeMessage,
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
        // Generate personalized welcome message using AI
        const welcomeText = await aiService.generateInitialProfileCheck();
        const welcomeMessage = await ChatTools.addCoachResponse(welcomeText);
        setMessages([welcomeMessage]);
      } else {
        setMessages(existingMessages);
      }
    } catch (error) {
      console.error('Error loading messages:', error);
      const fallbackWelcome = await aiService.generateInitialProfileCheck();
      setMessages([{
        id: '1',
        text: fallbackWelcome,
        isUser: false,
        timestamp: new Date(),
      }]);
    }
  };

  const generateAIResponse = async (userMessage: string, conversationHistory: string[]): Promise<string> => {
    setAiLoading(true);
    
    try {
      if (aiService.isReady()) {
        console.log('Generating AI response...');
        const aiResponse = await aiService.generateResponse(userMessage, conversationHistory);
        
        if (aiResponse.profileUpdated) {
          console.log('Profile was updated based on conversation');
        }
        
        if (aiResponse.error) {
          console.log('AI response had error, using fallback');
          return aiService.generateFallbackResponse(userMessage);
        }
        
        return aiResponse.text;
      } else {
        console.log('AI not ready, using fallback response');
        return aiService.generateFallbackResponse(userMessage);
      }
    } catch (error) {
      console.error('Error generating AI response:', error);
      return aiService.generateFallbackResponse(userMessage);
    } finally {
      setAiLoading(false);
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
      
      setTimeout(async () => {
        const conversationHistory = messages.map(msg => `${msg.isUser ? 'User' : 'Coach'}: ${msg.text}`);
        const responseText = await generateAIResponse(messageText, conversationHistory);
        
        const coachResponse: ChatMessage = {
          id: (Date.now() + 1).toString(),
          text: responseText,
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
          console.log('Generating coach response...');
          const conversationHistory = messages.map(msg => `${msg.isUser ? 'User' : 'Coach'}: ${msg.text}`);
          const responseText = await generateAIResponse(messageText, conversationHistory);
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
        <Text style={styles.title}>PALMER</Text>
        <Text style={styles.subtitle}>
          {aiLoading ? 'Thinking... 🤔' : 'Your behavioral health coach 🔒'}
        </Text>
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