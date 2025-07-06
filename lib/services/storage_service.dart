import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static const String _autoSaveKey = 'auto_saved_form';
  static const String _pendingSubmissionsKey = 'pending_submissions';
  

  static Future<void> saveFormData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_autoSaveKey, json.encode(data));
  }
  
  static Future<Map<String, dynamic>?> loadFormData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString(_autoSaveKey);
    if (savedData != null) {
      return json.decode(savedData);
    }
    return null;
  }
  
  static Future<void> clearAutoSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_autoSaveKey);
  }
  
 
  static Future<void> savePendingSubmission(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingData = await loadPendingSubmissions();
    pendingData.add(data);
    
    final stringList = pendingData.map((e) => json.encode(e)).toList();
    await prefs.setStringList(_pendingSubmissionsKey, stringList);
  }
  
  static Future<List<Map<String, dynamic>>> loadPendingSubmissions() async {
    final prefs = await SharedPreferences.getInstance();
    final pendingData = prefs.getStringList(_pendingSubmissionsKey) ?? [];
    return pendingData.map((e) => json.decode(e)).toList().cast<Map<String, dynamic>>();
  }
  
  static Future<void> removePendingSubmission(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingData = await loadPendingSubmissions();
    pendingData.removeWhere((item) => 
      item['submitted_at'] == data['submitted_at']);
    
    final stringList = pendingData.map((e) => json.encode(e)).toList();
    await prefs.setStringList(_pendingSubmissionsKey, stringList);
  }
  
  static Future<void> clearPendingSubmissions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingSubmissionsKey);
  }
}