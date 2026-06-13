import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  static const _apiKey = 'AIzaSyA8BhmAvnNqFpO0mmlQ7Gcv3z0XtFmF88U';
  static const _url =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  static const _systemPrompt =
      'You are an expert Indian legal assistant inside the "Pocket Court" app. '
      'Your role is to help Indian citizens understand their legal rights in simple, clear language. '
      'Always refer to specific Indian laws: IPC, CrPC, Motor Vehicles Act, Consumer Protection Act, IT Act, Constitution of India, etc. '
      'Mention relevant sections and articles when applicable. '
      'Suggest practical next steps (file FIR, approach consumer forum, call helpline etc.). '
      'Include relevant helpline numbers when appropriate (100 police, 181 women, 1930 cyber, 1800-11-4000 consumer). '
      'Keep responses concise and easy to understand for a common citizen. '
      'Always add a disclaimer that this is general legal awareness, not professional legal advice. '
      'If asked about non-legal topics, politely redirect to legal matters. '
      'Respond in the same language the user writes in (Hindi or English).';

  static Future<String> getResponse(String userMessage) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_url?key=$_apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': '$_systemPrompt\n\nUser: $userMessage'}
                  ]
                }
              ],
              'generationConfig': {
                'temperature': 0.7,
                'maxOutputTokens': 800,
              }
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return json['candidates'][0]['content']['parts'][0]['text'] as String;
      } else {
        return _fallback(userMessage);
      }
    } catch (_) {
      return _fallback(userMessage);
    }
  }

  static String _fallback(String msg) {
    final m = msg.toLowerCase();
    if (m.contains('fir') || m.contains('police')) {
      return 'To file an FIR, visit your nearest police station. If refused, approach the SP or file online at your state police portal. Helpline: 100';
    }
    if (m.contains('consumer') || m.contains('refund')) {
      return 'Under Consumer Protection Act 2019, you can file a complaint at consumerhelpline.gov.in or call 1800-11-4000.';
    }
    if (m.contains('cyber') || m.contains('fraud') || m.contains('upi')) {
      return 'Report cyber crime at cybercrime.gov.in or call 1930 immediately. Preserve all evidence.';
    }
    if (m.contains('traffic') || m.contains('challan')) {
      return 'Pay e-challans at echallan.parivahan.gov.in. Contest wrong challans in court.';
    }
    return 'I\'m your AI Legal Assistant. Ask me about your rights, FIR procedures, consumer complaints, cyber crime, traffic violations, or any legal situation you\'re facing.';
  }
}