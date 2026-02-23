-- =============================================
-- DS OB Golf Club - Supabase 테이블 설정
-- =============================================
-- Supabase 대시보드 > SQL Editor 에서 이 SQL을 실행하세요.

-- 1. 앱 데이터 테이블 생성
CREATE TABLE IF NOT EXISTS app_data (
  id INTEGER PRIMARY KEY DEFAULT 1,
  data JSONB NOT NULL DEFAULT '{}',
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT single_row CHECK (id = 1)
);

-- 2. Row Level Security (RLS) 활성화
ALTER TABLE app_data ENABLE ROW LEVEL SECURITY;

-- 3. 모든 사용자가 읽기/쓰기 가능하도록 정책 설정
-- (인증 없이 누구나 접근 가능 - 골프 클럽 멤버용)
CREATE POLICY "Allow public read" ON app_data
  FOR SELECT USING (true);

CREATE POLICY "Allow public insert" ON app_data
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow public update" ON app_data
  FOR UPDATE USING (true);

-- 4. 실시간 기능 활성화 (다른 사용자의 변경사항 자동 반영)
ALTER PUBLICATION supabase_realtime ADD TABLE app_data;

-- 5. updated_at 자동 갱신 트리거
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON app_data
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();
