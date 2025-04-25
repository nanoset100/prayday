import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_prayer.dart';

/// 사용자 기도문 저장 서비스
class PrayerSaveService {
  static const String _kUserPrayersKey = 'user_prayers';

  /// 모든 사용자 기도문 목록 가져오기
  static Future<List<UserPrayer>> getAllUserPrayers() async {
    final prefs = await SharedPreferences.getInstance();
    final prayersJsonList = prefs.getStringList(_kUserPrayersKey) ?? [];

    return prayersJsonList.map((prayerJson) {
      return UserPrayer.fromJsonString(prayerJson);
    }).toList();
  }

  /// 새 사용자 기도문 저장
  static Future<bool> saveUserPrayer(UserPrayer prayer) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prayersJsonList = prefs.getStringList(_kUserPrayersKey) ?? [];

      prayersJsonList.add(prayer.toJsonString());
      return await prefs.setStringList(_kUserPrayersKey, prayersJsonList);
    } catch (e) {
      print('기도문 저장 오류: $e');
      return false;
    }
  }

  /// 특정 날짜/시간의 기도문 가져오기
  static Future<UserPrayer?> getUserPrayerByDateTime(
    String date,
    String time,
  ) async {
    final prayers = await getAllUserPrayers();
    try {
      return prayers.firstWhere(
        (prayer) => prayer.date == date && prayer.time == time,
      );
    } catch (e) {
      return null;
    }
  }

  /// 사용자 기도문 삭제
  static Future<bool> deleteUserPrayer(String date, String time) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prayersJsonList = prefs.getStringList(_kUserPrayersKey) ?? [];

      // 기존 기도문 목록 불러오기
      final prayers =
          prayersJsonList
              .map((json) => UserPrayer.fromJsonString(json))
              .toList();

      // 삭제할 기도문을 제외한 목록 생성
      final filteredPrayers =
          prayers.where((p) => !(p.date == date && p.time == time)).toList();

      // 필터링된 목록이 원본 길이와 같다면 삭제할 항목이 없었음
      if (filteredPrayers.length == prayers.length) {
        return false;
      }

      // 새 목록을 JSON으로 변환하여 저장
      final filteredJsonList =
          filteredPrayers.map((prayer) => prayer.toJsonString()).toList();

      return await prefs.setStringList(_kUserPrayersKey, filteredJsonList);
    } catch (e) {
      print('기도문 삭제 오류: $e');
      return false;
    }
  }

  /// 현재 날짜 얻기 (YYYY-MM-DD 형식)
  static String getCurrentDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// 현재 시간 얻기 (HH:MM 형식)
  static String getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}
