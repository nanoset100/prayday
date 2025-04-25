import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

/// 언어 선택 드롭다운 위젯
class LanguageSelector extends StatelessWidget {
  // 버튼 스타일 (옵션)
  final bool isIcon;

  const LanguageSelector({super.key, this.isIcon = true});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    if (isIcon) {
      // 아이콘 버튼 형태
      return PopupMenuButton<String>(
        icon: const Icon(Icons.language),
        tooltip: '언어 선택',
        onSelected: (String langCode) {
          languageProvider.changeLanguage(langCode);
        },
        itemBuilder: (BuildContext context) {
          return LanguageProvider.supportedLanguages.map((language) {
            final String code = language['code'] ?? '';
            final String name = language['name'] ?? '';
            final bool isSelected = code == languageProvider.currentLanguage;

            return PopupMenuItem<String>(
              value: code,
              child: Row(
                children: [
                  if (isSelected)
                    const Icon(Icons.check, size: 16, color: Colors.blue)
                  else
                    const SizedBox(width: 16),
                  const SizedBox(width: 8),
                  Text(name),
                ],
              ),
            );
          }).toList();
        },
      );
    } else {
      // 드롭다운 버튼 형태
      return DropdownButton<String>(
        value: languageProvider.currentLanguage,
        icon: const Icon(Icons.arrow_drop_down),
        elevation: 16,
        underline: Container(height: 2, color: Theme.of(context).primaryColor),
        onChanged: (String? newValue) {
          if (newValue != null) {
            languageProvider.changeLanguage(newValue);
          }
        },
        items:
            LanguageProvider.supportedLanguages.map<DropdownMenuItem<String>>((
              language,
            ) {
              return DropdownMenuItem<String>(
                value: language['code'],
                child: Text(language['name'] ?? ''),
              );
            }).toList(),
      );
    }
  }
}
