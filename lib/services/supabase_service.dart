import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase 서비스
/// Supabase 클라이언트 초기화 및 관리를 담당
class SupabaseService {
  static SupabaseService? _instance;
  late SupabaseClient _client;

  /// 싱글톤 인스턴스 가져오기
  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  /// 생성자 (private)
  SupabaseService._();

  /// Supabase 클라이언트 가져오기
  SupabaseClient get client => _client;

  /// Supabase 초기화
  Future<void> initialize() async {
    try {
      // 환경 변수에서 값 가져오기
      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

      // 값이 없으면 오류 발생
      if (supabaseUrl == null || supabaseAnonKey == null) {
        throw Exception('Supabase URL 또는 Anonymous key가 .env 파일에 설정되지 않았습니다.');
      }

      // Supabase 초기화
      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

      // 클라이언트 설정
      _client = Supabase.instance.client;
      print('Supabase 초기화 완료.');
    } catch (e) {
      print('Supabase 초기화 오류: $e');
      rethrow;
    }
  }

  /// 테이블 존재 여부 확인
  Future<bool> checkTableExists(String tableName) async {
    try {
      final result =
          await _client
              .rpc('check_table_exists', params: {'p_table_name': tableName})
              .select();

      return result.isNotEmpty;
    } catch (e) {
      print('테이블 존재 여부 확인 오류: $e');
      return false;
    }
  }

  /// 테이블 생성 (테이블이 존재하지 않을 경우)
  Future<bool> createPrayersTable() async {
    try {
      // 테이블 존재 여부 확인
      final tableExists = await checkTableExists('prayers');
      if (tableExists) {
        print('prayers 테이블이 이미 존재합니다.');
        return true;
      }

      // SQL 스크립트 실행
      await _client.rpc('create_prayers_table');
      return true;
    } catch (e) {
      print('테이블 생성 오류: $e');
      return false;
    }
  }
}
