import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String _baseUrl = 'https://httpbin.org/post';
  
  static Future<bool> submitScoreCard(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('API Error: $e');
      return false;
    }
  }
  
  static Future<bool> submitBatch(List<Map<String, dynamic>> submissions) async {
    try {
      for (final submission in submissions) {
        final success = await submitScoreCard(submission);
        if (!success) return false;
      }
      return true;
    } catch (e) {
      print('Batch submission error: $e');
      return false;
    }
  }
}