import '../models/prayer.dart';

class PrayerDataExample {
  // 예제 다국어 기도문 데이터
  static List<Prayer> getSamplePrayers() {
    return [
      Prayer(
        id: 1,
        date: "01-01",
        themeKo: "하나님과의 친밀감",
        verseKo: "내가 너와 함께 하리라 – 여호수아 1:9",
        prayerKo:
            "사랑과 은혜의 하나님 아버지, 새해를 주님의 약속으로 시작하게 하심에 감사드립니다. 우리의 모든 길 가운데 함께하시며 두려움보다 믿음으로 나아가게 하소서. 하나님의 임재를 날마다 느끼며 담대히 살아가게 하옵소서. 예수님의 이름으로 기도드립니다. 아멘.",
        themeEn: "Closeness with God",
        verseEn: "I will be with you – Joshua 1:9",
        prayerEn:
            "Gracious and loving Father, thank You for allowing us to begin this new year with Your promise. Be with us on every path and lead us to live by faith, not fear. May we feel Your presence daily and walk boldly. In Jesus' name we pray. Amen.",
        themeJa: "神様との親しい関係",
        verseJa: "わたしはあなたと共にいる – ヨシュア記 1:9",
        prayerJa:
            "恵み深く愛に満ちた父なる神様、この新しい年をあなたの約束で始められることを感謝します。すべての道で共に歩んでくださり、恐れではなく信仰によって生きられるよう導いてください。日々あなたの臨在を感じ、力強く歩めますように。イエス様の御名によって祈ります。アーメン。",
        themeZh: "与神的亲密关系",
        verseZh: "我必与你同在 – 约书亚记 1:9",
        prayerZh:
            "亲爱慈爱的天父，感谢祢让我们以祢的应许开始新的一年。愿祢在我们行走的每条道路上与我们同在，使我们靠信心而不是惧怕生活。愿我们每日感受到祢的同在，勇敢前行。奉耶稣的名祷告，阿们。",
        themeEs: "Intimidad con Dios",
        verseEs: "Yo estaré contigo – Josué 1:9",
        prayerEs:
            "Padre amoroso y lleno de gracia, gracias por permitirnos comenzar este nuevo año con tu promesa. Acompáñanos en cada camino y ayúdanos a vivir por fe, no por miedo. Que sintamos tu presencia cada día y vivamos con valentía. En el nombre de Jesús oramos. Amén.",
      ),
      Prayer(
        id: 2,
        date: "01-02",
        themeKo: "감사의 마음",
        verseKo: "모든 일에 감사하라 – 데살로니가전서 5:18",
        prayerKo:
            "은혜로우신 하나님, 오늘 하루도 주님께서 허락하신 모든 것에 감사드립니다. 좋은 일뿐만 아니라 어려운 상황에서도 감사할 수 있는 믿음을 주소서. 우리의 마음을 감사로 채워주시고, 그 감사가 우리 삶을 통해 흘러나가게 하소서. 예수님의 이름으로 기도합니다. 아멘.",
        themeEn: "Attitude of Gratitude",
        verseEn: "Give thanks in all circumstances – 1 Thessalonians 5:18",
        prayerEn:
            "Gracious God, we thank You for all that You have given us today. Grant us faith to be thankful not only in good times but also in difficult situations. Fill our hearts with gratitude and let that thankfulness flow through our lives. In Jesus' name we pray. Amen.",
        themeJa: "感謝の心",
        verseJa: "すべての事について感謝しなさい – テサロニケ第一 5:18",
        prayerJa:
            "恵み深い神様、今日も与えてくださったすべてのことに感謝します。良いときだけでなく、困難な状況でも感謝できる信仰を与えてください。私たちの心を感謝で満たし、その感謝が私たちの生活を通して流れるようにしてください。イエス様の御名によって祈ります。アーメン。",
        themeZh: "感恩的心",
        verseZh: "凡事谢恩 – 帖撒罗尼迦前书 5:18",
        prayerZh:
            "恩慈的神，我们感谢祢今天所赐给我们的一切。请赐给我们信心，不仅在好时光中，也在困难情况下感恩。用感恩填满我们的心，让这感恩流贯我们的生活。奉耶稣的名祷告。阿们。",
        themeEs: "Actitud de gratitud",
        verseEs: "Dad gracias en todo – 1 Tesalonicenses 5:18",
        prayerEs:
            "Dios misericordioso, te agradecemos por todo lo que nos has dado hoy. Concédenos la fe para estar agradecidos no solo en los buenos momentos sino también en las situaciones difíciles. Llena nuestros corazones de gratitud y permite que esa gratitud fluya a través de nuestras vidas. En el nombre de Jesús oramos. Amén.",
      ),
    ];
  }

  // JSON 예제 문자열
  static String getSamplePrayersJson() {
    return '''
[
  {
    "id": 1,
    "date": "01-01",
    "theme_ko": "하나님과의 친밀감",
    "verse_ko": "내가 너와 함께 하리라 – 여호수아 1:9",
    "prayer_ko": "사랑과 은혜의 하나님 아버지, 새해를 주님의 약속으로 시작하게 하심에 감사드립니다. 우리의 모든 길 가운데 함께하시며 두려움보다 믿음으로 나아가게 하소서. 하나님의 임재를 날마다 느끼며 담대히 살아가게 하옵소서. 예수님의 이름으로 기도드립니다. 아멘.",
    "theme_en": "Closeness with God",
    "verse_en": "I will be with you – Joshua 1:9",
    "prayer_en": "Gracious and loving Father, thank You for allowing us to begin this new year with Your promise. Be with us on every path and lead us to live by faith, not fear. May we feel Your presence daily and walk boldly. In Jesus' name we pray. Amen.",
    "theme_ja": "神様との親しい関係",
    "verse_ja": "わたしはあなたと共にいる – ヨシュア記 1:9",
    "prayer_ja": "恵み深く愛に満ちた父なる神様、この新しい年をあなたの約束で始められることを感謝します。すべての道で共に歩んでくださり、恐れではなく信仰によって生きられるよう導いてください。日々あなたの臨在を感じ、力強く歩めますように。イエス様の御名によって祈ります。アーメン。",
    "theme_zh": "与神的亲密关系",
    "verse_zh": "我必与你同在 – 约书亚记 1:9", 
    "prayer_zh": "亲爱慈爱的天父，感谢祢让我们以祢的应许开始新的一年。愿祢在我们行走的每条道路上与我们同在，使我们靠信心而不是惧怕生活。愿我们每日感受到祢的同在，勇敢前行。奉耶稣的名祷告，阿们。",
    "theme_es": "Intimidad con Dios",
    "verse_es": "Yo estaré contigo – Josué 1:9",
    "prayer_es": "Padre amoroso y lleno de gracia, gracias por permitirnos comenzar este nuevo año con tu promesa. Acompáñanos en cada camino y ayúdanos a vivir por fe, no por miedo. Que sintamos tu presencia cada día y vivamos con valentía. En el nombre de Jesús oramos. Amén."
  },
  {
    "id": 2,
    "date": "01-02",
    "theme_ko": "감사의 마음",
    "verse_ko": "모든 일에 감사하라 – 데살로니가전서 5:18",
    "prayer_ko": "은혜로우신 하나님, 오늘 하루도 주님께서 허락하신 모든 것에 감사드립니다. 좋은 일뿐만 아니라 어려운 상황에서도 감사할 수 있는 믿음을 주소서. 우리의 마음을 감사로 채워주시고, 그 감사가 우리 삶을 통해 흘러나가게 하소서. 예수님의 이름으로 기도합니다. 아멘.",
    "theme_en": "Attitude of Gratitude",
    "verse_en": "Give thanks in all circumstances – 1 Thessalonians 5:18",
    "prayer_en": "Gracious God, we thank You for all that You have given us today. Grant us faith to be thankful not only in good times but also in difficult situations. Fill our hearts with gratitude and let that thankfulness flow through our lives. In Jesus' name we pray. Amen.",
    "theme_ja": "感謝の心",
    "verse_ja": "すべての事について感謝しなさい – テサロニケ第一 5:18",
    "prayer_ja": "恵み深い神様、今日も与えてくださったすべてのことに感謝します。良いときだけでなく、困難な状況でも感謝できる信仰を与えてください。私たちの心を感謝で満たし、その感謝が私たちの生活を通して流れるようにしてください。イエス様の御名によって祈ります。アーメン。",
    "theme_zh": "感恩的心",
    "verse_zh": "凡事谢恩 – 帖撒罗尼迦前书 5:18",
    "prayer_zh": "恩慈的神，我们感谢祢今天所赐给我们的一切。请赐给我们信心，不仅在好时光中，也在困难情况下感恩。用感恩填满我们的心，让这感恩流贯我们的生活。奉耶稣的名祷告。阿们。",
    "theme_es": "Actitud de gratitud",
    "verse_es": "Dad gracias en todo – 1 Tesalonicenses 5:18",
    "prayer_es": "Dios misericordioso, te agradecemos por todo lo que nos has dado hoy. Concédenos la fe para estar agradecidos no solo en los buenos momentos sino también en las situaciones difíciles. Llena nuestros corazones de gratitud y permite que esa gratitud fluya a través de nuestras vidas. En el nombre de Jesús oramos. Amén."
  }
]
''';
  }
}
