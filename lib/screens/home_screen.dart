import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/openai_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _prayerController = TextEditingController();
  String? _selectedEmotion;
  bool _isGenerating = false;
  Future<SharedPreferences>? _prefsFuture;

  final List<String> _emotions = ['불안', '감사', '회개', '외로움'];

  @override
  void initState() {
    super.initState();
    _prefsFuture = SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    _prayerController.dispose();
    super.dispose();
  }

  Future<void> _savePrayer(SharedPreferences prefs) async {
    try {
      if (_prayerController.text.isEmpty) {
        _showMessage('기도 내용을 입력해주세요');
        return;
      }

      if (_selectedEmotion == null) {
        _showMessage('감정을 선택해주세요');
        return;
      }

      final prayerEntry = {
        'text': _prayerController.text,
        'emotion': _selectedEmotion,
        'date': DateTime.now().toString().split(' ')[0],
      };

      final String prayerJson = jsonEncode(prayerEntry);

      final List<String>? existingPrayers = prefs.getStringList(
        'saved_prayers',
      );

      if (existingPrayers != null) {
        existingPrayers.add(prayerJson);
        await prefs.setStringList('saved_prayers', existingPrayers);
      } else {
        await prefs.setStringList('saved_prayers', [prayerJson]);
      }

      _showMessage('기도문이 저장되었습니다');

      _prayerController.clear();
      setState(() {
        _selectedEmotion = null;
      });
    } catch (e) {
      _showMessage('저장 중 오류가 발생했습니다: $e');
    }
  }

  Future<void> _generateAIPrayer() async {
    if (_prayerController.text.isEmpty) {
      _showMessage('기도 내용을 입력해주세요');
      return;
    }

    if (_selectedEmotion == null) {
      _showMessage('감정을 선택해주세요');
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final generatedPrayer = await OpenAIService.generatePrayer(
        _prayerController.text,
        _selectedEmotion!,
      );

      if (!mounted) return;

      // Store the original input in case user wants to revert
      final originalInput = _prayerController.text;

      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing by tapping outside
        builder:
            (context) => AlertDialog(
              title: const Text('AI가 생성한 기도문'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '원래 입력:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(originalInput),
                    const SizedBox(height: 16),
                    const Text(
                      'AI 생성 기도문:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(generatedPrayer),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _prayerController.text =
                        originalInput; // Restore original input
                    Navigator.of(context).pop();
                  },
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    _prayerController.text = generatedPrayer;
                    Navigator.of(context).pop();
                    _showMessage('AI 기도문이 적용되었습니다');
                  },
                  child: const Text('사용하기'),
                ),
              ],
            ),
      );
    } catch (e, stacktrace) {
      if (!mounted) return;

      print('Prayer generation error: $e');
      print('Stacktrace: $stacktrace');

      _showMessage('기도문 생성 오류: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (ScaffoldMessenger.maybeOf(context) != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } else {
      print("ScaffoldMessenger not available: $message");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('일상 기도기록'), centerTitle: true),
      body: FutureBuilder<SharedPreferences>(
        future: _prefsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('오류 발생: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final prefs = snapshot.data!;
            return _buildPrayerForm(prefs);
          } else {
            return const Center(child: Text('알 수 없는 상태'));
          }
        },
      ),
    );
  }

  Widget _buildPrayerForm(SharedPreferences prefs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '오늘의 말씀',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '여기에 오늘의 말씀이 표시됩니다. 이는 임시 텍스트입니다.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          const Text(
            '기도문 예시',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '주님, 오늘 하루도 감사합니다. 제 마음의 불안과 걱정을 주님께 맡깁니다. 제가 가진 모든 것들이 주님의 은혜임을 깨닫게 하시고, 주님의 뜻대로 살아갈 수 있도록 인도해 주소서. 어려운 상황에서도 주님을 신뢰하며, 이웃을 사랑하고 섬길 수 있는 마음을 주소서.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _prayerController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: '당신의 기도를 여기에 적어주세요...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedEmotion,
            decoration: const InputDecoration(
              labelText: '감정 선택',
              border: OutlineInputBorder(),
            ),
            items:
                _emotions.map((String emotion) {
                  return DropdownMenuItem<String>(
                    value: emotion,
                    child: Text(emotion),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedEmotion = newValue;
              });
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isGenerating ? null : _generateAIPrayer,
            icon:
                _isGenerating
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.auto_awesome),
            label: Text(_isGenerating ? '생성 중...' : '🙏 AI 도움받기'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _savePrayer(prefs),
            icon: const Icon(Icons.save),
            label: const Text('💾 저장하기'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
