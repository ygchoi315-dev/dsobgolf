#!/usr/bin/env bash
# 맥미니에서 실행: index.html 과 서버 설치 스크립트를 EC2 로 올리고 설치/업데이트합니다.
#   사용법:  bash deploy.sh            (처음 설치 시 로그인 아이디: golf)
#            LOGIN=원하는아이디 bash deploy.sh
#   이 파일과 같은 폴더에 index.html, setup.sh 가 있어야 합니다.
#   처음 실행 때만 비밀번호를 두 번 묻고, 이후 실행은 index.html 만 갱신됩니다(데이터·계정 유지).
set -euo pipefail
KEY="${KEY:-$HOME/.ssh/research-key.pem}"
HOST="${HOST:-ubuntu@54.160.129.26}"
LOGIN="${LOGIN:-golf}"
DIR="$(cd "$(dirname "$0")" && pwd)"
[ -f "$DIR/index.html" ] || DIR="$(cd "$DIR/.." && pwd)"   # 저장소 구조(deploy/ 하위)에서도 동작
SETUP="$(cd "$(dirname "$0")" && pwd)/setup.sh"

for f in "$DIR/index.html" "$SETUP"; do [ -f "$f" ] || { echo "파일 없음: $f"; exit 1; }; done

ssh -i "$KEY" "$HOST" 'mkdir -p /tmp/dsob'
scp -i "$KEY" "$DIR/index.html" "$SETUP" "$HOST:/tmp/dsob/"
ssh -t -i "$KEY" "$HOST" "sudo bash /tmp/dsob/setup.sh $LOGIN; rm -rf /tmp/dsob"
