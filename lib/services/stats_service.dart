import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class StatsService {
  static const String _lastVisitDateKey = 'last_visit_date';
  static const String _streakCountKey = 'streak_count';
  static const String _todayVisitsKey = 'today_visits';
  static const String _totalVisitsKey = 'total_visits';
  static const String _checkTimeKey = 'check_time';

  // 앱 실행 시 방문 기록 및 통계 업데이트
  static Future<void> recordVisit() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);

    // 마지막 방문 날짜
    final lastVisitDate = prefs.getString(_lastVisitDateKey) ?? '';

    // 총 방문 횟수 증가
    final totalVisits = prefs.getInt(_totalVisitsKey) ?? 0;
    await prefs.setInt(_totalVisitsKey, totalVisits + 1);

    // 오늘 방문 횟수 관리
    if (lastVisitDate == today) {
      // 오늘 이미 방문한 경우
      final todayVisits = prefs.getInt(_todayVisitsKey) ?? 0;
      await prefs.setInt(_todayVisitsKey, todayVisits + 1);
    } else {
      // 오늘 첫 방문인 경우
      await prefs.setInt(_todayVisitsKey, 1);

      // 연속 방문 처리
      if (lastVisitDate.isNotEmpty) {
        final lastVisit = DateTime.parse(lastVisitDate);
        final difference = now.difference(lastVisit).inDays;

        if (difference == 1) {
          // 어제 방문했으면 스트릭 증가
          final streak = prefs.getInt(_streakCountKey) ?? 0;
          await prefs.setInt(_streakCountKey, streak + 1);
        } else if (difference > 1) {
          // 하루 이상 놓쳤으면 스트릭 초기화
          await prefs.setInt(_streakCountKey, 1);
        }
      } else {
        // 첫 방문인 경우
        await prefs.setInt(_streakCountKey, 1);
      }
    }

    // 마지막 방문 날짜 업데이트
    await prefs.setString(_lastVisitDateKey, today);
  }

  // 통계 데이터 가져오기
  static Future<Map<String, dynamic>> getStats() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'streak': prefs.getInt(_streakCountKey) ?? 0,
      'todayVisits': prefs.getInt(_todayVisitsKey) ?? 0,
      'totalVisits': prefs.getInt(_totalVisitsKey) ?? 0,
      'checkTime': prefs.getString(_checkTimeKey) ?? '9:00 AM',
    };
  }

  // 확인 시간 설정
  static Future<void> setCheckTime(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_checkTimeKey, time);
  }

  // 확인 시간 가져오기
  static Future<String> getCheckTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_checkTimeKey) ?? '9:00 AM';
  }
}
