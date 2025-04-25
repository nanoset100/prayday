import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer.dart';

class PrayerStorageService {
  static const String _kPrayersKey = 'daily_prayers';

  // 모든 기도문 목록 가져오기
  Future<List<Prayer>> getAllPrayers() async {
    final prefs = await SharedPreferences.getInstance();
    final prayersJsonList = prefs.getStringList(_kPrayersKey) ?? [];

    return prayersJsonList.map((prayerJson) {
      return Prayer.fromJsonString(prayerJson);
    }).toList();
  }

  // 특정 ID의 기도문 가져오기
  Future<Prayer?> getPrayerById(int id) async {
    final prayers = await getAllPrayers();
    try {
      return prayers.firstWhere((prayer) => prayer.id == id);
    } catch (e) {
      return null; // ID에 해당하는 기도문이 없는 경우
    }
  }

  // 특정 날짜의 기도문 가져오기
  Future<Prayer?> getPrayerByDate(String date) async {
    final prayers = await getAllPrayers();
    try {
      return prayers.firstWhere((prayer) => prayer.date == date);
    } catch (e) {
      return null; // 날짜에 해당하는 기도문이 없는 경우
    }
  }

  // 새 기도문 추가
  Future<bool> addPrayer(Prayer prayer) async {
    final prayers = await getAllPrayers();

    // 같은 ID가 있는지 확인
    final exists = prayers.any((p) => p.id == prayer.id);
    if (exists) {
      return false; // 같은 ID의 기도문이 이미 존재
    }

    prayers.add(prayer);
    return _savePrayers(prayers);
  }

  // 기도문 업데이트
  Future<bool> updatePrayer(Prayer updatedPrayer) async {
    final prayers = await getAllPrayers();
    final index = prayers.indexWhere((p) => p.id == updatedPrayer.id);

    if (index == -1) {
      return false; // 업데이트할 기도문이 없음
    }

    prayers[index] = updatedPrayer;
    return _savePrayers(prayers);
  }

  // 기도문 삭제
  Future<bool> deletePrayer(int id) async {
    final prayers = await getAllPrayers();
    final initialLength = prayers.length;

    prayers.removeWhere((prayer) => prayer.id == id);

    if (prayers.length == initialLength) {
      return false; // 삭제할 기도문이 없었음
    }

    return _savePrayers(prayers);
  }

  // 모든 기도문 저장 (내부용)
  Future<bool> _savePrayers(List<Prayer> prayers) async {
    final prefs = await SharedPreferences.getInstance();
    final prayersJsonList =
        prayers.map((prayer) => prayer.toJsonString()).toList();

    return prefs.setStringList(_kPrayersKey, prayersJsonList);
  }

  // 기도문 일괄 가져오기 (샘플 데이터나 서버에서 가져온 데이터 저장 시 사용)
  Future<bool> importPrayers(List<Prayer> prayers) async {
    return _savePrayers(prayers);
  }

  // JSON 문자열로부터 기도문 목록 일괄 가져오기
  Future<bool> importPrayersFromJson(String jsonString) async {
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final prayers = jsonList.map((json) => Prayer.fromJson(json)).toList();
      return _savePrayers(prayers);
    } catch (e) {
      print('기도문 JSON 가져오기 오류: $e');
      return false;
    }
  }

  // 모든 기도문을 JSON 문자열로 내보내기
  Future<String> exportPrayersToJson() async {
    final prayers = await getAllPrayers();
    final jsonList = prayers.map((prayer) => prayer.toJson()).toList();
    return jsonEncode(jsonList);
  }

  // 새 기도문 ID 생성 (현재 최대 ID + 1)
  Future<int> generateNewId() async {
    final prayers = await getAllPrayers();
    if (prayers.isEmpty) {
      return 1;
    }

    int maxId = prayers.fold(
      0,
      (max, prayer) => prayer.id > max ? prayer.id : max,
    );
    return maxId + 1;
  }
}
