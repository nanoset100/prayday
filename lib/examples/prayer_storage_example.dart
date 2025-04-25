import 'package:flutter/material.dart';
import '../models/prayer.dart';
import '../services/prayer_repository.dart';
import '../services/prayer_storage_service.dart';
import '../services/prayer_data_example.dart';

class PrayerStorageExample extends StatefulWidget {
  const PrayerStorageExample({super.key});

  @override
  State<PrayerStorageExample> createState() => _PrayerStorageExampleState();
}

class _PrayerStorageExampleState extends State<PrayerStorageExample> {
  final PrayerRepository _repository = LocalPrayerRepository(
    PrayerStorageService(),
  );
  List<Prayer> _prayers = [];
  bool _isLoading = true;
  String _language = 'ko'; // 기본 언어: 한국어

  @override
  void initState() {
    super.initState();
    _loadPrayers();
  }

  // 기도문 목록 불러오기
  Future<void> _loadPrayers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prayers = await _repository.getAllPrayers();
      setState(() {
        _prayers = prayers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showMessage('기도문 불러오기 오류: $e');
    }
  }

  // 예제 데이터 불러오기
  Future<void> _loadSampleData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final samplePrayers = PrayerDataExample.getSamplePrayers();
      await _repository.importPrayers(samplePrayers);
      await _loadPrayers(); // 기도문 목록 다시 불러오기
      _showMessage('예제 데이터가 저장되었습니다');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showMessage('예제 데이터 로드 오류: $e');
    }
  }

  // 메시지 표시
  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // 언어 선택 변경
  void _changeLanguage(String language) {
    setState(() {
      _language = language;
    });
  }

  // 특정 언어에 맞는 테마 텍스트 가져오기
  String _getThemeByLanguage(Prayer prayer) {
    switch (_language) {
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
        return prayer.themeKo;
    }
  }

  // 특정 언어에 맞는
  String _getVerseByLanguage(Prayer prayer) {
    switch (_language) {
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

  // 특정 언어에 맞는 기도문 텍스트 가져오기
  String _getPrayerByLanguage(Prayer prayer) {
    switch (_language) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('다국어 기도문 저장소 예제'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _changeLanguage,
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'ko', child: Text('한국어')),
                  const PopupMenuItem(value: 'en', child: Text('English')),
                  const PopupMenuItem(value: 'ja', child: Text('日本語')),
                  const PopupMenuItem(value: 'zh', child: Text('中文')),
                  const PopupMenuItem(value: 'es', child: Text('Español')),
                ],
            icon: const Icon(Icons.language),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _prayers.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('저장된 기도문이 없습니다'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadSampleData,
                      child: const Text('예제 데이터 불러오기'),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: _prayers.length,
                itemBuilder: (context, index) {
                  final prayer = _prayers[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _getThemeByLanguage(prayer),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                prayer.date,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getVerseByLanguage(prayer),
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.blue[800],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(_getPrayerByLanguage(prayer)),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadSampleData,
        tooltip: '예제 데이터 불러오기',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
