import '../models/prayer.dart';

/// Prayer 객체에서 현재 언어에 맞는 필드를 반환하는 유틸리티 함수
class PrayerUtils {
  /// 지정된 언어에 맞는 테마 필드 반환
  static String getLocalizedTheme(Prayer prayer, String langCode) {
    switch (langCode) {
      case 'ko':
        return prayer.themeKo;
      case 'en':
        return prayer.themeEn;
      case 'ja':
        return prayer.themeJa;
      case 'zh':
        return prayer.themeZh;
      case 'es':
        return prayer.themeEs;
      default:
        return prayer.themeKo; // 기본값은 한국어
    }
  }

  /// 지정된 언어에 맞는 성경 구절 필드 반환
  static String getLocalizedVerse(Prayer prayer, String langCode) {
    switch (langCode) {
      case 'ko':
        return prayer.verseKo;
      case 'en':
        return prayer.verseEn;
      case 'ja':
        return prayer.verseJa;
      case 'zh':
        return prayer.verseZh;
      case 'es':
        return prayer.verseEs;
      default:
        return prayer.verseKo;
    }
  }

  /// 지정된 언어에 맞는 기도문 필드 반환
  static String getLocalizedPrayer(Prayer prayer, String langCode) {
    switch (langCode) {
      case 'ko':
        return prayer.prayerKo;
      case 'en':
        return prayer.prayerEn;
      case 'ja':
        return prayer.prayerJa;
      case 'zh':
        return prayer.prayerZh;
      case 'es':
        return prayer.prayerEs;
      default:
        return prayer.prayerKo;
    }
  }

  /// 필드 유형과 언어 코드에 따라 해당하는 값 반환
  static String getLocalizedField(
    Prayer prayer,
    String field,
    String langCode,
  ) {
    final map = {
      'theme': {
        'ko': prayer.themeKo,
        'en': prayer.themeEn,
        'ja': prayer.themeJa,
        'zh': prayer.themeZh,
        'es': prayer.themeEs,
      },
      'verse': {
        'ko': prayer.verseKo,
        'en': prayer.verseEn,
        'ja': prayer.verseJa,
        'zh': prayer.verseZh,
        'es': prayer.verseEs,
      },
      'prayer': {
        'ko': prayer.prayerKo,
        'en': prayer.prayerEn,
        'ja': prayer.prayerJa,
        'zh': prayer.prayerZh,
        'es': prayer.prayerEs,
      },
    };

    return map[field]?[langCode] ?? '';
  }
}
