import 'dart:convert';

class Prayer {
  final int id;
  final String date;

  // 한국어
  final String themeKo;
  final String verseKo;
  final String prayerKo;

  // 영어
  final String themeEn;
  final String verseEn;
  final String prayerEn;

  // 일본어
  final String themeJa;
  final String verseJa;
  final String prayerJa;

  // 중국어
  final String themeZh;
  final String verseZh;
  final String prayerZh;

  // 스페인어
  final String themeEs;
  final String verseEs;
  final String prayerEs;

  Prayer({
    required this.id,
    required this.date,
    required this.themeKo,
    required this.verseKo,
    required this.prayerKo,
    required this.themeEn,
    required this.verseEn,
    required this.prayerEn,
    required this.themeJa,
    required this.verseJa,
    required this.prayerJa,
    required this.themeZh,
    required this.verseZh,
    required this.prayerZh,
    required this.themeEs,
    required this.verseEs,
    required this.prayerEs,
  });

  // JSON에서 Prayer 객체로 변환
  factory Prayer.fromJson(Map<String, dynamic> json) {
    return Prayer(
      id: json['id'],
      date: json['date'],
      themeKo: json['theme_ko'],
      verseKo: json['verse_ko'],
      prayerKo: json['prayer_ko'],
      themeEn: json['theme_en'],
      verseEn: json['verse_en'],
      prayerEn: json['prayer_en'],
      themeJa: json['theme_ja'],
      verseJa: json['verse_ja'],
      prayerJa: json['prayer_ja'],
      themeZh: json['theme_zh'],
      verseZh: json['verse_zh'],
      prayerZh: json['prayer_zh'],
      themeEs: json['theme_es'],
      verseEs: json['verse_es'],
      prayerEs: json['prayer_es'],
    );
  }

  // Prayer 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'theme_ko': themeKo,
      'verse_ko': verseKo,
      'prayer_ko': prayerKo,
      'theme_en': themeEn,
      'verse_en': verseEn,
      'prayer_en': prayerEn,
      'theme_ja': themeJa,
      'verse_ja': verseJa,
      'prayer_ja': prayerJa,
      'theme_zh': themeZh,
      'verse_zh': verseZh,
      'prayer_zh': prayerZh,
      'theme_es': themeEs,
      'verse_es': verseEs,
      'prayer_es': prayerEs,
    };
  }

  // Prayer 객체를 JSON 문자열로 변환
  String toJsonString() {
    return jsonEncode(toJson());
  }

  // JSON 문자열에서 Prayer 객체로 변환
  static Prayer fromJsonString(String jsonString) {
    return Prayer.fromJson(jsonDecode(jsonString));
  }

  // Prayer 객체 복사 및 업데이트
  Prayer copyWith({
    int? id,
    String? date,
    String? themeKo,
    String? verseKo,
    String? prayerKo,
    String? themeEn,
    String? verseEn,
    String? prayerEn,
    String? themeJa,
    String? verseJa,
    String? prayerJa,
    String? themeZh,
    String? verseZh,
    String? prayerZh,
    String? themeEs,
    String? verseEs,
    String? prayerEs,
  }) {
    return Prayer(
      id: id ?? this.id,
      date: date ?? this.date,
      themeKo: themeKo ?? this.themeKo,
      verseKo: verseKo ?? this.verseKo,
      prayerKo: prayerKo ?? this.prayerKo,
      themeEn: themeEn ?? this.themeEn,
      verseEn: verseEn ?? this.verseEn,
      prayerEn: prayerEn ?? this.prayerEn,
      themeJa: themeJa ?? this.themeJa,
      verseJa: verseJa ?? this.verseJa,
      prayerJa: prayerJa ?? this.prayerJa,
      themeZh: themeZh ?? this.themeZh,
      verseZh: verseZh ?? this.verseZh,
      prayerZh: prayerZh ?? this.prayerZh,
      themeEs: themeEs ?? this.themeEs,
      verseEs: verseEs ?? this.verseEs,
      prayerEs: prayerEs ?? this.prayerEs,
    );
  }
}
