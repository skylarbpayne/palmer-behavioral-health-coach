import { prepareModel, getModel } from 'react-native-ai';
import { streamText } from 'ai';
import { BEHAVIORAL_HEALTH_COACH_SYSTEM_PROMPT, INITIAL_PROFILE_CHECK_PROMPT } from '../prompts/system-prompt';
import { ProfileTools } from '../utils/ProfileTools';

export interface AIResponse {
  text: string;
  profileUpdated: boolean;
  error?: string;
}

class AIService {
  private static instance: AIService;
  private modelId = 'gemma_2b_it_q4f32_1_MLC';
  private isInitialized = false;
  private isInitializing = false;

  static getInstance(): AIService {
    if (!AIService.instance) {
      AIService.instance = new AIService();
    }
    return AIService.instance;
  }

  async initialize(): Promise<void> {
    if (this.isInitialized || this.isInitializing) {
      return;
    }

    this.isInitializing = true;
    
    try {
      console.log('Preparing Gemma 2B model...');
      await prepareModel(this.modelId);
      this.isInitialized = true;
      console.log('AI Service initialized successfully');
    } catch (error) {
      console.error('Error initializing AI service:', error);
      this.isInitialized = false;
      throw error;
    } finally {
      this.isInitializing = false;
    }
  }

  async generateResponse(userMessage: string, conversationHistory: string[] = []): Promise<AIResponse> {
    if (!this.isInitialized) {
      console.log('AI not initialized, using fallback response');
      return {
        text: "I'm still starting up. Please give me a moment and try again.",
        profileUpdated: false
      };
    }

    try {
      // Get current profile summary
      const profileSummary = await ProfileTools.getProfileSummary();
      
      // Build conversation context
      const recentHistory = conversationHistory.slice(-10).join('\n');
      
      const prompt = `${BEHAVIORAL_HEALTH_COACH_SYSTEM_PROMPT}

## Current User Profile:
${profileSummary}

## Recent Conversation History:
${recentHistory}

## Current User Message:
${userMessage}

Please respond as PALMER, the behavioral health coach. If you need to update the user's profile based on information they've shared, describe what updates you would make and I'll handle them separately.`;

      console.log('Generating AI response...');
      
      const model = getModel(this.modelId);
      const { textStream } = await streamText({
        model: model,
        prompt: prompt,
        temperature: 0.7,
        maxTokens: 512,
      });

      let fullResponse = '';
      for await (const chunk of textStream) {
        fullResponse += chunk;
      }

      // Check if response contains profile update instructions
      const profileUpdated = await this.handleProfileUpdates(fullResponse, userMessage);

      return {
        text: fullResponse,
        profileUpdated: profileUpdated,
      };

    } catch (error) {
      console.error('Error generating AI response:', error);
      return {
        text: "I apologize, but I'm having trouble processing your message right now. Could you try again?",
        profileUpdated: false,
        error: error instanceof Error ? error.message : 'Unknown error'
      };
    }
  }

  async generateInitialProfileCheck(): Promise<string> {
    try {
      const profileSummary = await ProfileTools.getProfileSummary();
      
      if (profileSummary === 'No profile information available') {
        return `Hello! I'm PALMER, your personal behavioral health coach. I'm here to support you on your wellness journey.

To provide you with the most helpful and personalized guidance, I'd like to learn a bit about you. We can start with whatever you're comfortable sharing - your name, what brings you here today, or any health goals you're working on.

What would you like to begin with?`;
      }

      // If we have some profile info, provide a personalized greeting
      const hasName = await ProfileTools.hasSimpleField('firstName');
      const hasGoals = await ProfileTools.hasArrayItems('currentHealthGoals');
      const hasSymptoms = await ProfileTools.hasArrayItems('currentBehavioralHealthSymptoms');

      let greeting = "Hello";
      if (hasName) {
        const firstName = await ProfileTools.getSimpleField('firstName');
        if (firstName?.value) {
          greeting = `Hello, ${firstName.value}`;
        }
      }

      let message = `${greeting}! I'm PALMER, your behavioral health coach. `;

      if (!hasGoals && !hasSymptoms) {
        message += "I see I have some basic information about you, but I'd love to learn more about what you're hoping to work on. What brings you here today?";
      } else {
        message += "I'm here to support you with your wellness journey. How are you feeling today, and what would you like to focus on?";
      }

      return message;

    } catch (error) {
      console.error('Error generating initial profile check:', error);
      return "Hello! I'm PALMER, your behavioral health coach. I'm here to support you. How can I help you today?";
    }
  }

  private async handleProfileUpdates(aiResponse: string, userMessage: string): Promise<boolean> {
    // Simple pattern matching for common profile updates
    // In a more sophisticated implementation, this would be handled by the AI model itself
    // or through function calling capabilities
    
    let updated = false;
    const lowerUserMessage = userMessage.toLowerCase();

    try {
      // Check for name mentions
      if (lowerUserMessage.includes('my name is') || lowerUserMessage.includes("i'm ")) {
        const nameMatch = userMessage.match(/(?:my name is|i'm|i am) ([A-Za-z]+)/i);
        if (nameMatch && nameMatch[1]) {
          const name = nameMatch[1];
          const hasFirstName = await ProfileTools.hasSimpleField('firstName');
          if (!hasFirstName) {
            await ProfileTools.setFirstName(name);
            updated = true;
            console.log(`Added first name: ${name}`);
          }
        }
      }

      // Check for goal mentions
      if (lowerUserMessage.includes('goal') || lowerUserMessage.includes('want to') || lowerUserMessage.includes('trying to')) {
        // This is a simplified extraction - a real implementation would be more sophisticated
        if (lowerUserMessage.includes('lose weight')) {
          try {
            await ProfileTools.addHealthGoal('Lose weight');
            updated = true;
          } catch (e) {
            // Goal might already exist
          }
        }
        if (lowerUserMessage.includes('exercise more') || lowerUserMessage.includes('work out')) {
          try {
            await ProfileTools.addHealthGoal('Exercise regularly');
            updated = true;
          } catch (e) {
            // Goal might already exist
          }
        }
        if (lowerUserMessage.includes('sleep better')) {
          try {
            await ProfileTools.addHealthGoal('Improve sleep quality');
            updated = true;
          } catch (e) {
            // Goal might already exist
          }
        }
      }

      // Check for symptom mentions
      if (lowerUserMessage.includes('anxious') || lowerUserMessage.includes('anxiety')) {
        try {
          await ProfileTools.addBehavioralSymptom('Feeling anxious frequently');
          updated = true;
        } catch (e) {
          // Symptom might already exist
        }
      }
      if (lowerUserMessage.includes('depressed') || lowerUserMessage.includes('sad') || lowerUserMessage.includes('down')) {
        try {
          await ProfileTools.addBehavioralSymptom('Feeling down or sad');
          updated = true;
        } catch (e) {
          // Symptom might already exist
        }
      }
      if (lowerUserMessage.includes('stress') || lowerUserMessage.includes('overwhelmed')) {
        try {
          await ProfileTools.addBehavioralSymptom('Feeling stressed or overwhelmed');
          updated = true;
        } catch (e) {
          // Symptom might already exist
        }
      }

    } catch (error) {
      console.error('Error updating profile:', error);
    }

    return updated;
  }

  isReady(): boolean {
    return this.isInitialized;
  }

  private async generateContextAwareResponse(userMessage: string, conversationHistory: string[]): Promise<string> {
    // Get current profile information for context
    const profileSummary = await ProfileTools.getProfileSummary();
    const hasName = await ProfileTools.hasSimpleField('firstName');
    const userName = hasName ? (await ProfileTools.getSimpleField('firstName'))?.value || '' : '';
    
    // Use sophisticated behavioral health coaching responses
    return this.generateFallbackResponse(userMessage, userName, profileSummary, conversationHistory);
  }

  // Fallback response generator with context awareness
  generateFallbackResponse(userMessage: string, userName: string = '', profileSummary: string = '', conversationHistory: string[] = []): string {
    const message = userMessage.toLowerCase();
    const greeting = userName ? `Hello, ${userName}!` : "Hello!";
    
    if (message.includes('hello') || message.includes('hi')) {
      return `${greeting} I'm PALMER, your behavioral health coach. I'm here to support you on your wellness journey. What would you like to work on today?`;
    } else if (message.includes('goal') || message.includes('goals')) {
      return "Setting health goals is an important step in your wellness journey. I can help you identify, track, and achieve your goals. What specific area would you like to focus on?";
    } else if (message.includes('anxious') || message.includes('anxiety')) {
      return "I understand that anxiety can be challenging. There are many effective strategies we can explore together, such as breathing exercises, grounding techniques, and gradual exposure. What situations tend to trigger your anxiety?";
    } else if (message.includes('sad') || message.includes('depressed') || message.includes('down')) {
      return "I hear that you're going through a difficult time. It takes courage to reach out. There are evidence-based approaches that can help, including behavioral activation and mindfulness practices. How long have you been feeling this way?";
    } else if (message.includes('stress') || message.includes('overwhelmed')) {
      return "Feeling overwhelmed is something many people experience. Let's work together to identify what's contributing to your stress and develop some coping strategies. What aspects of your life feel most stressful right now?";
    } else if (message.includes('sleep')) {
      return "Good sleep is fundamental to mental health. I can help you develop better sleep hygiene habits and address factors that might be interfering with your rest. What's your current sleep pattern like?";
    } else if (message.includes('thank')) {
      return userName ? `You're welcome, ${userName}! I'm here whenever you need support.` : "You're welcome! I'm here whenever you need support.";
    } else {
      return "Thank you for sharing that with me. I'm here to support you on your health journey. Could you tell me more about what you're experiencing or what you'd like to work on?";
    }
  }
}

export default AIService;