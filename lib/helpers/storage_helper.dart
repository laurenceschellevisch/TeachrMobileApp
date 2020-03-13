import 'dart:core';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Store a key/value pair in FlutterSecureStorage.
/// The value can only be retrieved using [readValue(_key)].
Future<void> storeKeyValue(String _key, String _value) async {
  final FlutterSecureStorage _secureStorage = new FlutterSecureStorage();

  await _secureStorage.write(key: _key, value: _value);
}

/// Read the value of a key inside FlutterSecureStorage.
/// You have to store a key/value pair first using [storeKeyValue(_key, _value)].
readValue(String _key) async {
  final FlutterSecureStorage _secureStorage = new FlutterSecureStorage();

  return await _secureStorage.read(key: _key);
}

/// Delete a key and it's value inside FlutterSecureStorage.
deleteKeyValue(String _key) async {
  final FlutterSecureStorage _secureStorage = new FlutterSecureStorage();

  await _secureStorage.delete(key: _key);
}

/// Store a key/value pair in SharedPreferences.
/// The value must be either a String, boolean or int.
/// The stored value can be retrieved later on using [readSharedPref(_key)].
setSharedPref(String _key, var _value) async {
  final SharedPreferences _sharedPrefs = await SharedPreferences.getInstance();
  switch (_value.runtimeType) {
    case String:
      {
        await _sharedPrefs.setString(_key, _value);
      }
      break;
    case bool:
      {
        await _sharedPrefs.setBool(_key, _value);
      }
      break;
    case int:
      {
        await _sharedPrefs.setInt(_key, _value);
      }
      break;
  }
  debugPrint("setSharedPref()" +
      _value.runtimeType.toString() +
      "=" +
      _value.toString());
}

/// Read the value of a key in SharedPreferences. Returns any kind of type.
readSharedPref(String _key) async {
  final SharedPreferences _sharedPrefs = await SharedPreferences.getInstance();

  return _sharedPrefs.get(_key);
}

