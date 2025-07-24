const { getDefaultConfig } = require('expo/metro-config');

const config = getDefaultConfig(__dirname);

// Enable console logging to terminal
config.resolver.platforms = ['ios', 'android', 'native', 'web'];

// Add polyfills for AI SDK
config.resolver.alias = {
  ...config.resolver.alias,
  'text-encoding': require.resolve('text-encoding'),
};

module.exports = config;