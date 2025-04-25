import 'package:flutter/material.dart';
import '../models/user_prayer.dart';
import '../services/ai_prayer_service.dart';
import '../services/prayer_save_service.dart';
import '../widgets/tag_selector.dart';
import 'my_prayers_screen.dart';

class PrayerInputScreen extends StatefulWidget {
  const PrayerInputScreen({super.key});

  @override
  _PrayerInputScreenState createState() => _PrayerInputScreenState();
}

class _PrayerInputScreenState extends State<PrayerInputScreen> {
  final TextEditingController _prayerController = TextEditingController();
  final int _maxCharCount = 300;
  String? _aiGeneratedPrayer;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String _selectedTag = PrayerTags.OTHER;

  @override
  void dispose() {
    _prayerController.dispose();
    super.dispose();
  }

  Future<void> _generateAiPrayer() async {
    if (_prayerController.text.isEmpty) {
      setState(() {
        _errorMessage = '기도문을 입력해주세요.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final generatedPrayer = await AiPrayerService.generatePrayer(
        _prayerController.text,
      );
      setState(() {
        _aiGeneratedPrayer = generatedPrayer;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '기도문 생성 중 오류가 발생했습니다: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUserPrayer() async {
    if (_prayerController.text.isEmpty) {
      setState(() {
        _errorMessage = '기도문을 입력해주세요.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final userPrayer = UserPrayer(
        date: PrayerSaveService.getCurrentDate(),
        time: PrayerSaveService.getCurrentTime(),
        userInput: _prayerController.text,
        aiPrayer: _aiGeneratedPrayer,
        tag: _selectedTag,
      );

      final saved = await PrayerSaveService.saveUserPrayer(userPrayer);

      if (saved) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('기도문이 저장되었습니다.')));

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyPrayersScreen()),
          );
        }
      } else {
        setState(() {
          _errorMessage = '기도문 저장에 실패했습니다.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '기도문 저장 중 오류가 발생했습니다: $e';
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('나의 기도 작성'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyPrayersScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _prayerController,
                  maxLength: _maxCharCount,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: '오늘의 기도문을 작성해주세요.',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) {
                    setState(() {
                      _errorMessage = null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TagSelector(
                  value: _selectedTag,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedTag = value;
                      });
                    }
                  },
                  labelText: '기도문 주제 태그',
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _generateAiPrayer,
                  child:
                      _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('AI 도움받기'),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                if (_aiGeneratedPrayer != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'AI가 생성한 기도문:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _aiGeneratedPrayer!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveUserPrayer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('기도문 저장하기'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
