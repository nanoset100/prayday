import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// AI 기도문 생성 서비스
class AiPrayerService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  /// 사용자 입력을 기반으로 AI 기도문 생성
  static Future<String> generatePrayer(String userInput) async {
    try {
      // API 키 불러오기
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API 키가 설정되지 않았습니다. .env 파일을 확인해주세요.');
      }

      // HTTP 요청 헤더
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      };

      // 생성 요청 메시지
      final messages = [
        {
          'role': 'system',
          'content':
              '당신은 진심 어린 기도문을 작성하는 도우미입니다. 사용자의 생각과 감정을 반영하여 하나님께 드리는 300자 이내의 공손하고 간결한 기도문을 만들어주세요.',
        },
        {
          'role': 'user',
          'content':
              '아래의 내용을 바탕으로 하나님께 드리는 대표 기도문을 공손하고 간결하게 300자 이내로 작성해주세요:\n\n$userInput',
        },
      ];

      // 요청 본문
      final body = jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': messages,
        'temperature': 0.7,
        'max_tokens': 300,
      });

      // HTTP 요청 보내기
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: headers,
        body: body,
      );

      // 응답 처리
      if (response.statusCode == 200) {
        // 한글 인코딩 문제 해결을 위해 bodyBytes를 사용
        final decoded = utf8.decode(response.bodyBytes);
        final jsonResponse = jsonDecode(decoded);
        final generatedText = jsonResponse['choices'][0]['message']['content'];
        return generatedText.trim();
      } else {
        // 오류 응답도 동일하게 처리
        final decoded = utf8.decode(response.bodyBytes);
        final errorBody = jsonDecode(decoded);
        throw Exception(
          'API 요청 실패 (${response.statusCode}): ${errorBody['error']['message']}',
        );
      }
    } catch (e) {
      throw Exception('기도문 생성 오류: $e');
    }
  }
}
