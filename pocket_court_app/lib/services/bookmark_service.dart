import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/law_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

class BookmarkService {
  static const _key = 'bookmarks';
  static List<LawModel>? _cache;

  static Future<List<LawModel>> getAll() async {
    if (AuthService.isLoggedIn) {
      try {
        final res = await http.get(
          Uri.parse('${ApiService.baseUrl}/bookmarks'),
          headers: {'Authorization': 'Bearer ${AuthService.token}'},
        ).timeout(const Duration(seconds: 10));
        if (res.statusCode == 200) {
          final json = jsonDecode(res.body);
          _cache =
              (json['data'] as List).map((e) => LawModel.fromJson(e)).toList();
          return List.unmodifiable(_cache!);
        }
      } catch (_) {}
    }
    if (_cache != null) return List.unmodifiable(_cache!);
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    _cache = raw.map((e) => LawModel.fromJson(jsonDecode(e))).toList();
    return List.unmodifiable(_cache!);
  }

  static Future<bool> isBookmarked(String category, String situation) async {
    final all = await getAll();
    return all.any((l) => l.category == category && l.situation == situation);
  }

  static Future<void> add(LawModel law) async {
    final all = await getAll();
    final exists = all
        .any((l) => l.category == law.category && l.situation == law.situation);
    if (exists) return;

    if (AuthService.isLoggedIn) {
      await http
          .post(
            Uri.parse('${ApiService.baseUrl}/bookmarks'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${AuthService.token}',
            },
            body: jsonEncode(law.toJson()),
          )
          .timeout(const Duration(seconds: 10));
    }

    _cache = [...all, law];
    await _persistLocal();
  }

  static Future<void> remove(String category, String situation) async {
    if (AuthService.isLoggedIn) {
      await http
          .delete(
            Uri.parse('${ApiService.baseUrl}/bookmarks'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${AuthService.token}',
            },
            body: jsonEncode({'category': category, 'situation': situation}),
          )
          .timeout(const Duration(seconds: 10));
    }

    final all = await getAll();
    _cache = all
        .where((l) => !(l.category == category && l.situation == situation))
        .toList();
    await _persistLocal();
  }

  static Future<void> _persistLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      (_cache ?? []).map((l) => jsonEncode(l.toJson())).toList(),
    );
  }

  static void invalidate() => _cache = null;
}