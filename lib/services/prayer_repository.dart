import '../models/prayer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'prayer_storage_service.dart';

/// 기도문 저장소 추상 인터페이스
/// 로컬 저장소와 원격 저장소 모두에 사용할 수 있는 공통 인터페이스
abstract class PrayerRepository {
  // 모든 기도문 가져오기
  Future<List<Prayer>> getAllPrayers();

  // ID로 기도문 가져오기
  Future<Prayer?> getPrayerById(int id);

  // 날짜로 기도문 가져오기
  Future<Prayer?> getPrayerByDate(String date);

  // 기도문 추가
  Future<bool> addPrayer(Prayer prayer);

  // 기도문 업데이트
  Future<bool> updatePrayer(Prayer prayer);

  // 기도문 삭제
  Future<bool> deletePrayer(int id);

  // 기도문 일괄 가져오기
  Future<bool> importPrayers(List<Prayer> prayers);

  // 새 ID 생성
  Future<int> generateNewId();
}

/// SharedPreferences 기반 로컬 저장소 구현체
class LocalPrayerRepository implements PrayerRepository {
  final PrayerStorageService _storageService;

  LocalPrayerRepository(this._storageService);

  @override
  Future<List<Prayer>> getAllPrayers() {
    return _storageService.getAllPrayers();
  }

  @override
  Future<Prayer?> getPrayerById(int id) {
    return _storageService.getPrayerById(id);
  }

  @override
  Future<Prayer?> getPrayerByDate(String date) {
    return _storageService.getPrayerByDate(date);
  }

  @override
  Future<bool> addPrayer(Prayer prayer) {
    return _storageService.addPrayer(prayer);
  }

  @override
  Future<bool> updatePrayer(Prayer prayer) {
    return _storageService.updatePrayer(prayer);
  }

  @override
  Future<bool> deletePrayer(int id) {
    return _storageService.deletePrayer(id);
  }

  @override
  Future<bool> importPrayers(List<Prayer> prayers) {
    return _storageService.importPrayers(prayers);
  }

  @override
  Future<int> generateNewId() {
    return _storageService.generateNewId();
  }

  // 추가 로컬 기능: JSON 내보내기
  Future<String> exportToJson() {
    return _storageService.exportPrayersToJson();
  }

  // 추가 로컬 기능: JSON 가져오기
  Future<bool> importFromJson(String jsonString) {
    return _storageService.importPrayersFromJson(jsonString);
  }
}

/// Supabase 기반 원격 저장소 구현체
class RemotePrayerRepository implements PrayerRepository {
  // Supabase 클라이언트
  final SupabaseClient _supabaseClient;

  RemotePrayerRepository(this._supabaseClient);

  @override
  Future<List<Prayer>> getAllPrayers() async {
    try {
      final response = await _supabaseClient
          .from('prayers')
          .select()
          .order('date');

      return (response as List<dynamic>)
          .map((json) => Prayer.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Supabase 기도문 불러오기 오류: $e');
      rethrow;
    }
  }

  @override
  Future<Prayer?> getPrayerById(int id) async {
    try {
      final response =
          await _supabaseClient
              .from('prayers')
              .select()
              .eq('id', id)
              .maybeSingle();

      if (response == null) {
        return null;
      }

      return Prayer.fromJson(response);
    } catch (e) {
      print('Supabase ID로 기도문 불러오기 오류: $e');
      rethrow;
    }
  }

  @override
  Future<Prayer?> getPrayerByDate(String date) async {
    try {
      final response =
          await _supabaseClient
              .from('prayers')
              .select()
              .eq('date', date)
              .maybeSingle();

      if (response == null) {
        return null;
      }

      return Prayer.fromJson(response);
    } catch (e) {
      print('Supabase 날짜로 기도문 불러오기 오류: $e');
      rethrow;
    }
  }

  @override
  Future<bool> addPrayer(Prayer prayer) async {
    try {
      await _supabaseClient.from('prayers').insert(prayer.toJson());

      return true;
    } catch (e) {
      print('Supabase 기도문 추가 오류: $e');
      return false;
    }
  }

  @override
  Future<bool> updatePrayer(Prayer prayer) async {
    try {
      await _supabaseClient
          .from('prayers')
          .update(prayer.toJson())
          .eq('id', prayer.id);

      return true;
    } catch (e) {
      print('Supabase 기도문 업데이트 오류: $e');
      return false;
    }
  }

  @override
  Future<bool> deletePrayer(int id) async {
    try {
      await _supabaseClient.from('prayers').delete().eq('id', id);

      return true;
    } catch (e) {
      print('Supabase 기도문 삭제 오류: $e');
      return false;
    }
  }

  @override
  Future<bool> importPrayers(List<Prayer> prayers) async {
    try {
      final jsonList = prayers.map((p) => p.toJson()).toList();
      await _supabaseClient.from('prayers').insert(jsonList);

      return true;
    } catch (e) {
      print('Supabase 기도문 일괄 추가 오류: $e');
      return false;
    }
  }

  @override
  Future<int> generateNewId() async {
    try {
      final response =
          await _supabaseClient
              .from('prayers')
              .select('id')
              .order('id', ascending: false)
              .limit(1)
              .maybeSingle();

      if (response == null) {
        return 1;
      }

      return (response['id'] as int) + 1;
    } catch (e) {
      print('Supabase ID 생성 오류: $e');
      return 1;
    }
  }

  // Supabase 서버와 동기화
  Future<bool> syncWithLocal(LocalPrayerRepository localRepository) async {
    try {
      // 로컬 데이터 불러오기
      final localPrayers = await localRepository.getAllPrayers();

      // 원격 데이터 불러오기
      final remotePrayers = await getAllPrayers();

      // 로컬에만 있는 기도문 찾기
      final localOnlyPrayers = localPrayers.where(
        (local) => !remotePrayers.any((remote) => remote.id == local.id),
      );

      // 로컬에만 있는 기도문 서버에 추가
      if (localOnlyPrayers.isNotEmpty) {
        await importPrayers(localOnlyPrayers.toList());
      }

      return true;
    } catch (e) {
      print('Supabase 동기화 오류: $e');
      return false;
    }
  }
}

/// 로컬 및 원격 저장소 함께 사용 (하이브리드 모드)
class HybridPrayerRepository implements PrayerRepository {
  final LocalPrayerRepository _localRepository;
  final RemotePrayerRepository _remoteRepository;

  // 오프라인 모드 상태 - 온라인 연결 실패 시 자동으로 켜짐
  bool _offlineMode = false;

  HybridPrayerRepository(this._localRepository, this._remoteRepository);

  bool get isOfflineMode => _offlineMode;

  // 오프라인 모드 전환
  void setOfflineMode(bool value) {
    _offlineMode = value;
  }

  @override
  Future<List<Prayer>> getAllPrayers() async {
    try {
      if (_offlineMode) {
        return await _localRepository.getAllPrayers();
      }

      // 원격 데이터 불러오기 시도
      final remotePrayers = await _remoteRepository.getAllPrayers();

      // 로컬 저장소에도 저장
      await _localRepository.importPrayers(remotePrayers);

      return remotePrayers;
    } catch (e) {
      print('원격 데이터 불러오기 실패, 로컬 데이터 사용: $e');
      _offlineMode = true;
      return await _localRepository.getAllPrayers();
    }
  }

  @override
  Future<Prayer?> getPrayerById(int id) async {
    try {
      if (_offlineMode) {
        return await _localRepository.getPrayerById(id);
      }

      final prayer = await _remoteRepository.getPrayerById(id);
      return prayer;
    } catch (e) {
      print('원격에서 ID로 기도문 불러오기 실패, 로컬 사용: $e');
      _offlineMode = true;
      return await _localRepository.getPrayerById(id);
    }
  }

  @override
  Future<Prayer?> getPrayerByDate(String date) async {
    try {
      if (_offlineMode) {
        return await _localRepository.getPrayerByDate(date);
      }

      final prayer = await _remoteRepository.getPrayerByDate(date);
      return prayer;
    } catch (e) {
      print('원격에서 날짜로 기도문 불러오기 실패, 로컬 사용: $e');
      _offlineMode = true;
      return await _localRepository.getPrayerByDate(date);
    }
  }

  @override
  Future<bool> addPrayer(Prayer prayer) async {
    // 항상 로컬에 저장
    final localSuccess = await _localRepository.addPrayer(prayer);

    // 오프라인 모드면 로컬 저장 결과만 반환
    if (_offlineMode) {
      return localSuccess;
    }

    // 원격 저장소에도 저장 시도
    try {
      final remoteSuccess = await _remoteRepository.addPrayer(prayer);
      return remoteSuccess;
    } catch (e) {
      print('원격 저장 실패, 로컬에만 저장: $e');
      _offlineMode = true;
      return localSuccess;
    }
  }

  @override
  Future<bool> updatePrayer(Prayer prayer) async {
    // 항상 로컬 업데이트
    final localSuccess = await _localRepository.updatePrayer(prayer);

    // 오프라인 모드면 로컬 결과만 반환
    if (_offlineMode) {
      return localSuccess;
    }

    // 원격 저장소도 업데이트 시도
    try {
      final remoteSuccess = await _remoteRepository.updatePrayer(prayer);
      return remoteSuccess;
    } catch (e) {
      print('원격 업데이트 실패, 로컬만 업데이트: $e');
      _offlineMode = true;
      return localSuccess;
    }
  }

  @override
  Future<bool> deletePrayer(int id) async {
    // 항상 로컬에서 삭제
    final localSuccess = await _localRepository.deletePrayer(id);

    // 오프라인 모드면 로컬 결과만 반환
    if (_offlineMode) {
      return localSuccess;
    }

    // 원격 저장소에서도 삭제 시도
    try {
      final remoteSuccess = await _remoteRepository.deletePrayer(id);
      return remoteSuccess;
    } catch (e) {
      print('원격 삭제 실패, 로컬만 삭제: $e');
      _offlineMode = true;
      return localSuccess;
    }
  }

  @override
  Future<bool> importPrayers(List<Prayer> prayers) async {
    // 항상 로컬에 저장
    final localSuccess = await _localRepository.importPrayers(prayers);

    // 오프라인 모드면 로컬 결과만 반환
    if (_offlineMode) {
      return localSuccess;
    }

    // 원격 저장소에도 저장 시도
    try {
      final remoteSuccess = await _remoteRepository.importPrayers(prayers);
      return remoteSuccess;
    } catch (e) {
      print('원격 일괄 저장 실패, 로컬에만 저장: $e');
      _offlineMode = true;
      return localSuccess;
    }
  }

  @override
  Future<int> generateNewId() async {
    if (_offlineMode) {
      return await _localRepository.generateNewId();
    }

    try {
      return await _remoteRepository.generateNewId();
    } catch (e) {
      print('원격 ID 생성 실패, 로컬 ID 생성: $e');
      _offlineMode = true;
      return await _localRepository.generateNewId();
    }
  }

  // 로컬 데이터를 원격으로 동기화
  Future<bool> syncLocalToRemote() async {
    if (_offlineMode) {
      return false;
    }

    try {
      return await _remoteRepository.syncWithLocal(_localRepository);
    } catch (e) {
      print('동기화 실패: $e');
      _offlineMode = true;
      return false;
    }
  }
}
