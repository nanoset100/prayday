import 'package:flutter/material.dart';
import '../services/openai_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'my_prayers_screen.dart';

class PrayerExampleScreen extends StatefulWidget {
  const PrayerExampleScreen({super.key});

  @override
  State<PrayerExampleScreen> createState() => _PrayerExampleScreenState();
}

class _PrayerExampleScreenState extends State<PrayerExampleScreen> {
  final TextEditingController _prayerController = TextEditingController();
  String selectedFeeling = '불안';
  bool _isLoading = false;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  final List<String> feelings = [
    '불안',
    '감사',
    '슬픔',
    '기쁨',
    '용서',
    '소망',
    '외로움',
    '지침',
    '두려움',
    '갈망',
  ];

  Future<void> _getAIPrayer() async {
    if (_prayerController.text.isEmpty) {
      _showError('기도문을 먼저 입력해주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final aiPrayer = await OpenAIService.generatePrayer(
        _prayerController.text,
        selectedFeeling,
      );

      setState(() {
        _prayerController.text = '${_prayerController.text}\n\n$aiPrayer';
      });
    } catch (e) {
      _showError('오류가 발생했습니다: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _savePrayer() async {
    if (_prayerController.text.isEmpty) {
      _showError('기도문을 입력해주세요.');
      return;
    }

    try {
      final now = DateTime.now();
      final dateKey = DateFormat('yyyy-MM-dd').format(now);
      final storageKey = 'prayers_$dateKey';

      // 기존 기도문 리스트 가져오기
      final existingPrayers = _prefs.getStringList(storageKey) ?? [];

      // 새로운 기도문 추가
      final newPrayer = '[$selectedFeeling] ${_prayerController.text}';
      existingPrayers.add(newPrayer);

      // 저장
      await _prefs.setStringList(storageKey, existingPrayers);

      _showSuccess('기도문이 저장되었습니다');
    } catch (e) {
      _showError('저장 중 오류가 발생했습니다: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('일상 기도기록'),
        centerTitle: true,
        backgroundColor: const Color(0xFF6DF6EA),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 오늘의 말씀 (성경구절 포함)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF6DF6EA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '📖 오늘의 말씀: "항상 기도하라" (데살로니가전서 5:17)',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),

            // 예시 기도문
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '예시 기도문 🙏\n사랑의 하나님,\n우리가 어떤 상황 속에서도 항상 기도하라 명하신 주님의 말씀을 마음에 새깁니다.\n기도로 시작하고 기도로 마치는 하루가 되게 하시고,\n삶의 모든 영역에서 하나님을 의지하는 믿음을 갖게 하옵소서.\n예수님의 이름으로 기도드립니다. 아멘.',
                style: TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),

            // 감정 선택 드롭다운 (감정만 표시)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedFeeling,
                underline: const SizedBox(),
                items:
                    feelings.map((String feeling) {
                      return DropdownMenuItem<String>(
                        value: feeling,
                        child: Text(feeling), // 감정만 출력
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedFeeling = newValue!;
                  });
                },
              ),
            ),
            const SizedBox(height: 12),

            // 안내문 (1줄만!)
            const Text(
              '내 감정을 선택한 후 상황에 맞게 적어보세요',
              style: TextStyle(fontSize: 13, color: Colors.black54),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 8),

            // 내 기도문 입력창
            TextField(
              controller: _prayerController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: '나의 기도문을 여기에 작성해보세요',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // AI 도움받기 버튼
            ElevatedButton(
              onPressed: _isLoading ? null : _getAIPrayer,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6DF6EA),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  _isLoading
                      ? const CircularProgressIndicator()
                      : const Text("✨🙏 AI 도움받기"),
            ),
            const SizedBox(height: 16),

            // 저장 + 내 기도문 보기 버튼
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _savePrayer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("💾 저장하기"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyPrayersScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("📖 내 기도문 보기"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
