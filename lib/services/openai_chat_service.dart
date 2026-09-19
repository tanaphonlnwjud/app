import 'dart:convert';

import 'package:http/http.dart' as http;

class OpenAIChatService {
  OpenAIChatService({http.Client? client}) : _client = client ?? http.Client();

  static const _apiKey = String.fromEnvironment('OPENROUTER_API_KEY');
  static const _model = 'nvidia/nemotron-3-ultra-550b-a55b:free';
  static const _endpoint =
      'https://openrouter.ai/api/v1/chat/completions';

  final http.Client _client;

  Future<String> sendMessage(List<Map<String, String>> messages) async {
    if (_apiKey.isEmpty) {
      throw const OpenAIChatException(
        'ยังไม่ได้ตั้งค่า OpenRouter API key ให้รันแอปด้วย '
        '--dart-define=OPENROUTER_API_KEY=...',
      );
    }

    final response = await _client.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
        'HTTP-Referer': 'https://localhost',
        'X-Title': 'Nisit Hub',
      },
      body: jsonEncode({
        'model': _model,
        'messages': messages,
        'temperature': 0.7,
        'max_tokens': 0,
      }),
    );

    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = responseData['error'] as Map<String, dynamic>?;
      final errorCode = error?['code'] as String?;
      if (response.statusCode == 401) {
        throw const OpenAIChatException(
          'OpenRouter API key ไม่ถูกต้องหรือหมดอายุ',
        );
      }
      if (response.statusCode == 429 || errorCode == 'insufficient_quota') {
        throw const OpenAIChatException(
          'โควตาหรือ rate limit ของโมเดลหมดแล้ว จึงไม่สามารถใช้งาน AI ต่อได้',
        );
      }
      throw OpenAIChatException(
        error?['message'] as String? ?? 'ไม่สามารถเชื่อมต่อ OpenRouter ได้',
      );
    }

    final choices = responseData['choices'] as List<dynamic>?;
    final message = choices?.firstOrNull as Map<String, dynamic>?;
    final content = (message?['message'] as Map<String, dynamic>?)?['content'];
    if (content is! String || content.trim().isEmpty) {
      throw const OpenAIChatException('OpenRouter ไม่ได้ส่งข้อความตอบกลับ');
    }
    return content.trim();
  }
}

class OpenAIChatException implements Exception {
  const OpenAIChatException(this.message);

  final String message;
}