import 'package:flutter/material.dart';
import '../services/stats_service.dart';
import 'package:intl/intl.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Map<String, dynamic> _stats = {
    'streak': 0,
    'todayVisits': 0,
    'totalVisits': 0,
    'checkTime': '9:00 AM',
  };

  bool _isLoading = true;
  TimeOfDay _selectedTime = TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
    });

    final stats = await StatsService.getStats();

    // 저장된 시간 문자열 파싱
    final checkTime = stats['checkTime'] as String;
    if (checkTime.isNotEmpty) {
      try {
        final format = DateFormat.jm(); // 오전/오후 형식
        final dateTime = format.parse(checkTime);
        _selectedTime = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
      } catch (e) {
        print('시간 파싱 오류: $e');
      }
    }

    setState(() {
      _stats = stats;
      _isLoading = false;
    });
  }

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });

      // 선택한 시간을 문자열로 변환하여 저장
      final now = DateTime.now();
      final dateTime = DateTime(
        now.year,
        now.month,
        now.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      final formattedTime = DateFormat.jm().format(dateTime); // 오전/오후 형식

      await StatsService.setCheckTime(formattedTime);
      _loadStats(); // 통계 다시 로드
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 기도 기록'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 통계 카드
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                '나의 기도 기록',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // 통계 아이콘 및 숫자
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  // 연속 접속일
                                  _buildStatItem(
                                    icon: Icons.local_fire_department,
                                    iconColor: Colors.orange,
                                    value: '${_stats['streak']}',
                                    label: '연속 접속일',
                                  ),

                                  // 오늘 접속
                                  _buildStatItem(
                                    icon: Icons.calendar_today,
                                    iconColor: Colors.blue,
                                    value: '${_stats['todayVisits']}',
                                    label: '오늘 접속',
                                  ),

                                  // 전체 접속
                                  _buildStatItem(
                                    icon: Icons.bar_chart,
                                    iconColor: Colors.green,
                                    value: '${_stats['totalVisits']}',
                                    label: '전체 접속',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 매일 확인 시간 설정
                      const Text(
                        '매일 확인 시간 설정',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '매일 이 시간이 되면 기도문을 작성하는 것을 잊지 마세요.',
                        style: TextStyle(color: Colors.grey),
                      ),

                      // 시간 선택기
                      ListTile(
                        title: const Text('확인 시간'),
                        subtitle: Text(
                          _stats['checkTime'],
                          style: const TextStyle(fontSize: 18),
                        ),
                        trailing: const Icon(Icons.access_time),
                        onTap: _selectTime,
                      ),

                      const Divider(),

                      // 사용 팁
                      const SizedBox(height: 24),
                      const Text(
                        '사용 팁',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildTipItem('매일 꾸준히 접속하면 연속 접속일이 늘어납니다.'),
                      _buildTipItem('설정한 시간에 알림이 오지 않더라도 매일 앱을 열어 기도문을 작성하세요.'),
                      _buildTipItem('기도문 내용을 메모해두면 나중에 모아볼 수 있습니다.'),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, size: 48, color: iconColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text(tip, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
