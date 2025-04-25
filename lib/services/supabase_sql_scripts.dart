/// 이 파일은 Supabase SQL 에디터에서 실행할 스크립트를 포함합니다.
/// 실제 앱에서 사용되지 않으며, Supabase 데이터베이스 설정을 위한 참고용입니다.
library;

/// 테이블 존재 여부 확인 함수
const checkTableExistsScript = '''
CREATE OR REPLACE FUNCTION check_table_exists(p_table_name text)
RETURNS SETOF record AS
\$\$
BEGIN
    RETURN QUERY SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = p_table_name
    ) AS exists;
END;
\$\$ LANGUAGE plpgsql;
''';

/// prayers 테이블 생성 함수
const createPrayersTableScript = '''
CREATE OR REPLACE FUNCTION create_prayers_table()
RETURNS void AS
\$\$
BEGIN
    -- Check if table already exists
    IF NOT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'prayers'
    ) THEN
        -- Create the prayers table
        CREATE TABLE prayers (
            id INT PRIMARY KEY,
            date TEXT NOT NULL,
            theme_ko TEXT NOT NULL,
            verse_ko TEXT NOT NULL,
            prayer_ko TEXT NOT NULL,
            theme_en TEXT NOT NULL,
            verse_en TEXT NOT NULL,
            prayer_en TEXT NOT NULL,
            theme_ja TEXT NOT NULL,
            verse_ja TEXT NOT NULL,
            prayer_ja TEXT NOT NULL,
            theme_zh TEXT NOT NULL,
            verse_zh TEXT NOT NULL,
            prayer_zh TEXT NOT NULL,
            theme_es TEXT NOT NULL,
            verse_es TEXT NOT NULL,
            prayer_es TEXT NOT NULL,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
        );
        
        -- Set up Row Level Security (RLS)
        ALTER TABLE prayers ENABLE ROW LEVEL SECURITY;
        
        -- Create policy for authenticated users
        CREATE POLICY "Allow authenticated read access" 
        ON prayers FOR SELECT 
        USING (auth.role() = 'authenticated');
        
        -- Create policy for authenticated insert
        CREATE POLICY "Allow authenticated insert" 
        ON prayers FOR INSERT 
        WITH CHECK (auth.role() = 'authenticated');
        
        -- Create policy for authenticated update
        CREATE POLICY "Allow authenticated update" 
        ON prayers FOR UPDATE 
        USING (auth.role() = 'authenticated');
        
        -- Create policy for authenticated delete
        CREATE POLICY "Allow authenticated delete" 
        ON prayers FOR DELETE 
        USING (auth.role() = 'authenticated');
    END IF;
END;
\$\$ LANGUAGE plpgsql;
''';

/// Supabase SQL 에디터에서 실행할 전체 스크립트
const fullScript = '''
-- 테이블 존재 여부를 확인하는 함수
$checkTableExistsScript

-- prayers 테이블을 생성하는 함수
$createPrayersTableScript

-- prayers 테이블 생성 함수 실행
SELECT create_prayers_table();
''';

/// Supabase 설정 가이드
const setupGuide = '''
Supabase 설정 가이드:

1. Supabase 대시보드에서 SQL 에디터 실행
2. 위의 fullScript 내용을 복사하여 SQL 에디터에 붙여넣기
3. 스크립트 실행하여 필요한 함수와 테이블 생성
4. Storage 설정 (선택사항):
   - 기도문 이미지를 저장할 bucket 생성 (예: prayer_images)
   - 접근 권한 설정: 인증된 사용자만 읽기/쓰기 가능하도록 설정
5. Authentication 설정 (선택사항): 
   - 앱에 필요한 인증 방식 설정 (이메일/비밀번호, OAuth 등)
''';
