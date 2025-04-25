import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// 기도 알림 서비스
class NotificationService {
  // 싱글톤 인스턴스
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // 알림 플러그인 인스턴스
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 알림 ID 상수
  static const int morningNotificationId = 0;
  static const int noonNotificationId = 1;
  static const int eveningNotificationId = 2;

  /// 알림 서비스 초기화
  Future<void> initialize() async {
    // 타임존 초기화
    tz_data.initializeTimeZones();

    // Android 설정
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 설정
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    // 초기화 설정
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // 플러그인 초기화
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Android 13 이상에서 알림 권한 요청
    await _requestPermissions();

    // 매일 기도 알림 예약
    await scheduleDailyPrayerNotification();
  }

  /// 알림 권한 요청
  Future<bool> requestPermission() async {
    // iOS 권한 요청
    final bool? iosResult = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // 주의: AndroidFlutterLocalNotificationsPlugin.requestPermission()은 19.x 버전에서 제거됨
    // Android 권한은 initialize() 메서드에서 처리해야 함

    return iosResult ?? false;
  }

  /// 하루 1회 알림 설정 (아침 9시)
  Future<void> scheduleDailyNotification() async {
    await cancelAllNotifications(); // 기존 알림 제거

    final now = DateTime.now();
    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      9, // 오전 9시
      0,
    );

    // 이미 지난 시간이면 다음날로 설정
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await _scheduleNotification(
      id: morningNotificationId,
      title: '기도 시간',
      body: '오늘도 기도로 시작해보세요!',
      scheduledTime: scheduledTime,
    );
  }

  /// 하루 3회 알림 설정 (아침 8시, 점심 12시, 저녁 8시)
  Future<void> scheduleThreeDailyNotifications() async {
    await cancelAllNotifications(); // 기존 알림 제거

    final now = DateTime.now();

    // 아침 알림 (8시)
    var morningTime = DateTime(now.year, now.month, now.day, 8, 0);
    if (morningTime.isBefore(now)) {
      morningTime = morningTime.add(const Duration(days: 1));
    }

    // 점심 알림 (12시)
    var noonTime = DateTime(now.year, now.month, now.day, 12, 0);
    if (noonTime.isBefore(now)) {
      noonTime = noonTime.add(const Duration(days: 1));
    }

    // 저녁 알림 (20시)
    var eveningTime = DateTime(now.year, now.month, now.day, 20, 0);
    if (eveningTime.isBefore(now)) {
      eveningTime = eveningTime.add(const Duration(days: 1));
    }

    // 알림 예약
    await _scheduleNotification(
      id: morningNotificationId,
      title: '아침 기도 시간',
      body: '하루를 기도로 시작해보세요.',
      scheduledTime: morningTime,
    );

    await _scheduleNotification(
      id: noonNotificationId,
      title: '점심 기도 시간',
      body: '잠시 멈추고 기도의 시간을 가져보세요.',
      scheduledTime: noonTime,
    );

    await _scheduleNotification(
      id: eveningNotificationId,
      title: '저녁 기도 시간',
      body: '오늘 하루를 돌아보며 기도해보세요.',
      scheduledTime: eveningTime,
    );
  }

  /// 알림 예약 내부 메서드
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    // Android 알림 상세 설정 (SDK 33-34 호환성 문제 해결)
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'prayer_notification_channel',
          '기도 알림',
          channelDescription: '정기적인 기도 알림',
          importance: Importance.high,
          priority: Priority.high,
          enableLights: true,
          playSound: true,
          // null 값 사용 금지 (Android SDK 33-34 문제)
          largeIcon: null,
          // 스타일 설정 방식 변경
          styleInformation: BigTextStyleInformation(''),
        );

    // iOS 알림 상세 설정
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // 플랫폼 통합 알림 상세 설정
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // 매일 반복 알림 설정 (19.x 버전 호환)
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // 매일 같은 시간에 반복
    );
  }

  /// 테스트용 즉시 알림
  Future<void> showTestNotification() async {
    // Android 호환성 문제 해결
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'prayer_test_channel',
          '테스트 알림',
          channelDescription: '알림 테스트용 채널',
          importance: Importance.max,
          priority: Priority.high,
          // SDK 33-34 호환성 문제 해결
          styleInformation: BigTextStyleInformation(''),
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      999, // 테스트용 ID
      '테스트 알림',
      '알림이 정상적으로 작동합니다!',
      notificationDetails,
    );
  }

  /// 모든 알림 취소
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  /// 알림 탭 콜백 핸들러
  void _onNotificationTap(NotificationResponse response) {
    // 알림 탭 시 처리할 로직
    // 예: 특정 화면으로 이동하기
  }

  Future<void> _requestPermissions() async {}

  Future<void> scheduleDailyPrayerNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'prayer_channel',
      '기도 알림',
      channelDescription: '매일 기도 시간을 알려주는 알림입니다.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    // 매일 오전 9시에 알림 예약 (19.x 버전 호환)
    await _notificationsPlugin.zonedSchedule(
      0,
      '🙏 기도의 시간입니다',
      '오늘도 하나님과 함께 기도로 하루를 시작해요!',
      _nextInstanceOfNineAM(),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfNineAM() {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      9,
      0,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }
}
