# Palmer Behavioral Health Coach

A React Native mobile application for personal health coaching through locally running LLMs. This app provides a health summary view and chat interface for interacting with your personal health coach.

## Features

- **Health Summary**: View your daily health metrics, goal progress, and personalized suggestions
- **Health Coach Chat**: Chat with your AI health coach (coming soon)
- **Real-time Updates**: Health summary updates based on coach interactions
- **Local AI**: Designed to work with on-device LLM inference for privacy and offline functionality

## Current Implementation

This initial version includes:
- ✅ Health summary view with fake data
- ✅ Basic navigation structure (Summary and Chat tabs)
- ✅ Clean, mobile-optimized UI
- ⏳ Chat functionality (placeholder view)
- ⏳ LLM integration
- ⏳ Real health data integration
- ⏳ Notification system

## Prerequisites

- Node.js (v18 or later)
- npm or yarn
- Expo CLI (`npm install -g @expo/cli`)
- For iOS: Xcode and iOS Simulator
- For Android: Android Studio and Android emulator

## Installation & Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd palmer-behavioral-health-coach
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Start the development server**
   ```bash
   npm start
   # or
   npx expo start
   ```

## Running the App

### Web (for quick testing)
```bash
npm run web
```

### iOS Simulator
```bash
npm run ios
```

### Android Emulator
```bash
npm run android
```

### Physical Device
1. Install Expo Go app on your device
2. Scan the QR code displayed in terminal/browser after running `npm start`

## Project Structure

```
├── App.tsx                 # Main app with navigation
├── components/
│   ├── HealthSummary.tsx   # Health summary view
│   └── ChatScreen.tsx      # Chat interface (placeholder)
├── assets/                 # App icons and images
└── package.json           # Dependencies
```

## Health Summary Features

The health summary displays:
- **Health Metrics**: Sleep, steps, heart rate, stress level with status indicators
- **Goals Progress**: Visual progress bars for daily goals
- **Suggestions & Accomplishments**: Actionable health recommendations and completed tasks

All data is currently mocked for demonstration purposes.

## Development Notes

- Built with Expo for cross-platform compatibility
- Uses React Navigation for tab-based navigation
- TypeScript for type safety
- Designed mobile-first with responsive layouts
- Follows React Native best practices

## Future Enhancements

- Integration with health data sources (HealthKit, Google Fit)
- On-device LLM integration (likely Gemma 3n)
- Real-time chat functionality
- Push notifications for health reminders
- Data persistence and analytics
- Personalized health insights

## Contributing

This is an early-stage project. Focus on keeping implementations simple and building incrementally.