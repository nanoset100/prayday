import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _prefsKey = 'selectedLanguage';
  static const String defaultLanguage = 'ko'; // 기본 언어: 한국어

  // 지원되는 언어 목록
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'ko', 'name': '한국어'},
    {'code': 'en', 'name': 'English'},
    {'code': 'ja', 'name': '日本語'},
    {'code': 'zh', 'name': '中文'},
    {'code': 'es', 'name': 'Español'},
  ];

  String _currentLanguage = defaultLanguage;

  // 현재 선택된 언어 getter
  String get currentLanguage => _currentLanguage;

  // 현재 선택된 언어 이름 getter
  String get currentLanguageName {
    final language = supportedLanguages.firstWhere(
      (lang) => lang['code'] == _currentLanguage,
      orElse: () => supportedLanguages.first,
    );
    return language['name'] ?? '한국어';
  }

  // 초기화 메서드
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString(_prefsKey) ?? defaultLanguage;
    notifyListeners();
  }

  // 언어 변경 메서드
  Future<void> changeLanguage(String languageCode) async {
    if (_currentLanguage == languageCode) return;

    // 지원되는 언어인지 확인
    final isSupported = supportedLanguages.any(
      (lang) => lang['code'] == languageCode,
    );
    if (!isSupported) return;

    // 언어 업데이트 및 저장
    _currentLanguage = languageCode;

    // SharedPreferences에 저장
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, languageCode);

    // 리스너에게 변경 알림
    notifyListeners();
  }
}
