# CLAUDE.md - Development Notes

## Key Insights and Decisions

### Issue #1 Implementation (Health Summary Skeleton)
**Date**: 2025-07-13

**Key Design Decisions**:
- Used Expo for rapid prototyping and cross-platform compatibility
- Implemented component-based architecture with separate HealthSummary and ChatScreen components
- Created extensible data structures (HealthMetric, Goal, Suggestion interfaces) that can easily integrate with real data sources
- Used React Navigation with bottom tabs for intuitive mobile UX

**Important Pattern**: 
The health summary is designed with clear separation between data and presentation. The fake data structures mirror what we'll need for real health data integration, making future LLM integration straightforward.

**Architecture Notes**:
- App.tsx handles navigation and overall app structure
- components/ directory contains feature-specific screens
- Each component is self-contained with its own styles
- Ready for state management integration when adding real-time chat updates

**Next Steps**: 
1. LLM integration (likely Gemma 3n based on notes.md research)
2. Real health data sources (HealthKit/Google Fit)
3. Chat functionality with health summary updates
4. Notification system for health changes

This foundation supports the core requirement: a health coach that can update the summary in real-time through chat interactions.

### Issue #3 Implementation (User Profile System)

**Date**: 2025-07-13

**Key Design Decisions**:

- Created comprehensive UserProfile interface with all required fields (personal info, health goals, symptoms, interventions)
- Implemented secure local storage using AsyncStorage with singleton pattern for data consistency
- Added comprehensive timestamp tracking for both "last changed" and "last confirmed" on all fields
- Created LLM-friendly tool functions for easy profile management and updates
- All data stored locally and never leaves the device as required

**Architecture Components**:

- `types/UserProfile.ts` - TypeScript interfaces for profile data structure
- `services/UserProfileService.ts` - Core service handling secure storage and data management
- `utils/ProfileTools.ts` - Easy-to-use utility functions designed for LLM integration
- Full timestamp tracking with metadata for audit trails

**Security Features**:

- All data stored locally using AsyncStorage (never transmitted)
- Singleton pattern ensures data consistency across app
- Error handling for storage failures
- Date serialization/deserialization for proper timestamp handling

**LLM Integration Ready**:
The ProfileTools provide a complete set of functions that an LLM can use to manage user profile data, including adding/removing goals, symptoms, and interventions, plus confirmation workflows.

### Issue #3 Updates (Item-Level Metadata & Validation)
**Date**: 2025-07-13

**Major Improvements**:
- **Item-level metadata tracking**: Every field and array item now has its own lastChanged/lastConfirmed timestamps
- **Zod validation**: Added comprehensive data validation schemas for type safety and data integrity
- **UUID-based array items**: Each goal, symptom, and intervention has a unique ID for precise tracking
- **Enhanced ProfileTools**: Complete rewrite with methods for individual item management

**Key Architecture Changes**:
- `ProfileField<T>` structure for simple fields with individual metadata
- `ProfileArrayItem<T>` structure for array items with unique IDs and metadata
- Zod schemas for runtime validation and type safety
- Comprehensive serialization/deserialization for date handling

**New Capabilities**:
- Track when each individual goal was added, modified, or confirmed
- Update specific symptoms by ID while preserving others
- Detailed audit trails for all profile changes
- LLM can now manage individual items with precise control

**Dependencies Added**:
- `zod` for data validation
- `uuid` for unique item identification
- `@types/uuid` for TypeScript support

### Issue #5 Implementation (AI Chat Integration)
**Date**: 2025-07-20

**Key Design Decisions**:
- Integrated React Native AI library with Gemma 2B model for on-device LLM processing
- Created comprehensive behavioral health coach system prompt with evidence-based guidelines
- Implemented graceful fallback system for when AI model is not available
- Connected AI to existing user profile system for personalized responses and automatic profile updates

**Architecture Components**:
- `services/AIService.ts` - Core AI service managing Gemma 2B model interaction
- `prompts/system-prompt.ts` - Comprehensive system prompt and behavioral guidelines for health coaching
- `mlc-config.json` - Model configuration for React Native AI library
- Enhanced `ChatScreen.tsx` - Integrated AI responses with visual loading indicators

**AI Features**:
- **Personalized responses** based on user profile data (goals, symptoms, interventions)
- **Automatic profile updates** from conversation context (names, goals, symptoms)
- **Evidence-based coaching** following behavioral health best practices
- **Fallback responses** when AI model is unavailable
- **Profile-aware welcome messages** that adapt to user's current information

**Technical Implementation**:
- Uses React Native AI with MLC LLM Engine for on-device processing
- Graceful degradation when model preparation dependencies are missing
- Non-blocking AI initialization to maintain app responsiveness
- Conversation history context for coherent multi-turn conversations

**Dependencies Added**:
- `react-native-ai` for on-device LLM processing
- `ai` (Vercel AI SDK) for text streaming capabilities

**Current Status**:
- ✅ AI service implemented with fallback system
- ✅ Chat screen integrated with AI responses
- ✅ Profile system connected for personalization
- ⏳ Model preparation requires Git LFS and Rust installation
- ⏳ Full Gemma 2B model download and preparation pending

**Next Steps**:
1. Install Git LFS and Rust for complete model preparation
2. Test AI responses with actual model once prepared
3. Fine-tune system prompts based on user feedback
4. Add more sophisticated profile update extraction

## Important Reminders

- Always create a PR for your work