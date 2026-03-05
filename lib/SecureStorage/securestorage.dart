import 'package:cyklze/widgets/date_time.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer' as developer;
import 'dart:convert';

class SecureStorage {
  // Create storage instance
  static const _storage = FlutterSecureStorage();

  // Keys
  static const _accessTokenKey = "CYKLZE_ACCESS_TOKEN_KEY";
    static const _isfirst = "CYKLZE_FIRST_KEY";
  static const _refreshTokenKey = "CYKLZE_REFRESH_TOKEN_KEY";
  static const _userAddressKey = "CYKLZE_USER_ADDRESS_KEY";
  static const _userAreasKey = "CYKLZE_USER_AREAS_KEY";
  static const _userCitiesKey = "CYKLZE_USER_CITIES_KEY";
    static const _userPostalRange = "CYKLZE_USER_POSTAL_KEY";
     static const _email = "CYKLZE_USER_HELP_EMAIL";
    static const _userRegxKey = "CYKLZE_USER_REGX_KEY";

  /// Save Access Token
  static Future<void> saveAccessToken(String token) async {
    try {
      await _storage.write(key: _accessTokenKey, value: token);
    } catch (e) {
     
      await clearAll();
    }
  }
static Future<void> saveCities(List<String> cities) async {
  try {
    await _storage.write(
      key: _userCitiesKey,
      value: jsonEncode(cities),
    );
  } catch (e) {
    await clearAll();
  }
}
static Future<void> saveemail(String cities) async {
  try {
    await _storage.write(
      key: _email,
      value: cities,
    );
  } catch (e) {
    await clearAll();
  }
}
static Future<String?> getemail() async {
  try {
  final value =  await _storage.read(
      key: _email
    );
    if (value == null) return 'support@cyklze.com';
    return value;
  } catch (e) {
    await clearAll();
  }
}

static Future<List<String>> getCities() async {
  try {
    final value = await _storage.read(key: _userCitiesKey);

    if (value == null) return [];

    return List<String>.from(jsonDecode(value));
  } catch (e) {
    await clearAll();
    return [];
  }
}

// static Future<void> savePostalRange( List<PostalCodeRange> postal) async {
//   try {
//     await _storage.write(
//       key: _userPostalRange,
//       value: jsonEncode(postal),
//     );
//   } catch (e) {
//     await clearAll();
//   }
// }
static Future<void> savePostalRange(List<PostalCodeRange> postal) async {
  try {
    final jsonString = jsonEncode(
      postal.map((e) => e.toJson()).toList(),
    );

    await _storage.write(
      key: _userPostalRange,
      value: jsonString,
    );
  } catch (e) {
    await clearAll();
  }
}

// static Future< List<PostalCodeRange>> getPostalRange() async {
//   try {
//     final value = await _storage.read(key: _userPostalRange);

//     if (value == null) return [];

//     return  List<PostalCodeRange>.from(jsonDecode(value));
//   } catch (e) {
//     await clearAll();
//     return [];
//   }
// }




static Future<List<PostalCodeRange>> getPostalRange() async {
  try {
    final value = await _storage.read(key: _userPostalRange);

    if (value == null) return [];

    final List decoded = jsonDecode(value);

    return decoded
        .map((e) => PostalCodeRange.fromJson(e))
        .toList();
  } catch (e) {
    await clearAll();
    return [];
  }
}

static Future<void> saveAreas(List<String> cities) async {
  try {
    await _storage.write(
      key: _userAreasKey,
      value: jsonEncode(cities),
    );
  } catch (e) {
    await clearAll();
  }
}

static Future<List<String>> getAreas() async {
  try {
    final value = await _storage.read(key: _userAreasKey);

    if (value == null) return [];

    return List<String>.from(jsonDecode(value));
  } catch (e) {
    await clearAll();
    return [];
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


 static Future<void> saveRegx(String address) async {
    try {
      await _storage.write(key: _userRegxKey, value: address);
    } catch (e) {
     await clearAll();
    }
  }

  /// Get User Address
  static Future<String?> getRegx() async {
    try {
      return await _storage.read(key: _userRegxKey);
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
