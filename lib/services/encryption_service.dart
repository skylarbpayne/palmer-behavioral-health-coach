import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  static const String _keyName = 'palmer_encryption_key';
  Encrypter? _encrypter;
  IV? _iv;

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get or generate encryption key
      String? keyString = prefs.getString(_keyName);
      if (keyString == null) {
        // Generate new key
        final key = Key.fromSecureRandom(32);
        keyString = base64.encode(key.bytes);
        await prefs.setString(_keyName, keyString);
      }
      
      // Create encrypter
      final key = Key.fromBase64(keyString);
      _encrypter = Encrypter(AES(key));
      
      // Generate IV for this session
      _iv = IV.fromSecureRandom(16);
    } catch (e) {
      print('Failed to initialize encryption: $e');
      rethrow;
    }
  }

  Future<String> encrypt(String plainText) async {
    if (_encrypter == null || _iv == null) {
      await initialize();
    }
    
    try {
      final encrypted = _encrypter!.encrypt(plainText, iv: _iv!);
      
      // Combine IV and encrypted data
      final combined = <int>[];
      combined.addAll(_iv!.bytes);
      combined.addAll(encrypted.bytes);
      
      return base64.encode(combined);
    } catch (e) {
      print('Failed to encrypt data: $e');
      throw Exception('Encryption failed');
    }
  }

  Future<String> decrypt(String encryptedData) async {
    if (_encrypter == null) {
      await initialize();
    }
    
    try {
      final combined = base64.decode(encryptedData);
      
      // Extract IV and encrypted data
      final iv = IV(Uint8List.fromList(combined.take(16).toList()));
      final encryptedBytes = combined.skip(16).toList();
      final encrypted = Encrypted(Uint8List.fromList(encryptedBytes));
      
      return _encrypter!.decrypt(encrypted, iv: iv);
    } catch (e) {
      print('Failed to decrypt data: $e');
      throw Exception('Decryption failed');
    }
  }

  Future<void> clearKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyName);
      _encrypter = null;
      _iv = null;
    } catch (e) {
      print('Failed to clear encryption key: $e');
    }
  }

  bool get isInitialized => _encrypter != null && _iv != null;
}