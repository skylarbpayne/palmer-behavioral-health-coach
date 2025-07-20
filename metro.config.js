const { getDefaultConfig } = require('expo/metro-config');

const config = getDefaultConfig(__dirname);

// Enable console logging to terminal
config.resolver.platforms = ['ios', 'android', 'native', 'web'];

module.exports = config;