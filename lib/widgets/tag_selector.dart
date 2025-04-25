import 'package:flutter/material.dart';

/// 기도문 태그 상수
class PrayerTags {
  static const String THANKFUL = '감사';
  static const String REPENT = '회개';
  static const String REQUEST = '간구';
  static const String PEACE = '평안';
  static const String MISSION = '사명';
  static const String COMFORT = '위로';
  static const String FAITH = '믿음';
  static const String JOY = '기쁨';
  static const String OTHER = '기타';

  /// 모든 태그 목록
  static List<String> get all => [
    THANKFUL,
    REPENT,
    REQUEST,
    PEACE,
    MISSION,
    COMFORT,
    FAITH,
    JOY,
    OTHER,
  ];

  /// 태그별 아이콘 매핑
  static IconData getIconForTag(String tag) {
    switch (tag) {
      case THANKFUL:
        return Icons.favorite;
      case REPENT:
        return Icons.history;
      case REQUEST:
        return Icons.request_page;
      case PEACE:
        return Icons.spa;
      case MISSION:
        return Icons.directions_run;
      case COMFORT:
        return Icons.healing;
      case FAITH:
        return Icons.church;
      case JOY:
        return Icons.celebration;
      case OTHER:
      default:
        return Icons.label;
    }
  }

  /// 태그별 색상 매핑
  static Color getColorForTag(String tag) {
    switch (tag) {
      case THANKFUL:
        return Colors.pink;
      case REPENT:
        return Colors.deepPurple;
      case REQUEST:
        return Colors.blue;
      case PEACE:
        return Colors.teal;
      case MISSION:
        return Colors.orange;
      case COMFORT:
        return Colors.green;
      case FAITH:
        return Colors.indigo;
      case JOY:
        return Colors.amber;
      case OTHER:
      default:
        return Colors.grey;
    }
  }
}

/// 태그 선택 드롭다운 위젯
class TagSelector extends StatelessWidget {
  final String value;
  final Function(String?) onChanged;
  final String? labelText;
  final bool showIcon;

  const TagSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.labelText,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          items:
              PrayerTags.all.map((String tag) {
                return DropdownMenuItem<String>(
                  value: tag,
                  child: Row(
                    children: [
                      if (showIcon) ...[
                        Icon(
                          PrayerTags.getIconForTag(tag),
                          color: PrayerTags.getColorForTag(tag),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(tag),
                    ],
                  ),
                );
              }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// 태그 칩 표시 위젯
class TagChip extends StatelessWidget {
  final String tag;
  final VoidCallback? onTap;
  final bool isSelected;

  const TagChip({
    super.key,
    required this.tag,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        avatar: Icon(
          PrayerTags.getIconForTag(tag),
          color: isSelected ? Colors.white : PrayerTags.getColorForTag(tag),
          size: 16,
        ),
        label: Text(
          tag,
          style: TextStyle(
            color: isSelected ? Colors.white : null,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        backgroundColor:
            isSelected
                ? PrayerTags.getColorForTag(tag)
                : PrayerTags.getColorForTag(tag).withOpacity(0.1),
      ),
    );
  }
}
