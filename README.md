# DS OB Golf 2026 기록 페이지

본인 전용 골프 모임 기록 페이지입니다. 라운드(조 편성·스코어·포상), 개인 집계, 동반자 매트릭스, 재정(입출금·1인당 지출)을 기록합니다.

- 주소: `https://dsobgolf.duckdns.org` (아이디·비밀번호 보호)
- 서버: AWS EC2 `54.160.129.26` (Ubuntu 24.04, nginx). `ygarchive`와 같은 서버이며 기존 사이트 설정은 건드리지 않습니다.
- 데이터: 서버의 `/var/lib/dsobgolf/data.json` 한 파일. 매일 `/var/backups/dsobgolf/`에 백업되고 180일 보관됩니다.

## 파일

| 파일 | 역할 |
|---|---|
| `index.html` | 페이지 전체 (HTML·CSS·JS 한 파일, 2026 초기 데이터 포함) |
| `deploy/deploy.sh` | **맥미니에서 실행.** index.html 과 setup.sh 를 서버로 복사한 뒤 설치/업데이트 |
| `deploy/setup.sh` | 서버에서 실행됨. nginx 사이트 추가, 로그인 계정, HTTPS, 백업 설정 |

## 맥미니에서 처음 설치

```bash
cd ~/dsobgolf
bash deploy/deploy.sh
```

- 처음 한 번만 로그인 비밀번호를 두 번 묻습니다 (아이디 기본값 `golf`, 바꾸려면 `LOGIN=아이디 bash deploy/deploy.sh`).
- 끝에 `확인 … 401` 이 나오면 성공입니다.
- SSH 키 경로가 다르면 `KEY=~/.ssh/키파일.pem bash deploy/deploy.sh`.

## 페이지 수정 후 반영

`index.html` 을 고친 뒤 같은 명령을 다시 실행하면 됩니다. 계정·데이터·인증서는 그대로 유지되고 페이지 파일만 바뀝니다.

```bash
bash deploy/deploy.sh
```

## 자주 쓰는 서버 명령

```bash
# 비밀번호 변경
ssh -t -i ~/.ssh/research-key.pem ubuntu@54.160.129.26 'sudo htpasswd /etc/nginx/.htpasswd-dsobgolf golf'

# 데이터 파일을 맥미니로 내려받기
scp -i ~/.ssh/research-key.pem ubuntu@54.160.129.26:/var/lib/dsobgolf/data.json ~/Desktop/
```

페이지의 **멤버·설정 → JSON 내보내기/가져오기** 로도 백업·복원할 수 있습니다.
