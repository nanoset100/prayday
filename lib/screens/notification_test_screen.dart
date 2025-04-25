import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  final NotificationService _notificationService = NotificationService();
  String _status = '알림 상태: 초기화 필요';
  bool _isOnce = true; // 하루 1회 모드 (기본값)

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    await _notificationService.initialize();
    final hasPermission = await _notificationService.requestPermission();

    setState(() {
      _status = hasPermission ? '알림 상태: 권한 허용됨' : '알림 상태: 권한 거부됨';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('기도 알림 설정')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 상태 표시
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(_status, style: const TextStyle(fontSize: 16)),
              ),
            ),

            const SizedBox(height: 24),

            // 알림 빈도 선택
            const Text(
              '알림 빈도 설정:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            RadioListTile<bool>(
              title: const Text('하루 1회 (오전 9시)'),
              value: true,
              groupValue: _isOnce,
              onChanged: (value) {
                setState(() {
                  _isOnce = value!;
                });
              },
            ),

            RadioListTile<bool>(
              title: const Text('하루 3회 (아침 8시, 점심 12시, 저녁 8시)'),
              value: false,
              groupValue: _isOnce,
              onChanged: (value) {
                setState(() {
                  _isOnce = value!;
                });
              },
            ),

            const SizedBox(height: 24),

            // 알림 설정 버튼
            ElevatedButton(
              onPressed: _scheduleNotifications,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('알림 설정하기', style: TextStyle(fontSize: 16)),
            ),

            const SizedBox(height: 16),

            // 테스트 알림 버튼
            OutlinedButton(
              onPressed: _sendTestNotification,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('테스트 알림 보내기', style: TextStyle(fontSize: 16)),
            ),

            const SizedBox(height: 16),

            // 알림 취소 버튼
            TextButton(
              onPressed: _cancelAllNotifications,
              child: const Text('모든 알림 취소하기'),
            ),
          ],
        ),
      ),
    );
  }

  /// 알림 스케줄 설정
  Future<void> _scheduleNotifications() async {
    try {
      if (_isOnce) {
        // 하루 1회 알림
        await _notificationService.scheduleDailyNotification();
        setState(() {
          _status = '알림 설정 완료: 하루 1회 (오전 9시)';
        });
      } else {
        // 하루 3회 알림
        await _notificationService.scheduleThreeDailyNotifications();
        setState(() {
          _status = '알림 설정 완료: 하루 3회 (아침, 점심, 저녁)';
        });
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('기도 알림이 설정되었습니다')));
    } catch (e) {
      setState(() {
        _status = '알림 설정 오류: $e';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('알림 설정 중 오류 발생: $e')));
    }
  }

  /// 테스트 알림 발송
  Future<void> _sendTestNotification() async {
    try {
      await _notificationService.showTestNotification();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('테스트 알림이 발송되었습니다')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('테스트 알림 발송 중 오류 발생: $e')));
    }
  }

  /// 모든 알림 취소
  Future<void> _cancelAllNotifications() async {
    try {
      await _notificationService.cancelAllNotifications();
      setState(() {
        _status = '모든 알림이 취소되었습니다';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('모든 알림이 취소되었습니다')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('알림 취소 중 오류 발생: $e')));
    }
  }
}
