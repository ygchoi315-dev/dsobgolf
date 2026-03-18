# DS OB Golf Club - Firebase 설정 가이드

## 1. Firebase 프로젝트 생성

1. https://console.firebase.google.com/ 접속
2. **"프로젝트 추가"** 클릭
3. 프로젝트 이름 입력 (예: `dsob-golf-club`)
4. Google Analytics는 **사용 안 함** 선택 (필요 없음)
5. **"프로젝트 만들기"** 클릭

## 2. Realtime Database 생성

1. 왼쪽 메뉴에서 **빌드 > Realtime Database** 선택
2. **"데이터베이스 만들기"** 클릭
3. 위치 선택: **asia-southeast1** (싱가포르, 한국에서 가장 가까움)
4. 보안 규칙: **테스트 모드에서 시작** 선택
5. **"사용 설정"** 클릭

## 3. 보안 규칙 설정

Realtime Database > **규칙** 탭에서 아래 내용으로 수정:

```json
{
  "rules": {
    ".read": true,
    ".write": true
  }
}
```

**"게시"** 클릭하여 저장

> 참고: 이 설정은 누구나 읽기/쓰기가 가능합니다. 골프 클럽 멤버 전용 앱이므로 이 설정이 적합합니다.

## 4. 웹 앱 등록 및 설정값 가져오기

1. **프로젝트 설정** (왼쪽 상단 톱니바퀴 아이콘) 클릭
2. **"일반"** 탭에서 아래로 스크롤
3. **"앱 추가"** > 웹 아이콘 (`</>`) 클릭
4. 앱 닉네임 입력 (예: `DSOB Golf Web`)
5. **"앱 등록"** 클릭
6. 표시되는 설정에서 아래 두 값을 복사:
   - `apiKey` (예: `AIzaSyA...`)
   - `databaseURL` (예: `https://dsob-golf-club-default-rtdb.asia-southeast1.firebasedatabase.app`)

## 5. index.html에 설정값 입력

`index.html` 파일에서 아래 부분을 찾아 복사한 값을 입력:

```javascript
const FIREBASE_CONFIG = {
  apiKey: "여기에_apiKey_붙여넣기",
  databaseURL: "여기에_databaseURL_붙여넣기"
};
```

## 6. 확인

1. 브라우저에서 앱을 열면 **"동기화됨"** (초록색 점)이 표시되어야 합니다
2. 데이터를 수정하면 Firebase Console > Realtime Database > **데이터** 탭에서 변경 내용을 확인할 수 있습니다

## Firebase 무료 플랜 (Spark) 제한

- 저장 용량: 1GB
- 다운로드: 10GB/월
- 동시 연결: 100개
- 프로젝트 일시중지: **없음** (Supabase와 다르게 자동 중지 안 됨)

골프 클럽 규모의 데이터에는 충분합니다.
