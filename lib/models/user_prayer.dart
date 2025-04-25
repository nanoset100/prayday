import 'dart:convert';

/// 사용자가 작성하고 AI가 도움을 준 기도문 모델
class UserPrayer {
  final String date; // YYYY-MM-DD 형식
  final String time; // HH:MM 형식
  final String userInput; // 사용자 입력 기도문
  final String? aiPrayer; // AI 생성 기도문 (null일 수 있음)
  final String tag; // 기도문 주제 태그

  UserPrayer({
    required this.date,
    required this.time,
    required this.userInput,
    this.aiPrayer,
    this.tag = '기타', // 기본값은 '기타'
  });

  // JSON에서 UserPrayer 객체로 변환
  factory UserPrayer.fromJson(Map<String, dynamic> json) {
    return UserPrayer(
      date: json['date'],
      time: json['time'],
      userInput: json['user_input'],
      aiPrayer: json['ai_prayer'],
      tag: json['tag'] ?? '기타', // 기존 데이터 호환성 유지
    );
  }

  // UserPrayer 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'time': time,
      'user_input': userInput,
      'ai_prayer': aiPrayer,
      'tag': tag,
    };
  }

  // UserPrayer 객체를 JSON 문자열로 변환
  String toJsonString() {
    return jsonEncode(toJson());
  }

  // JSON 문자열에서 UserPrayer 객체로 변환
  static UserPrayer fromJsonString(String jsonString) {
    return UserPrayer.fromJson(jsonDecode(jsonString));
  }

  // 날짜와 시간을 합쳐서 표시 (예: 2023-04-24 14:30)
  String get dateTime => '$date $time';

  // 간단한 기도문 내용 미리보기 (최대 50자)
  String get previewText {
    final text = aiPrayer ?? userInput;
    if (text.length <= 50) {
      return text;
    }
    return '${text.substring(0, 47)}...';
  }
}
