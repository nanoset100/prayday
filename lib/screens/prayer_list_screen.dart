import 'package:flutter/material.dart';
import '../models/user_prayer.dart';
import '../services/prayer_save_service.dart';
import '../widgets/tag_selector.dart';
import 'prayer_detail_screen.dart';
import 'prayer_input_screen.dart';
import 'stats_screen.dart';

class PrayerListScreen extends StatefulWidget {
  const PrayerListScreen({super.key});

  @override
  State<PrayerListScreen> createState() => _PrayerListScreenState();
}

class _PrayerListScreenState extends State<PrayerListScreen> {
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

  // 메시지 표시
  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('일일 기도문'),
        actions: [
          // 통계 화면 버튼
          IconButton(
            icon: const Icon(Icons.insights),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatsScreen()),
              );
            },
            tooltip: '나의 기록',
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
