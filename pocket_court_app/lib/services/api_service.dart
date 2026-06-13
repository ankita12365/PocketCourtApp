import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import '../models/law_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';
  static const _timeout = Duration(seconds: 10);
  static const _headers = {'Content-Type': 'application/json'};

  static void _assertOk(http.Response res, String ctx) {
    if (res.statusCode != 200 && res.statusCode != 201) {
      final msg =
          jsonDecode(res.body)['message'] ?? '$ctx failed (${res.statusCode})';
      throw Exception(msg);
    }
  }

  static Future<http.Response> _get(String url) async {
    try {
      return await http
          .get(Uri.parse(url), headers: _headers)
          .timeout(_timeout);
    } on SocketException {
      throw Exception(
          'Cannot reach server. Run: adb reverse tcp:5000 tcp:5000');
    } on TimeoutException {
      throw Exception('Request timed out. Is the backend running?');
    }
  }

  static Future<List<CategoryModel>> getCategories() async {
    final res = await _get('$baseUrl/categories');
    _assertOk(res, 'Load categories');
    return (jsonDecode(res.body)['data'] as List)
        .map((e) => CategoryModel.fromJson(e))
        .toList();
  }

  static Future<List<String>> getSituations(String category) async {
    final res =
        await _get('$baseUrl/situations/${Uri.encodeComponent(category)}');
    _assertOk(res, 'Load situations');
    return List<String>.from(jsonDecode(res.body)['data']);
  }

  static Future<LawModel> getLaw(String category, String situation) async {
    try {
      final uri = Uri.parse('$baseUrl/law').replace(
          queryParameters: {'category': category, 'situation': situation});
      final res = await http.get(uri, headers: _headers).timeout(_timeout);
      _assertOk(res, 'Load law');
      return LawModel.fromJson(jsonDecode(res.body)['data']);
    } on SocketException {
      throw Exception(
          'Cannot reach server. Run: adb reverse tcp:5000 tcp:5000');
    } on TimeoutException {
      throw Exception('Request timed out. Is the backend running?');
    }
  }

  static Future<List<LawModel>> getAllLaws() async {
    final res = await _get('$baseUrl/laws');
    _assertOk(res, 'Load laws');
    return (jsonDecode(res.body)['data'] as List)
        .map((e) => LawModel.fromJson(e))
        .toList();
  }
}
