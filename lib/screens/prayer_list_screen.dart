import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/prayer_data_example.dart';
import '../providers/language_provider.dart';
import '../widgets/language_selector.dart';
import 'prayer_detail_screen.dart';
import '../main.dart'; // 글로벌 prayerRepository 접근을 위해 import
import '../models/user_prayer.dart';
import '../services/prayer_save_service.dart';
import '../widgets/tag_selector.dart';
import 'prayer_input_screen.dart'; // PrayerInputScreen 클래스는 오직 여기서만 import

class PrayerListScreen extends StatefulWidget {
  const PrayerListScreen({super.key});

  @override
  State<PrayerListScreen> createState() => _PrayerListScreenState();
}

class _PrayerListScreenState extends State<PrayerListScreen> {
  // 글로벌 저장소 인스턴스 사용
  // final PrayerRepository _repository = LocalPrayerRepository(PrayerStorageService());
  List<UserPrayer> _prayers = [];
  List<UserPrayer> _filteredPrayers = [];
  bool _isLoading = true;
  String? _selectedTagFilter;

  @override
  void initState() {
    super.initState();
    _loadPrayers();
  }

  // 기도문 목록 불러오기 및 날짜순 정렬
  Future<void> _loadPrayers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prayers = await PrayerSaveService.getAllUserPrayers();

      // 기도문이 없으면 예제 데이터 로드
      if (prayers.isEmpty) {
        await _loadSampleData();
        return;
      }

      // 날짜 기준 오름차순 정렬
      prayers.sort((a, b) => a.date.compareTo(b.date));

      setState(() {
        _prayers = prayers;
        _applyTagFilter(); // 태그 필터 적용
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showMessage('기도문 불러오기 오류: $e');
    }
  }

  // 태그 필터 적용
  void _applyTagFilter() {
    if (_selectedTagFilter == null) {
      // 필터가 없으면 모든 기도문 표시
      _filteredPrayers = List.from(_prayers);
    } else {
      // 선택된 태그에 맞는 기도문만 필터링
      _filteredPrayers =
          _prayers.where((prayer) => prayer.tag == _selectedTagFilter).toList();
    }
  }

  // 태그 필터 변경
  void _changeTagFilter(String? tag) {
    setState(() {
      _selectedTagFilter = tag;
      _applyTagFilter();
    });
  }

  // 태그 필터 초기화
  void _resetTagFilter() {
    setState(() {
      _selectedTagFilter = null;
      _applyTagFilter();
    });
  }

  // 예제 데이터 불러오기
  Future<void> _loadSampleData() async {
    try {
      final samplePrayers = PrayerDataExample.getSamplePrayers();
      await prayerRepository.importPrayers(samplePrayers);

      // 데이터 재로드
      final prayerList = await prayerRepository.getAllPrayers();
      prayerList.sort((a, b) => a.date.compareTo(b.date));

      // Prayer 타입을 UserPrayer 타입으로 매핑/변환 (구조에 맞게 조정)
      final userPrayers =
          prayerList
              .map(
                (p) => UserPrayer(
                  date: p.date,
                  time: '12:00', // 기본 시간
                  userInput: p.prayerKo, // 한국어 기도문
                  aiPrayer: p.prayerEn, // 영어 기도문을 AI 기도로 설정
                  tag: PrayerTags.OTHER, // 기본 태그 설정
                ),
              )
              .toList();

      setState(() {
        _prayers = userPrayers;
        _applyTagFilter(); // 태그 필터 적용
        _isLoading = false;
      });

      _showMessage('예제 기도문을 불러왔습니다');
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

  @override
  Widget build(BuildContext context) {
    // 언어 Provider 접근
    final languageProvider = Provider.of<LanguageProvider>(context);
    final String currentLanguage = languageProvider.currentLanguage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('일일 기도문'),
        actions: [
          // 언어 선택 버튼
          const LanguageSelector(),

          // 예제 데이터 로드 버튼
          IconButton(
            icon: const Icon(Icons.data_array),
            onPressed: _loadSampleData,
            tooltip: '예제 데이터 불러오기',
          ),

          // 새로고침 버튼
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPrayers,
            tooltip: '새로고침',
          ),
        ],
      ),
      body: Column(
        children: [
          // 태그 필터 영역
          if (!_isLoading && _prayers.isNotEmpty) _buildTagFilterSection(),

          // 기도문 목록 영역
          Expanded(child: _buildPrayerList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToInputScreen,
        tooltip: '새 기도문 작성',
        child: const Icon(Icons.add),
      ),
    );
  }

  // 태그 필터 섹션 위젯
  Widget _buildTagFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '주제별 필터링:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              if (_selectedTagFilter != null)
                TextButton.icon(
                  icon: const Icon(Icons.clear),
                  label: const Text('필터 초기화'),
                  onPressed: _resetTagFilter,
                ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // 모든 태그에 대한 필터 칩 생성
                ...PrayerTags.all.map((tag) {
                  bool isSelected = _selectedTagFilter == tag;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: TagChip(
                      tag: tag,
                      isSelected: isSelected,
                      onTap: () {
                        if (isSelected) {
                          _resetTagFilter();
                        } else {
                          _changeTagFilter(tag);
                        }
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          if (_selectedTagFilter != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  PrayerTags.getIconForTag(_selectedTagFilter!),
                  color: PrayerTags.getColorForTag(_selectedTagFilter!),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '$_selectedTagFilter 기도문 ${_filteredPrayers.length}개',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ],
          const Divider(height: 24),
        ],
      ),
    );
  }

  // 기도문 목록 위젯
  Widget _buildPrayerList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_prayers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '저장된 기도문이 없습니다.\n새 기도문을 작성해보세요.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _navigateToInputScreen();
              },
              child: const Text('기도문 작성하기'),
            ),
          ],
        ),
      );
    }

    if (_filteredPrayers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${_selectedTagFilter ?? ""} 태그의 기도문이 없습니다.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _resetTagFilter,
              child: const Text('필터 초기화'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPrayers,
      child: ListView.builder(
        itemCount: _filteredPrayers.length,
        itemBuilder: (context, index) {
          final prayer = _filteredPrayers[index];
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Card(
              elevation: 2,
              child: ListTile(
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${prayer.date} ${prayer.time}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    TagChip(tag: prayer.tag, isSelected: true),
                  ],
                ),
                subtitle: Text(
                  prayer.previewText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showDeleteConfirmation(prayer),
                ),
                onTap: () => _navigateToDetailScreen(prayer),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('기도문 삭제'),
                content: const Text('이 기도문을 삭제하시겠습니까?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('취소'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('삭제'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  Future<void> _deletePrayer(UserPrayer prayer) async {
    try {
      await PrayerSaveService.deleteUserPrayer(prayer.date, prayer.time);
      setState(() {
        _prayers.removeWhere(
          (p) => p.date == prayer.date && p.time == prayer.time,
        );
        _applyTagFilter(); // 필터 다시 적용
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('기도문이 삭제되었습니다')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('삭제 오류: $e')));
      }
    }
  }

  void _navigateToDetailScreen(UserPrayer prayer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrayerDetailScreen(prayer: prayer),
      ),
    ).then((_) => _loadPrayers());
  }

  void _navigateToInputScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrayerInputScreen()),
    ).then((_) => _loadPrayers());
  }

  Future<void> _showDeleteConfirmation(UserPrayer prayer) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('기도문 삭제'),
          content: const Text('이 기도문을 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('삭제', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deletePrayer(prayer);
              },
            ),
          ],
        );
      },
    );
  }
}
