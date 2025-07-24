import 'text-encoding';

// Polyfill for crypto.randomUUID if needed
if (!global.crypto) {
  global.crypto = {};
}

if (!global.crypto.randomUUID) {
  global.crypto.randomUUID = () => {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
      const r = Math.random() * 16 | 0;
      const v = c === 'x' ? r : (r & 0x3 | 0x8);
      return v.toString(16);
    });
  };
}

// Polyfill for ReadableStream if needed (required by AI SDK)
if (typeof global.ReadableStream === 'undefined') {
  try {
    const { ReadableStream } = require('web-streams-polyfill/ponyfill');
    global.ReadableStream = ReadableStream;
  } catch (error) {
    console.warn('ReadableStream polyfill not available');
  }
}