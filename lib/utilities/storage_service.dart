import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // Singleton instance
  static final StorageService _instance = StorageService._internal();

  // SharedPreferences instance
  late SharedPreferences _prefs;

  // Factory constructor
  factory StorageService() {
    return _instance;
  }

  // Internal constructor
  StorageService._internal();

  // Initialize storage service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Get string value from storage
  String? getString(String key) {
    return _prefs.getString(key);
  }

  // Set string value in storage
  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  // Get boolean value from storage
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  // Set boolean value in storage
  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  // Get int value from storage
  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  // Set int value in storage
  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  // Get double value from storage
  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  // Set double value in storage
  Future<bool> setDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }

  // Get object from storage
  Map<String, dynamic>? getObject(String key) {
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return null;
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  // Set object in storage
  Future<bool> setObject(String key, Map<String, dynamic> value) async {
    return await _prefs.setString(key, json.encode(value));
  }

  // Get list from storage
  List<dynamic>? getList(String key) {
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return null;
    return json.decode(jsonString) as List<dynamic>;
  }

  // Set list in storage
  Future<bool> setList(String key, List<dynamic> value) async {
    return await _prefs.setString(key, json.encode(value));
  }

  // Remove item from storage
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  // Clear all storage
  Future<bool> clear() async {
    return await _prefs.clear();
  }
}
