import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'services/supabase_service.dart';
import 'screens/prayer_list_screen.dart';
import 'services/prayer_repository.dart';
import 'services/prayer_storage_service.dart';
import 'providers/language_provider.dart';

// 글로벌 저장소 인스턴스
late PrayerRepository prayerRepository;

void main() async {
  // Flutter 바인딩 초기화 (플러그인 사용 전 필수)
  WidgetsFlutterBinding.ensureInitialized();

  // 환경 변수 로드
  await dotenv.load();

  // 로컬 저장소 생성
  final localRepository = LocalPrayerRepository(PrayerStorageService());

  try {
    // Supabase 초기화
    await SupabaseService.instance.initialize();

    // 원격 저장소 생성
    final remoteRepository = RemotePrayerRepository(
      SupabaseService.instance.client,
    );

    // 하이브리드 저장소 사용 (로컬 + 원격)
    prayerRepository = HybridPrayerRepository(
      localRepository,
      remoteRepository,
    );
    print('하이브리드 저장소 (로컬 + Supabase) 사용 중');
  } catch (e) {
    // Supabase 초기화 실패 시 로컬 저장소만 사용
    print('Supabase 초기화 실패: $e');
    print('로컬 저장소 (SharedPreferences) 사용 중');
    prayerRepository = localRepository;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 언어 Provider 초기화 및 제공
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LanguageProvider>(
          create: (_) {
            final provider = LanguageProvider();
            // 비동기로 SharedPreferences에서 언어 설정 로드
            provider.initialize();
            return provider;
          },
        ),
      ],
      child: MaterialApp(
        title: '일상 기도기록',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const PrayerListScreen(),
      ),
    );
  }
}
