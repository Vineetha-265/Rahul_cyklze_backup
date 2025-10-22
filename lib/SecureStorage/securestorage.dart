import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer' as developer;

class SecureStorage {
  // Create storage instance
  static const _storage = FlutterSecureStorage();

  // Keys
  static const _accessTokenKey = "CYKLZE_ACCESS_TOKEN_KEY";
    static const _isfirst = "CYKLZE_FIRST_KEY";
  static const _refreshTokenKey = "CYKLZE_REFRESH_TOKEN_KEY";
  static const _userAddressKey = "CYKLZE_USER_ADDRESS_KEY";

  /// Save Access Token
  static Future<void> saveAccessToken(String token) async {
    try {
      await _storage.write(key: _accessTokenKey, value: token);
    } catch (e) {
     
      await clearAll();
    }
  }
    static Future<void> firstTime( ) async {
    try {
      await _storage.write(key: _isfirst, value: "firsttime");
    } catch (e) {
    
      await clearAll();
    }
  }

  static Future<String?> getFirstTime() async {
    try {
      return await _storage.read(key: _isfirst);
    } catch (e) {
     
      await clearAll();
      return null;
    }
  }

  /// Get Access Token
  static Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
    
      await clearAll();
      return null;
    }
  }

  /// Save Refresh Token
  static Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: token);
    } catch (e) {
      await clearAll();
    }
  }

  /// Get Refresh Token
  static Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      await clearAll();
      return null;
    }
  }

  /// Save User Address
  static Future<void> saveAddress(String address) async {
    try {
      await _storage.write(key: _userAddressKey, value: address);
    } catch (e) {
     await clearAll();
    }
  }

  /// Get User Address
  static Future<String?> getAddress() async {
    try {
      return await _storage.read(key: _userAddressKey);
    } catch (e) {
     await clearAll();
      return null;
    }
  }

  /// Clear everything (useful if corrupted or logout)
  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
    
    await _storage.deleteAll(); }
  }
}
