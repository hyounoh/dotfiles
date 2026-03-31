# 백엔드 엔지니어 CLI 레퍼런스

터미널에서 자주 쓰는 명령어와 패턴 모음.

---

## 주요 명령어 패턴

### ripgrep (rg) — 코드 검색

```bash
# 특정 타입 파일에서 패턴 검색 (파일 목록만)
rg "OrderService" --type kotlin -l

# 매칭 전후 컨텍스트 포함
rg "fun cancel" -A 10 -B 2 --type kotlin

# 정규식으로 클래스/함수 정의 탐색
rg "class\s+\w+Repository" --type kotlin

# 특정 디렉토리 제외
rg "TODO" --type kotlin --glob "!**/test/**"

# 대소문자 무시
rg -i "eximbay" --type kotlin

# 단어 단위 매칭
rg -w "cancel" --type kotlin
```

---

### jq — JSON 처리

API 응답, 설정 파일, 빌드 결과 등 JSON 데이터를 가공할 때 핵심 도구.

```bash
# 기본 포맷팅
curl -s https://api.example.com/orders | jq '.'

# 배열에서 특정 필드만 추출
jq '.items[].orderId' response.json

# 조건 필터링
jq '.[] | select(.status == "FAILED")' results.json

# 중첩 구조 탐색
jq '.order.pgResponse.resultCode' response.json

# 여러 필드 조합 출력
jq '.[] | {id: .orderId, amount: .totalAmount, status: .status}' orders.json

# 배열 길이
jq '.items | length' response.json

# null 제거
jq '[.[] | select(.cancelledAt != null)]' orders.json

# 키 목록 확인 (구조 파악용)
jq 'keys' response.json
jq '.[0] | keys' array-response.json

# 문자열로 raw 출력 (-r)
jq -r '.[] | .name' users.json

# curl과 파이프라인 조합
curl -s -X POST https://api.example.com/pay \
  -H "Content-Type: application/json" \
  -d '{"amount": 1000}' | jq '.result.tid'
```

---

### find — 파일 탐색

```bash
# 특정 확장자 파일 탐색
find . -name "*.kt" -path "*/domain/*"

# 최근 수정된 파일
find . -name "*.kt" -newer build.gradle.kts

# 특정 디렉토리 제외
find . -name "*.sql" -not -path "*/build/*"

# 파일 크기 필터
find . -name "*.log" -size +10M

# 탐색 결과를 다른 명령어에 전달
find . -name "V*.sql" | sort | tail -5
```

---

### git — 변경 이력 탐색

```bash
# 최근 커밋 한줄 요약
git log --oneline -20

# 특정 파일의 변경 이력
git log --oneline -- order/src/main/kotlin/OrderService.kt

# 변경된 파일 목록만
git diff --stat HEAD~1

# 특정 문자열이 추가/삭제된 커밋 찾기
git log -S "cancelOrder" --oneline

# 브랜치 간 파일 비교
git diff main..feature/cancel -- src/OrderService.kt

# 코드베이스 전체에서 패턴 검색 (git grep)
git grep "TossPayClient" -- "*.kt"

# 특정 커밋 시점의 파일 내용 확인
git show HEAD~3:order/src/main/kotlin/OrderService.kt
```

---

### sed — 스트림 텍스트 편집

```bash
# 특정 줄 범위만 출력 (큰 파일에서 부분 확인)
sed -n '50,80p' LargeFile.kt

# 특정 패턴 줄만 삭제
sed '/^\/\//d' file.kt   # 주석 줄 제거

# 문자열 치환 (첫 번째만 / 전체)
sed 's/old/new/' file.txt        # 각 줄의 첫 번째만
sed 's/old/new/g' file.txt       # 각 줄의 전체

# 파일 직접 수정 (-i)
sed -i '' 's/localhost:3306/127.0.0.1:3306/g' config.yml   # macOS
sed -i 's/localhost:3306/127.0.0.1:3306/g' config.yml      # Linux

# 특정 줄만 치환
sed '5s/old/new/' file.txt       # 5번째 줄만
sed '10,20s/old/new/g' file.txt  # 10~20번째 줄

# 줄 삭제
sed '1d' file.txt                # 첫 줄 삭제 (헤더 제거)
sed '/^$/d' file.txt             # 빈 줄 제거
sed '/^#/d' config.yml           # 주석 줄 제거

# 줄 추가
sed '3a\new line' file.txt       # 3번째 줄 뒤에 추가
sed '1i\header line' file.txt    # 1번째 줄 앞에 삽입

# 파이프라인 조합
cat app.log | sed -n '/ERROR/,/^$/p'   # ERROR부터 빈 줄까지 블록 추출
env | sed 's/=.*//g'                   # 환경변수 이름만 출력
```

---

### awk — 필드 기반 텍스트 처리

```bash
# ── 기본: 필드 추출 ──
# 기본 구분자는 공백/탭
awk '{print $1}' file.txt              # 첫 번째 필드
awk '{print $1, $3}' file.txt          # 1, 3번째 필드
awk '{print $NF}' file.txt             # 마지막 필드
awk '{print NR, $0}' file.txt          # 줄 번호 + 전체 줄

# 구분자 지정 (-F)
awk -F',' '{print $1, $3}' data.csv    # CSV
awk -F':' '{print $1}' /etc/passwd     # 콜론 구분
awk -F'\t' '{print $2}' data.tsv       # 탭 구분

# ── 조건 필터 ──
awk '$3 > 1000' data.csv               # 3번째 필드가 1000 초과
awk '$2 == "ERROR"' app.log            # 2번째 필드가 ERROR
awk '/order/' file.txt               # "order" 포함 줄만
awk '!/^#/' config.yml                 # 주석 아닌 줄만

# ── 집계 ──
# 합산
awk '{sum += $2} END {print sum}' amounts.txt

# 카운트
awk '/ERROR/ {count++} END {print count}' app.log

# 평균
awk '{sum += $2; n++} END {print sum/n}' amounts.txt

# 최대/최소
awk 'BEGIN{max=0} $2>max {max=$2} END{print max}' data.txt

# ── 포맷 출력 ──
# printf로 정렬된 표
awk -F',' '{printf "%-20s %-10s %8d\n", $1, $2, $3}' data.csv

# 출력 구분자 변경
awk -F',' 'BEGIN{OFS="\t"} {print $1, $3}' data.csv   # CSV → TSV

# ── 실전 패턴 ──
# 프로세스 메모리 사용량 (RSS, MB)
ps aux | awk '{print $11, $6/1024 "MB"}' | sort -k2 -rn | head -10

# 로그에서 시간대별 에러 빈도
awk '/ERROR/ {print substr($1,1,13)}' app.log | sort | uniq -c

# Gradle 의존성에서 버전만 추출
./gradlew dependencies | awk -F':' '/spring-boot/ {print $NF}'

# docker stats에서 CPU/MEM 추출
docker stats --no-stream --format "{{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" | \
  awk -F'\t' '{printf "%-30s %8s %s\n", $1, $2, $3}'
```

---

### curl — HTTP 요청

```bash
# GET 요청
curl -s https://api.example.com/orders
curl -s https://api.example.com/orders | jq '.'

# POST with JSON body
curl -s -X POST https://api.example.com/pay \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"amount": 1000, "currency": "KRW"}'

# PUT / PATCH
curl -s -X PUT https://api.example.com/orders/123 \
  -H "Content-Type: application/json" \
  -d '{"status": "CANCELLED"}'

# 응답 상태 코드만 확인
curl -s -o /dev/null -w "%{http_code}" https://api.example.com/health

# 요청/응답 헤더 포함 출력 (-v)
curl -v https://api.example.com/orders 2>&1 | head -50

# 파일로 저장
curl -s -o response.json https://api.example.com/orders

# 리다이렉트 따라가기 (-L)
curl -sL https://short.url/abc

# 타임아웃 설정
curl -s --connect-timeout 5 --max-time 10 https://api.example.com/orders

# JSON 파일로 body 전송
curl -s -X POST https://api.example.com/pay \
  -H "Content-Type: application/json" \
  -d @request.json
```

---

### gh — GitHub CLI

```bash
# PR 목록 / 상세 보기
gh pr list
gh pr view 123
gh pr view --web   # 브라우저로 열기

# PR 생성
gh pr create --title "feat: add cancel API" --body "..." --base main

# PR 체크아웃
gh pr checkout 123

# PR 상태 / CI 확인
gh pr status
gh pr checks 123

# PR 머지
gh pr merge 123 --squash
gh pr merge 123 --rebase

# 이슈 목록 / 생성
gh issue list
gh issue create --title "Bug: ..." --body "..." --label bug

# 릴리즈 목록 / 생성
gh release list
gh release create v1.2.3 --notes "Release notes"

# 워크플로우 실행 / 목록
gh workflow list
gh workflow run deploy.yml --field env=prod

# API 직접 호출 (REST)
gh api repos/{owner}/{repo}/pulls --jq '.[].title'
gh api -X POST repos/{owner}/{repo}/issues \
  --field title="Bug report" --field body="..."

# 현재 레포 정보
gh repo view
gh repo clone owner/repo
```

---

### 네트워크 — 포트·연결 진단

```bash
# 포트 점유 프로세스 확인
lsof -i :9001
lsof -i :9001 -n -P

# 포트 범위 점유 현황
lsof -i :9001-9010

# 프로세스 ID로 포트 확인
lsof -p <PID> -i

# TCP 연결 상태 (ss — modern)
ss -tlnp           # 리스닝 포트 목록
ss -tnp            # 연결 중인 TCP 세션
ss -tnp | grep 9001

# TCP 연결 상태 (netstat — legacy, macOS)
netstat -an | grep 9001
netstat -tlnp 2>/dev/null | grep LISTEN

# DNS 조회
dig api.example.com
dig api.example.com A +short
nslookup api.example.com

# 포트 연결 가능 여부 확인 (nc)
nc -zv localhost 9001
nc -zv -w 3 redis.internal 6379  # 타임아웃 3초

# ping / traceroute
ping -c 3 api.example.com
traceroute api.example.com

# HTTP 응답 헤더만 확인
curl -I https://api.example.com/health
curl -sI https://api.example.com/health | grep -i "content-type\|status"
```

---

### I/O Redirection — 입출력 제어

```bash
# stdout → 파일 덮어쓰기
command > output.txt

# stdout → 파일 추가
command >> output.txt

# stderr → 파일
command 2> error.log

# stdout + stderr → 동일 파일
command > output.txt 2>&1
command &> output.txt          # bash 단축형

# stderr 버리기
command 2>/dev/null

# stdout 버리고 stderr만 보기
command 1>/dev/null

# 둘 다 버리기
command > /dev/null 2>&1

# stdin 파일에서 읽기
mysql -u user -p database < schema.sql

# Here-doc — 멀티라인 입력
cat <<EOF
line1
line2
EOF

# Here-doc → 파일
cat > config.yaml <<EOF
server:
  port: 9001
EOF

# Here-string — 단일 문자열 stdin
jq '.' <<< '{"key": "value"}'
grep "pattern" <<< "$VARIABLE"

# tee — stdout 유지하며 파일에도 기록
./gradlew build 2>&1 | tee build.log
command | tee output.txt | grep "ERROR"

# process substitution — 파일처럼 다루기
diff <(git show HEAD:file.kt) <(cat file.kt)
```

---

### vim — 편집기 필수 조작

```bash
# 실행
vim file.kt
vim +50 file.kt       # 50번째 줄에서 열기
vim +/pattern file.kt # 패턴 위치에서 열기
```

```
# 모드 전환
i      삽입 모드 진입 (커서 앞)
a      삽입 모드 진입 (커서 뒤)
o      아래 줄에 새 줄 삽입 후 진입
O      위 줄에 새 줄 삽입 후 진입
Esc    노말 모드로 복귀

# 저장 / 종료
:w     저장
:q     종료 (변경 없을 때)
:wq    저장 후 종료
:q!    저장 없이 강제 종료
ZZ     저장 후 종료 (단축키)

# 이동
h/j/k/l   ←↓↑→
gg         파일 첫 줄
G          파일 마지막 줄
:50        50번째 줄로 이동
w / b      다음 / 이전 단어
0 / ^      줄 처음 / 첫 글자
$          줄 끝
Ctrl-d/u   반 페이지 아래/위

# 편집
dd     현재 줄 삭제 (잘라내기)
yy     현재 줄 복사
p / P  붙여넣기 (커서 아래/위)
u      실행 취소
Ctrl-r 다시 실행
x      커서 글자 삭제
dw     단어 삭제
D      줄 끝까지 삭제
C      줄 끝까지 삭제 후 삽입 모드

# 검색
/pattern    아래 방향 검색
?pattern    위 방향 검색
n / N       다음 / 이전 매칭
*           커서 단어 검색 (아래)
#           커서 단어 검색 (위)

# 치환 (sed 스타일)
:s/old/new/         현재 줄 첫 번째
:s/old/new/g        현재 줄 전체
:%s/old/new/g       파일 전체
:%s/old/new/gc      파일 전체 (확인 요청)
:10,20s/old/new/g   10~20번째 줄

# 비주얼 모드 (선택)
v      문자 단위 선택
V      줄 단위 선택
Ctrl-v 블록 선택 (세로 편집)
# 선택 후: d(삭제), y(복사), >(들여쓰기)

# 분할 창
:split file2.kt    수평 분할
:vsplit file2.kt   수직 분할
Ctrl-w w           창 전환
:q                 현재 창 닫기
```

---

### tmux — 터미널 세션 관리

서버 접속, 장시간 작업, 멀티 창 분할에 필수. SSH 세션이 끊겨도 작업이 유지된다.

```bash
# 세션
tmux new -s work          # "work" 세션 생성
tmux ls                   # 세션 목록
tmux attach -t work       # 세션 재접속
tmux kill-session -t work # 세션 종료
```

```
# 세션 내 키 바인딩 (Ctrl-b 가 prefix)
Ctrl-b d       세션 detach (종료 아님, 백그라운드로)
Ctrl-b s       세션 목록 전환
Ctrl-b $       세션 이름 변경

# 창 (window)
Ctrl-b c       새 창 생성
Ctrl-b n / p   다음 / 이전 창
Ctrl-b 0-9     창 번호로 이동
Ctrl-b ,       창 이름 변경
Ctrl-b &       현재 창 닫기

# 분할 (pane)
Ctrl-b %       세로 분할
Ctrl-b "       가로 분할
Ctrl-b 화살표   pane 이동
Ctrl-b z       pane 최대화 / 복구 (zoom)
Ctrl-b x       현재 pane 닫기
Ctrl-b {/}     pane 위치 교환

# 스크롤 / 복사
Ctrl-b [       스크롤 모드 진입 (q 로 종료)
Space          복사 시작 (스크롤 모드 내)
Enter          복사 완료
Ctrl-b ]       붙여넣기
```

---

### ps / kill / watch — 프로세스 관리

```bash
# 실행 중인 프로세스 확인
ps aux                          # 전체 프로세스
ps aux | grep "order-api"     # 이름으로 필터
ps aux | grep java | grep -v grep

# 프로세스 트리
ps auxf         # 부모-자식 관계 포함 (Linux)
pstree -p       # 트리 형태 (Linux)

# CPU/메모리 상위 프로세스
ps aux --sort=-%cpu | head -10
ps aux --sort=-%mem | head -10

# 프로세스 종료
kill <PID>          # SIGTERM (정상 종료 요청)
kill -9 <PID>       # SIGKILL (강제 종료)
killall java        # 이름으로 일괄 종료
pkill -f "order-api"   # 패턴으로 종료

# 특정 포트 점유 프로세스 종료
kill $(lsof -t -i :9001)

# watch — 명령을 주기적으로 반복 실행
watch -n 2 'ps aux | grep java'         # 2초마다 갱신
watch -n 1 'curl -s localhost:9001/health | jq .'
watch -d 'ls -la logs/'                 # 변경된 부분 강조 (-d)
```

---

### htop — 인터랙티브 프로세스 모니터링

`ps` + `top`보다 직관적인 TUI 모니터링 도구.

```bash
htop                    # 전체 프로세스 보기
htop -p <PID>           # 특정 프로세스만
htop -u user      # 특정 유저 프로세스만
```

```
# htop 내부 키
F3 / /   프로세스 이름 검색
F4       필터 (키워드로 목록 좁히기)
F5       트리 뷰 전환
F6       정렬 기준 선택 (CPU, MEM 등)
F9       kill 시그널 전송
F10      종료
Space    프로세스 태그 (다중 선택)
u        유저 필터
```

---

### sort / uniq / wc / cut — 텍스트 데이터 처리

```bash
# sort — 정렬
sort file.txt                   # 알파벳 오름차순
sort -r file.txt                # 내림차순
sort -n file.txt                # 숫자 정렬
sort -k2 -n file.txt            # 2번째 필드 기준 숫자 정렬
sort -t',' -k3 -n data.csv      # CSV 3번째 컬럼 기준
sort -u file.txt                # 정렬 + 중복 제거

# uniq — 중복 처리 (정렬 후 사용)
sort file.txt | uniq            # 중복 제거
sort file.txt | uniq -c         # 중복 횟수 포함
sort file.txt | uniq -d         # 중복된 것만
sort file.txt | uniq -c | sort -rn | head -10  # 빈도 TOP10

# wc — 줄/단어/바이트 카운트
wc -l file.txt                  # 줄 수
wc -l *.kt                      # 파일별 줄 수
find . -name "*.kt" | wc -l     # 파일 개수
cat response.json | jq '.[]' | wc -l  # JSON 배열 길이

# cut — 필드 추출
cut -d',' -f1,3 data.csv        # CSV에서 1,3번째 컬럼
cut -d':' -f1 /etc/passwd       # 콜론 구분, 첫 번째 필드
cut -c1-10 file.txt             # 1~10번째 문자
ls -la | cut -c1-10             # 권한 부분만

# 조합 예시
# 로그에서 상태코드 빈도 분석
cat access.log | awk '{print $9}' | sort | uniq -c | sort -rn

# 커밋 작성자 빈도
git log --format="%an" | sort | uniq -c | sort -rn | head -10
```

---

### ssh / scp / rsync — 원격 접속 및 파일 전송

```bash
# SSH 접속
ssh user@host
ssh -p 2222 user@host           # 포트 지정
ssh -i ~/.ssh/key.pem user@host # 키 파일 지정
ssh -L 8080:localhost:9001 user@host  # 로컬 포트 포워딩

# SSH 터널 (포트 포워딩)
# 원격 서버의 9001 포트를 로컬 8080으로
ssh -L 8080:localhost:9001 user@remote-server
# DB 터널 (원격 DB를 로컬처럼 접근)
ssh -L 13306:db.internal:3306 user@bastion

# 원격 명령 실행 (접속 없이)
ssh user@host 'ps aux | grep java'
ssh user@host 'tail -100 /var/log/app/app.log'

# scp — 파일 복사
scp file.txt user@host:/remote/path/
scp user@host:/remote/file.txt ./local/
scp -r ./dir user@host:/remote/   # 디렉토리 재귀 복사
scp -P 2222 file.txt user@host:/path/  # 포트 지정

# rsync — 증분 동기화 (대용량 파일, 디렉토리 동기화)
rsync -avz ./src/ user@host:/remote/src/   # 원격 업로드
rsync -avz user@host:/remote/logs/ ./logs/ # 원격 다운로드
rsync -avz --delete ./src/ user@host:/remote/src/  # 원본과 완전 동기화
rsync -avz --exclude='*.log' --exclude='build/' ./  user@host:/app/
# -a: 권한/타임스탬프 보존, -v: verbose, -z: 압축

# SSH config (~/.ssh/config) — 자주 쓰는 서버 단축 설정
# Host bastion
#   HostName bastion.example.com
#   User ec2-user
#   IdentityFile ~/.ssh/prod-key.pem
# 사용: ssh bastion
```

---

### openssl / base64 — 인코딩 · 암호화

```bash
# Base64 인코딩 / 디코딩
echo -n "hello" | base64
echo "aGVsbG8=" | base64 --decode
# 파일
base64 -i image.png -o image.b64
base64 --decode -i image.b64 -o image.png

# URL-safe Base64 (+ → -, / → _)
echo -n "hello" | base64 | tr '+/' '-_' | tr -d '='

# JWT 디코딩 (서명 검증 없이 payload 확인)
TOKEN="eyJ..."
echo $TOKEN | cut -d'.' -f2 | base64 --decode 2>/dev/null | jq '.'

# HMAC-SHA256 서명
echo -n "message" | openssl dgst -sha256 -hmac "secret-key"

# SHA256 해시
echo -n "password" | openssl dgst -sha256
openssl dgst -sha256 file.txt

# 랜덤 키 생성
openssl rand -hex 32         # 64자 hex (256bit)
openssl rand -base64 32      # Base64 인코딩 랜덤 키

# 인증서 정보 확인
openssl s_client -connect api.example.com:443 -showcerts 2>/dev/null | \
  openssl x509 -noout -dates
echo | openssl s_client -connect api.example.com:443 2>/dev/null | \
  openssl x509 -noout -subject -issuer

# PEM 인증서 내용 확인
openssl x509 -in cert.pem -noout -text
```

---

### docker — 컨테이너 관리

```bash
# 컨테이너 상태
docker ps                        # 실행 중인 컨테이너
docker ps -a                     # 모든 컨테이너 (중지 포함)
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 컨테이너 조작
docker start/stop/restart <name>
docker rm <name>                 # 컨테이너 삭제
docker exec -it <name> bash      # 컨테이너 쉘 접속
docker exec -it <name> sh        # bash 없을 때

# 로그
docker logs <name>               # 전체 로그
docker logs -f <name>            # 실시간 로그 (follow)
docker logs --tail 100 <name>    # 마지막 100줄
docker logs --since 10m <name>   # 최근 10분

# 이미지 관리
docker images
docker pull mysql:8.0
docker rmi <image-id>
docker image prune               # 미사용 이미지 정리

# docker compose
docker compose up -d             # 백그라운드 실행
docker compose down              # 중지 + 컨테이너 삭제
docker compose down -v           # 볼륨까지 삭제 (데이터 초기화)
docker compose logs -f           # 전체 서비스 로그
docker compose logs -f mysql     # 특정 서비스 로그
docker compose ps                # 서비스 상태

# 리소스 사용량 모니터링
docker stats                     # 실시간 CPU/메모리
docker stats --no-stream         # 1회 스냅샷

# 컨테이너 내부 파일 복사
docker cp <name>:/path/to/file ./local/
docker cp ./local/file <name>:/path/to/

# 볼륨 / 네트워크
docker volume ls
docker network ls
docker inspect <name>            # 상세 정보 (IP 등)
```

---

### lazydocker — Docker TUI

설치: `brew install lazydocker`

```bash
lazydocker        # 실행
lazydocker -f docker-compose.yml  # 특정 compose 파일 지정
```

```
# 패널 이동
h/l 또는 ←/→   패널 전환 (Containers / Images / Volumes / Networks / Project)
j/k 또는 ↑/↓   항목 선택
Enter           항목 상세 / 하위 패널 진입
Tab             하단 탭 전환 (Logs / Stats / Config / Top 등)

# 컨테이너 조작
[ d ]   컨테이너 삭제
[ s ]   start / stop 토글
[ r ]   restart
[ a ]   attach (interactive shell)
[ e ]   exec — 명령 입력 후 실행
[ U ]   docker compose up (Project 패널)
[ D ]   docker compose down (Project 패널)

# 로그
[ m ]   로그 패널 포커스 / 스크롤 모드 진입
[ g ]   로그 처음으로
[ G ]   로그 끝으로
[ /  ]  로그 내 검색

# 기타
[ R ]   전체 새로고침
[ x ]   메뉴 (context menu)
[ q ]   종료
```

---

### mysql — 데이터베이스 클라이언트

```bash
# 접속
mysql -h 127.0.0.1 -P 3306 -u root -p
mysql -h 127.0.0.1 -P 3306 -u root -proot dbname  # 비밀번호 인라인

# 단일 쿼리 실행 (-e)
mysql -h 127.0.0.1 -u root -proot dbname \
  -e "SELECT * FROM order_order LIMIT 10;"

# SQL 파일 실행
mysql -h 127.0.0.1 -u root -proot dbname < schema.sql

# 결과를 파일로 저장
mysql -h 127.0.0.1 -u root -proot dbname \
  -e "SELECT * FROM order_order;" > result.tsv

# Docker 컨테이너 내 MySQL 바로 실행
docker exec -it mysql-container mysql -uroot -proot dbname
docker exec mysql-container mysql -uroot -proot dbname \
  -e "SELECT COUNT(*) FROM order_order;"

# 테이블 구조 확인
mysql> DESCRIBE order_order;
mysql> SHOW CREATE TABLE order_order\G
mysql> SHOW INDEX FROM order_order;

# 실행 중인 쿼리 확인
mysql> SHOW PROCESSLIST;
mysql> SHOW FULL PROCESSLIST;

# 슬로우 쿼리 분석
mysql> EXPLAIN SELECT * FROM order_order WHERE pg_tid = 'xxx';
mysql> EXPLAIN ANALYZE SELECT ...;  # MySQL 8.0+

# 유용한 옵션
mysql --table     # 표 형식 출력
mysql -s          # 조용한 모드 (헤더 제거)
mysql -N          # 컬럼명 제거 (순수 데이터만)
mysql --vertical  # 세로 출력 (\G 와 동일)
```

---

### redis-cli — Redis 캐시 점검

```bash
# 접속
redis-cli -h 127.0.0.1 -p 6379
redis-cli -h 127.0.0.1 -p 6379 -a password  # 인증 필요 시

# 단일 명령 실행
redis-cli -h 127.0.0.1 GET "session:user:123"
redis-cli -h 127.0.0.1 HGETALL "order:order:456"

# Docker 컨테이너 내 redis-cli
docker exec -it redis-container redis-cli
docker exec redis-container redis-cli GET "key:name"

# 키 탐색
redis-cli KEYS "*order*"       # 패턴 매칭 (운영 주의)
redis-cli SCAN 0 MATCH "*order*" COUNT 100  # 운영 환경 안전 버전
redis-cli SCAN 0 MATCH "*order*" COUNT 100 TYPE hash  # 타입 필터

# 키 정보
redis-cli TTL "session:user:123"     # 남은 만료 시간 (초), -1=영구, -2=없음
redis-cli TYPE "order:order:456"   # 타입 확인 (string/hash/list/set/zset)
redis-cli OBJECT ENCODING "key"      # 내부 인코딩

# 데이터 조회
redis-cli GET key                    # String
redis-cli HGETALL hash_key           # Hash 전체
redis-cli HGET hash_key field        # Hash 특정 필드
redis-cli LRANGE list_key 0 -1       # List 전체
redis-cli SMEMBERS set_key           # Set 전체
redis-cli ZRANGE zset_key 0 -1 WITHSCORES  # Sorted Set

# 서버 상태
redis-cli INFO                       # 전체 정보
redis-cli INFO memory                # 메모리 사용량
redis-cli INFO keyspace              # DB별 키 수
redis-cli DBSIZE                     # 현재 DB 키 수
redis-cli MONITOR                    # 실시간 커맨드 모니터링 (운영 주의)
```

---

### kafka — 메시지 확인 및 진단

Confluent/Apache Kafka 배포판 공통 패턴. 바이너리 위치는 환경마다 다를 수 있다.

```bash
# 토픽 목록
kafka-topics.sh --bootstrap-server localhost:9092 --list

# 토픽 상세 (파티션, 복제 등)
kafka-topics.sh --bootstrap-server localhost:9092 \
  --describe --topic order.order.created

# 컨슈머 그룹 목록
kafka-consumer-groups.sh --bootstrap-server localhost:9092 --list

# 컨슈머 그룹 lag 확인 (밀린 메시지 수)
kafka-consumer-groups.sh --bootstrap-server localhost:9092 \
  --describe --group order-consumer-group

# 메시지 읽기 (처음부터)
kafka-console-consumer.sh --bootstrap-server localhost:9092 \
  --topic order.order.created \
  --from-beginning \
  --max-messages 10

# 메시지 읽기 (최신부터)
kafka-console-consumer.sh --bootstrap-server localhost:9092 \
  --topic order.order.created

# 키 포함 읽기
kafka-console-consumer.sh --bootstrap-server localhost:9092 \
  --topic order.order.created \
  --property print.key=true \
  --property key.separator=":"

# 특정 파티션·오프셋부터 읽기
kafka-console-consumer.sh --bootstrap-server localhost:9092 \
  --topic order.order.created \
  --partition 0 --offset 100

# 메시지 발행
kafka-console-producer.sh --bootstrap-server localhost:9092 \
  --topic order.order.created
# 입력 후 엔터로 메시지 전송, Ctrl-C 종료

# 키-값 메시지 발행
kafka-console-producer.sh --bootstrap-server localhost:9092 \
  --topic order.order.created \
  --property parse.key=true \
  --property key.separator=":"
# key:{"orderId":"123","status":"CREATED"} 형식으로 입력

# Docker 환경에서 실행
docker exec -it kafka-container \
  kafka-console-consumer.sh --bootstrap-server localhost:9092 \
  --topic order.order.created --from-beginning --max-messages 5
```

---

### Gradle — 빌드 및 태스크 실행

```bash
# 빌드
./gradlew build                          # 전체 빌드 (테스트 포함)
./gradlew build -x test                  # 테스트 제외
./gradlew :order-api:build             # 특정 모듈만

# 실행 가능한 JAR 생성
./gradlew :order-api:bootJar
./gradlew :order-api:bootJar --exclude-task test

# 애플리케이션 실행
./gradlew :order-api:bootRun
./gradlew :order-api:bootRun --args='--spring.profiles.active=local'

# 테스트
./gradlew test                           # 전체 테스트
./gradlew :order-api:test              # 특정 모듈 테스트
./gradlew test --tests "*OrderServiceTest"  # 특정 클래스
./gradlew test --tests "*OrderServiceTest.cancelOrder"  # 특정 메서드
./gradlew test --info                    # 상세 출력

# 의존성 확인
./gradlew dependencies                   # 전체 의존성 트리
./gradlew :order-api:dependencies --configuration runtimeClasspath
./gradlew dependencyInsight --dependency spring-boot  # 특정 라이브러리 추적

# 태스크 목록 확인
./gradlew tasks                          # 주요 태스크
./gradlew tasks --all                    # 전체 태스크

# 캐시 초기화
./gradlew clean                          # build 디렉토리 삭제
./gradlew --stop                         # Gradle 데몬 종료
rm -rf ~/.gradle/caches                  # Gradle 전역 캐시 삭제

# 병렬 빌드 (멀티 모듈)
./gradlew build --parallel
./gradlew build --parallel --max-workers=4

# 빌드 성능 분석
./gradlew build --profile               # HTML 리포트 생성 (build/reports/profile/)
./gradlew build --scan                  # Gradle Build Scan (온라인 리포트)
```

---

### JVM 진단 — jstack / jmap / jcmd

JVM 기반 애플리케이션(Spring Boot 등) 운영 중 CPU 과부하, 메모리 누수, 데드락 진단.

```bash
# 프로세스 확인
jps -l                              # JVM 프로세스 목록 (PID + 클래스명)
jps -v                              # JVM 옵션 포함

# 스레드 덤프 (CPU 스파이크, 데드락 분석)
jstack <PID>                        # 표준 출력
jstack <PID> > thread-dump.txt      # 파일로 저장
jstack -l <PID>                     # 락 정보 포함

# 반복 스레드 덤프 (CPU 스파이크 추적)
for i in 1 2 3; do
  jstack <PID> > thread-dump-$i.txt
  sleep 5
done

# 힙 덤프 (OOM, 메모리 누수 분석)
jmap -dump:format=b,file=heap.hprof <PID>
jmap -dump:live,format=b,file=heap-live.hprof <PID>  # live 객체만

# 힙 사용 현황 (간략)
jmap -heap <PID>
jmap -histo <PID> | head -30        # 클래스별 인스턴스 수

# jcmd — 통합 진단 (Java 7+ 권장)
jcmd <PID> help                     # 사용 가능한 커맨드 목록
jcmd <PID> Thread.print             # 스레드 덤프
jcmd <PID> GC.heap_info             # 힙 사용량
jcmd <PID> GC.run                   # GC 강제 실행
jcmd <PID> VM.flags                 # JVM 플래그 확인
jcmd <PID> VM.system_properties     # 시스템 프로퍼티

# GC 로그 실시간 확인 (JVM 실행 시 옵션 필요)
# 실행 시: -Xlog:gc*:file=gc.log:time:filecount=5,filesize=20m
tail -f gc.log | grep -E "GC|Pause"
```

---

### tar / gzip / zip — 압축 및 아카이브

```bash
# tar — 아카이브 생성/해제
tar -czf archive.tar.gz ./dir/          # 압축 아카이브 생성 (gzip)
tar -cjf archive.tar.bz2 ./dir/        # 압축 아카이브 생성 (bzip2)
tar -czf logs-$(date +%Y%m%d).tar.gz ./logs/  # 날짜 포함 이름

tar -xzf archive.tar.gz                # 현재 디렉토리에 해제
tar -xzf archive.tar.gz -C /target/   # 특정 경로에 해제
tar -tzf archive.tar.gz                # 내용 목록 확인 (해제 없이)
tar -xzf archive.tar.gz ./dir/file.kt  # 특정 파일만 해제

# gzip / gunzip
gzip file.log                          # 압축 (원본 삭제)
gzip -k file.log                       # 압축 (원본 유지)
gzip -d file.log.gz                    # 압축 해제 (= gunzip)
gzip -l file.log.gz                    # 압축률 정보 확인

# 대용량 로그 압축하며 읽기 (해제 없이)
zcat file.log.gz | grep "ERROR"
zgrep "ERROR" file.log.gz
zless file.log.gz

# zip / unzip
zip -r archive.zip ./dir/              # 디렉토리 압축
zip archive.zip file1.kt file2.kt     # 파일 지정
unzip archive.zip                      # 현재 디렉토리에 해제
unzip archive.zip -d /target/         # 특정 경로에 해제
unzip -l archive.zip                   # 내용 목록 확인
```

---

### diff — 파일 비교

```bash
# 기본 비교
diff file1.txt file2.txt
diff -u file1.txt file2.txt            # unified 포맷 (git diff 스타일)
diff -y file1.txt file2.txt            # 나란히 비교
diff -i file1.txt file2.txt            # 대소문자 무시

# 디렉토리 비교
diff -r dir1/ dir2/
diff -rq dir1/ dir2/                   # 다른 파일 목록만

# 컬러 출력 (GNU diff)
diff --color=auto file1.txt file2.txt

# git 커밋 간 특정 파일 비교
diff <(git show HEAD~1:path/file.kt) <(git show HEAD:path/file.kt)

# 두 명령 출력 비교
diff <(ls dir1/) <(ls dir2/)
diff <(sort file1.txt) <(sort file2.txt)
```

---

### 로그 모니터링 — tail / less / grep

```bash
# tail — 실시간 로그 추적
tail -f app.log                       # 실시간 추적
tail -f app.log | grep "ERROR"        # 에러만 필터
tail -f app.log | grep -E "ERROR|WARN"
tail -100 app.log                     # 마지막 100줄
tail -f app.log | grep --line-buffered "OrderOrder"

# 여러 파일 동시 추적
tail -f service1.log service2.log
tail -f /var/log/*.log

# less — 대용량 파일 탐색 (vim 유사 키 바인딩)
less app.log
less +F app.log      # tail -f 처럼 실시간 모드로 시작
```

```
# less 내부 키
G          파일 끝으로
g          파일 처음으로
/pattern   아래 검색
?pattern   위 검색
n / N      다음 / 이전 매칭
F          실시간 모드 (Ctrl-C로 탈출)
q          종료
```

```bash
# grep — 로그 패턴 검색
grep "ERROR" app.log
grep -n "ERROR" app.log            # 줄 번호 포함
grep -A 5 -B 2 "Exception" app.log # 컨텍스트 포함
grep -c "ERROR" app.log            # 매칭 줄 수만
grep -v "health-check" app.log     # 제외 패턴
grep -E "ERROR|FATAL|Exception" app.log  # 정규식

# 날짜 범위로 필터
grep "2026-03-30 14:" app.log      # 특정 시간대
grep -E "2026-03-30 1[4-6]:" app.log  # 14~16시

# 특정 트랜잭션 ID 추적
grep "txId=abc123" app.log
grep -h "txId=abc123" logs/*.log   # 여러 파일, 파일명 제거
```

---

### 환경변수 / 쉘 생산성

```bash
# 환경변수 확인
env                            # 전체 환경변수
printenv PATH
echo $JAVA_HOME

# 변수 설정 / 해제
export MY_VAR=value
unset MY_VAR

# .env 파일 로드 (현재 쉘에 적용)
set -a && source dev.env && set +a
export $(grep -v '^#' dev.env | xargs)  # 주석 제외 로드

# 명령어 히스토리 검색
history | grep "gradlew"
Ctrl-R                        # 대화형 역방향 검색

# 마지막 명령어 관련
!!              # 직전 명령어 재실행
!$              # 직전 명령어의 마지막 인자
!^              # 직전 명령어의 첫 번째 인자
sudo !!         # 직전 명령어를 sudo로 재실행

# 명령어 위치 확인
which java
which -a java   # 모든 경로 출력
type gradle     # alias/function 여부도 표시

# 디스크 사용량
df -h           # 파일시스템별 사용량
du -sh ./build  # 특정 디렉토리 크기
du -sh */ | sort -rh | head -10  # 하위 디렉토리 크기 순위

# 날짜 / 타임스탬프
date                            # 현재 시간
date +"%Y-%m-%d %H:%M:%S"       # 포맷 지정
date -u +"%Y-%m-%dT%H:%M:%SZ"   # UTC ISO 8601
date +%s                        # Unix timestamp (초)
date -d "2026-03-30" +%s        # 특정 날짜 → timestamp (Linux)
```

---

### xargs — 파이프라인 확장

```bash
# 기본 사용법: stdin을 인자로 변환
echo "file1 file2 file3" | xargs ls -la
find . -name "*.log" | xargs rm

# -I {} — 위치 지정자 (입력값을 특정 위치에 삽입)
find . -name "*.kt" | xargs -I {} cp {} {}.bak
cat ids.txt | xargs -I {} curl -s https://api.example.com/orders/{}

# -P — 병렬 실행
find . -name "*.kt" | xargs -P 4 -I {} wc -l {}
cat endpoints.txt | xargs -P 8 -I {} curl -s -o /dev/null -w "%{http_code} {}\n" {}

# -n — 한 번에 처리할 인자 수
cat files.txt | xargs -n 1 process.sh   # 1개씩
echo "a b c d" | xargs -n 2 echo        # 2개씩

# 공백/특수문자 안전 처리 (-0, null delimiter)
find . -name "*.kt" -print0 | xargs -0 grep "TODO"

# 확인 후 실행 (-p)
find . -name "*.tmp" | xargs -p rm
```

---

### fzf — 퍼지 인터랙티브 검색

설치: `brew install fzf && $(brew --prefix)/opt/fzf/install`

```bash
# 파일 퍼지 검색 후 편집
vim $(fzf)
vim $(fzf --preview 'cat {}')  # 미리보기 포함

# 히스토리 인터랙티브 검색 (Ctrl-R 대체)
# fzf 설치 시 자동으로 Ctrl-R에 바인딩됨

# git branch 인터랙티브 체크아웃
git branch | fzf | xargs git checkout

# git log 인터랙티브 탐색
git log --oneline | fzf --preview 'git show --stat $(echo {} | cut -d" " -f1)'

# 실행 중인 프로세스 선택 후 kill
ps aux | fzf | awk '{print $2}' | xargs kill

# 환경변수 인터랙티브 검색
env | fzf

# 디렉토리 인터랙티브 이동
cd $(find . -type d | fzf)

# rg 결과에서 인터랙티브 선택
rg "TODO" --type kotlin -l | fzf | xargs vim

# docker 컨테이너 인터랙티브 선택 후 접속
docker ps --format "{{.Names}}" | fzf | xargs -I {} docker exec -it {} bash

# Kafka 토픽 인터랙티브 선택
kafka-topics.sh --bootstrap-server localhost:9092 --list | fzf
```

```
# fzf 내부 키 바인딩
Ctrl-J/K    위아래 이동
Tab         다중 선택 (--multi 옵션 필요)
Shift-Tab   선택 해제
Enter       확정
Esc / Ctrl-C  취소
Ctrl-/      미리보기 창 토글
```

---

### Shell 스크립팅 패턴

```bash
# ── 조건문 ──
if [ -f "dev.env" ]; then
  source dev.env
else
  echo "dev.env not found"
  exit 1
fi

# 문자열 비교
if [ "$ENV" = "prod" ]; then echo "production"; fi

# 숫자 비교
if [ $EXIT_CODE -ne 0 ]; then echo "failed"; fi

# 명령어 성공 여부
if ./gradlew build -x test; then
  echo "build ok"
fi

# 파일/디렉토리 존재 확인
[ -f file.txt ] && echo "file exists"
[ -d ./build ] || mkdir -p ./build

# ── 루프 ──
# 파일 목록 순회
for f in *.sql; do
  echo "Processing $f"
done

# 범위 반복
for i in {1..5}; do
  echo "attempt $i"
  sleep 1
done

# 배열 순회
ENVS=(dev stage prod)
for env in "${ENVS[@]}"; do
  echo "deploy to $env"
done

# while — 조건 반복
RETRY=0
while [ $RETRY -lt 3 ]; do
  curl -sf http://localhost:9001/health && break
  RETRY=$((RETRY + 1))
  sleep 2
done

# while — 파일 한 줄씩 읽기
while IFS= read -r line; do
  echo "Processing: $line"
done < ids.txt

# ── 함수 ──
wait_for_port() {
  local PORT=$1
  local MAX=${2:-30}
  for i in $(seq 1 $MAX); do
    nc -z localhost "$PORT" 2>/dev/null && return 0
    echo "Waiting for port $PORT... ($i/$MAX)"
    sleep 1
  done
  echo "Timeout waiting for port $PORT" && return 1
}

# 호출
wait_for_port 9001 60

# ── 변수 / 문자열 ──
NAME="order-api"
echo "${NAME}-v2"                 # 문자열 연결
echo "${NAME^^}"                  # 대문자 변환
echo "${NAME/api/service}"        # 치환

# 기본값 설정
PORT=${PORT:-9001}
ENV=${1:-local}                   # 첫 번째 인자, 없으면 local

# ── 에러 처리 ──
set -e          # 명령 실패 시 즉시 종료
set -u          # 미정의 변수 사용 시 오류
set -o pipefail # 파이프 중간 실패도 감지
# 스크립트 상단에 함께 쓰는 관용구:
set -euo pipefail

# 종료 시 정리 (trap)
cleanup() {
  echo "Cleaning up..."
  docker compose down 2>/dev/null
}
trap cleanup EXIT

# ── 스크립트 유용 패턴 ──
# 스크립트 위치 기준 상대 경로
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 명령어 존재 확인
command -v jq >/dev/null 2>&1 || { echo "jq required"; exit 1; }

# 인자 파싱
usage() { echo "Usage: $0 [-e env] [-p port]"; exit 1; }
while getopts "e:p:h" opt; do
  case $opt in
    e) ENV=$OPTARG ;;
    p) PORT=$OPTARG ;;
    h) usage ;;
    *) usage ;;
  esac
done
```

---

### macOS 전용 도구

```bash
# ── 클립보드 ──
# 터미널 출력을 클립보드로 복사
cat response.json | pbcopy
echo $TOKEN | pbcopy
git log --oneline -5 | pbcopy

# 클립보드 내용 출력
pbpaste
pbpaste | jq '.'                  # JSON 클립보드 파싱
pbpaste | grep "ERROR"

# 클립보드 → 파일
pbpaste > output.txt

# ── 파일/URL 열기 ──
open .                            # 현재 디렉토리를 Finder에서 열기
open ./build/reports/tests/       # HTML 리포트 브라우저로 열기
open -a "IntelliJ IDEA" .         # 특정 앱으로 열기
open https://github.com           # 브라우저로 URL 열기

# ── 시스템 정보 ──
sw_vers                           # macOS 버전
sw_vers -productVersion           # 버전 번호만 (예: 15.3.0)
sysctl -n hw.logicalcpu           # CPU 코어 수
sysctl -n hw.memsize | awk '{print $0/1024/1024/1024 " GB"}'  # 메모리

# ── caffeinate — 슬립 방지 ──
caffeinate -i ./gradlew build     # 빌드 중 슬립 방지
caffeinate -s -t 3600             # 1시간 슬립 방지 (서버 설정 등)

# ── 네트워크 ──
# macOS에서 포트 점유 확인 (ss 없음)
lsof -i :9001 -n -P | grep LISTEN

# ARP 테이블 (로컬 네트워크 장치)
arp -a

# 네트워크 인터페이스 IP 확인
ipconfig getifaddr en0            # Wi-Fi IP
ifconfig en0 | grep inet

# DNS 캐시 초기화
sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder

# ── 유틸리티 ──
# 파일 빠른 탐색 (Spotlight DB 사용, find보다 빠름)
mdfind -name "application-local.yml"
mdfind "kind:kotlin OrderService"

# 클립보드로 공개키 복사
cat ~/.ssh/id_rsa.pub | pbcopy

# 현재 프로세스 CPU/메모리 (Activity Monitor CLI)
top -l 1 -pid $(pgrep -f "order-api") -stats pid,cpu,mem
```

---

### column — 표 형식 정렬 출력

```bash
# ── 기본 사용 ──
# 탭 구분 데이터를 정렬된 표로 출력
column -t file.tsv

# 구분자 지정
column -t -s ',' data.csv
column -t -s ':' /etc/passwd

# mysql 결과를 깔끔한 표로 출력
mysql -h 127.0.0.1 -u root -proot dbname \
  -e "SELECT order_id, amount, status FROM order_order LIMIT 10" \
  | column -t -s $'\t'

# docker ps 출력 정렬
docker ps --format "{{.Names}}\t{{.Status}}\t{{.Ports}}" | column -t

# ── 파이프라인 조합 ──
# 환경변수 목록을 표로 정리
env | sort | column -t -s '='

# Kafka 컨슈머 그룹 lag 결과 정렬
kafka-consumer-groups.sh --bootstrap-server localhost:9092 \
  --describe --group order-consumer-group \
  | column -t

# SSH config 파싱
grep -E "^Host|HostName|User" ~/.ssh/config | paste - - - | column -t

# ── column (GNU/util-linux) vs macOS ──
# macOS 기본 column은 기능 제한. brew install util-linux 로 업그레이드 가능
# 또는 awk로 대체:
awk 'BEGIN{FS="\t"} {printf "%-20s %-15s %-10s\n", $1, $2, $3}' data.tsv
```

---

### kcat (kafkacat) — 유연한 Kafka CLI

설치: `brew install kcat`

```bash
# ── 기본 모드 ──
# -C: Consumer / -P: Producer / -L: Metadata 조회

# 토픽 메타데이터 확인 (브로커, 파티션, 리더)
kcat -b localhost:9092 -L
kcat -b localhost:9092 -L -t order.order.created   # 특정 토픽만

# ── Consumer ──
# 처음부터 읽기 (-o beginning)
kcat -b localhost:9092 -t order.order.created -C -o beginning

# 최신 메시지 N개만
kcat -b localhost:9092 -t order.order.created -C -o -5  # 마지막 5개
kcat -b localhost:9092 -t order.order.created -C -e     # EOF에서 종료

# JSON 파싱과 조합
kcat -b localhost:9092 -t order.order.created -C -o beginning -e \
  | jq 'select(.status == "FAILED")'

# 키 포함 출력
kcat -b localhost:9092 -t order.order.created -C \
  -f 'Key: %k\nValue: %s\nPartition: %p, Offset: %o\n---\n'

# 특정 파티션·오프셋 지정
kcat -b localhost:9092 -t order.order.created -C -p 0 -o 100

# 컨슈머 그룹 지정
kcat -b localhost:9092 -t order.order.created -C -G my-group

# ── Producer ──
# stdin에서 메시지 발행
echo '{"orderId":"123","status":"CREATED"}' | \
  kcat -b localhost:9092 -t order.order.created -P

# 키-값 메시지 발행 (-K 구분자)
echo 'order-123:{"orderId":"123","status":"CREATED"}' | \
  kcat -b localhost:9092 -t order.order.created -P -K ':'

# 파일에서 발행 (줄마다 메시지)
kcat -b localhost:9092 -t order.order.created -P < messages.json

# ── Avro + Schema Registry ──
# brew install libserdes 또는 Confluent 배포판 필요
kcat -b localhost:9092 -t order.order.created -C \
  -s avro \
  -r http://localhost:18081    # Schema Registry URL

# ── Docker 환경 ──
docker exec kafka-container kcat \
  -b localhost:9092 -t order.order.created -C -o -10 -e
```

---

### yq — YAML 처리

설치: `brew install yq`

```bash
# 값 읽기
yq '.spring.datasource.url' application.yml
yq '.server.port' application-local.yml

# 배열 순회
yq '.spring.profiles.include[]' application.yml

# 값 수정 (stdout)
yq '.server.port = 9002' application.yml

# 파일 직접 수정 (-i)
yq -i '.server.port = 9002' application.yml

# JSON → YAML 변환
yq -P '.' data.json

# YAML → JSON 변환
yq -o json '.' application.yml

# 여러 문서가 있는 YAML (--- 구분)
yq 'select(documentIndex == 0)' multi-doc.yml

# k8s manifest에서 이미지 추출
yq '.spec.containers[].image' deployment.yml
```

---

### miller (mlr) — CSV/TSV/JSON 파이프라인 처리

설치: `brew install miller`

```bash
# 테이블 형태로 보기
mlr --csv --opprint cat data.csv

# 필터
mlr --csv filter '$status == "FAILED"' data.csv
mlr --csv filter '$amount > 1000' orders.csv

# 정렬
mlr --csv sort-by -nr amount data.csv        # 금액 내림차순

# 통계
mlr --csv stats1 -a sum,count,mean -f amount data.csv

# 특정 컬럼만 출력
mlr --csv cut -f order_id,status,amount data.csv

# 컬럼 추가/변환
mlr --csv put '$total = $amount + $tax' data.csv

# 그룹별 집계
mlr --csv stats1 -a sum -f amount -g status data.csv

# 포맷 변환
mlr --csv --ojson cat data.csv               # CSV → JSON
mlr --json --ocsv cat data.json              # JSON → CSV
mlr --csv --otsv cat data.csv                # CSV → TSV
```

---

### tidy-viewer (tv) — CSV 컬러 테이블 출력

설치: `brew install tidy-viewer`

```bash
tv data.csv                    # 기본 출력
tv data.csv -n 50              # 50행만
tv data.csv -e                 # 모든 컬럼 출력 (잘림 없이)
tv data.csv -e | less -S       # 모든 컬럼 + 스크롤
```

---

### delta — git diff 뷰어

설치: `brew install delta`

```bash
# .gitconfig에 설정하면 git diff/log -p에서 자동 사용됨
# [core]
#   pager = delta
# [delta]
#   navigate = true
#   side-by-side = true
#   line-numbers = true

# 단독 사용
delta file1.txt file2.txt
diff -u old.kt new.kt | delta    # diff 출력을 delta로 파이프

# git diff에서 자동 적용 (설정 시)
git diff                          # syntax highlight + side-by-side
git log -p                        # 커밋별 diff도 동일 적용
git show HEAD                     # 특정 커밋 diff

# delta 내부 키 (navigate = true 설정 시)
# n / N    다음 / 이전 파일로 이동
# q        종료
```

---

### gping — ping 그래프 시각화

설치: `brew install gping`

```bash
gping google.com                  # 단일 호스트
gping google.com 8.8.8.8         # 여러 호스트 동시 비교
gping -b 30 api.example.com      # 버퍼 크기 (표시할 데이터 포인트)
gping -i 0.5 api.example.com     # 0.5초 간격
```

---

### doggo — 모던 DNS 클라이언트

설치: `brew install doggo`

```bash
doggo api.example.com                  # 기본 A 레코드
doggo api.example.com A                # 명시적 A 레코드
doggo api.example.com CNAME            # CNAME
doggo api.example.com MX               # 메일 서버
doggo api.example.com @8.8.8.8         # 특정 DNS 서버 지정
doggo api.example.com --json           # JSON 출력
```

---

### lazysql — DB TUI 클라이언트

설치: `brew install lazysql`

```bash
# 접속
lazysql mysql://root:root@127.0.0.1:3306/order
lazysql postgres://user:pass@localhost:5432/dbname

# alias 사용 (tools.zsh에 등록됨)
lzs
```

```
# 주요 키 바인딩
?          도움말
Tab        패널 전환 (테이블 목록 / 쿼리 / 결과)
e          쿼리 에디터 열기
Enter      테이블 선택 / 쿼리 실행
j/k        행 이동
h/l        컬럼 이동
q          종료
```

---

### k9s — Kubernetes TUI

설치: `brew install k9s`

```bash
k9s                               # 현재 context의 기본 네임스페이스
k9s -n order                    # 특정 네임스페이스
k9s --context prod                # 특정 context
```

```
# 주요 키 바인딩
:pod       Pod 목록
:svc       Service 목록
:deploy    Deployment 목록
:ns        네임스페이스 전환
/pattern   필터링
l          로그 보기
s          셸 접속
d          describe
y          YAML 보기
Ctrl-d     삭제
?          도움말
:q         종료
```

---

## 파이프라인 조합 패턴

```bash
# Kotlin 파일에서 특정 패턴 찾고 파일명만 뽑아 정렬
rg "implements|extends" --type kotlin -l | sort

# git log에서 특정 키워드 커밋만 필터
git log --oneline | grep -i "cancel\|refund" | head -20

# JSON 배열에서 특정 조건 필터 후 특정 필드만 추출
cat response.json | jq -r '.[] | select(.amount > 1000) | .orderId'

# SQL 파일 버전 순서 확인
find . -name "V*.sql" | sort | awk -F'__' '{print $1, $2}'

# 여러 파일에서 패턴 찾고 컨텍스트 포함 출력
find . -name "*.kt" | xargs rg "@Transactional" -l

# API 응답에서 에러만 필터링
curl -s https://api.example.com/logs | jq '[.[] | select(.level == "ERROR")]'

# 빌드 로그에서 에러 라인만 추출
./gradlew build 2>&1 | grep -E "error:|ERROR|FAILED"

# 환경변수 로드 후 명령 실행
set -a && source dev.env && set +a && ./gradlew :order-api:bootJar

# Kafka 메시지 실시간 필터링
kafka-console-consumer.sh --bootstrap-server localhost:9092 \
  --topic order.order.created | jq 'select(.status == "FAILED")'

# 특정 기간 로그에서 에러 빈도 분석
grep "ERROR" app.log | awk '{print $1, $2}' | cut -c1-13 | sort | uniq -c

# Redis 특정 패턴 키 전체 삭제 (개발 환경 전용)
redis-cli KEYS "session:*" | xargs redis-cli DEL

# DB에서 결과를 JSON으로 가공
mysql -h 127.0.0.1 -u root -proot dbname -N -s \
  -e "SELECT order_id, amount FROM order_order LIMIT 5" | \
  awk '{print "{\"orderId\":\""$1"\",\"amount\":"$2"}"}'
```

---

### head — 앞부분 출력

```bash
# 파일 앞 N줄 출력
head -20 app.log                      # 앞 20줄
head -1 data.csv                      # 헤더(첫 줄)만 확인

# 바이트 단위
head -c 1024 large-file.bin           # 앞 1KB만

# 파이프라인에서 결과 제한
find . -name "*.kt" | head -10        # 상위 10개만
rg "TODO" --type kotlin -l | head -5

# tail과 조합 — 범위 추출 (50~60번째 줄)
head -60 file.txt | tail -10

# 여러 파일
head -5 *.sql                         # 각 파일의 앞 5줄 (파일명 구분 포함)
```

---

### set / source — 쉘 환경 제어

```bash
# ── set — 쉘 옵션 설정 ──
set -e          # 명령 실패 시 즉시 종료
set -u          # 미정의 변수 사용 시 오류
set -o pipefail # 파이프 중간 실패도 감지
set -euo pipefail  # 스크립트 상단 관용구 (위 세 개 합침)

# set -a — export 자동화 (.env 로드 패턴)
set -a          # 이후 정의되는 모든 변수를 자동 export
source dev.env  # 파일 안의 변수들이 환경변수로 등록됨
set +a          # 자동 export 해제

# set -x — 디버깅 (실행되는 명령 출력)
set -x
./gradlew build   # 실행 과정이 터미널에 출력됨
set +x

# ── source (= .) — 현재 쉘에서 파일 실행 ──
# 서브쉘이 아닌 현재 쉘에서 실행하므로 변수/함수가 현재 쉘에 반영됨
source ~/.zshrc              # 설정 다시 로드
source dev.env               # 환경변수 로드
. ~/.zshrc                   # source와 동일 (POSIX 호환 표기)

# source vs 그냥 실행의 차이
source script.sh   # 현재 쉘에서 실행 → 변수가 현재 쉘에 남음
./script.sh        # 서브쉘에서 실행 → 변수가 사라짐
```

---

### aws — AWS CLI

```bash
# ── 인증 / 프로파일 ──
aws sts get-caller-identity                    # 현재 인증 정보 확인
aws sts get-caller-identity --profile prod     # 특정 프로파일

# 프로파일 전환
export AWS_PROFILE=prod
aws configure list                             # 현재 설정 확인

# ── S3 ──
aws s3 ls                                      # 버킷 목록
aws s3 ls s3://bucket-name/prefix/             # 디렉토리 탐색
aws s3 cp s3://bucket/file.csv ./              # 다운로드
aws s3 cp ./file.csv s3://bucket/              # 업로드
aws s3 sync ./local/ s3://bucket/remote/       # 디렉토리 동기화

# ── CloudWatch Logs ──
# 로그 그룹 목록
aws logs describe-log-groups --query 'logGroups[].logGroupName' --output text

# 최근 로그 스트림 확인
aws logs describe-log-streams \
  --log-group-name /ecs/order-api \
  --order-by LastEventTime --descending --limit 5

# 로그 조회 (최근 10분)
aws logs filter-log-events \
  --log-group-name /ecs/order-api \
  --start-time $(date -v-10M +%s000) \
  --filter-pattern "ERROR" \
  --query 'events[].message' --output text

# ── ECS ──
aws ecs list-clusters --query 'clusterArns[]' --output text
aws ecs list-services --cluster my-cluster --query 'serviceArns[]' --output text
aws ecs describe-services --cluster my-cluster --services order-api \
  --query 'services[].{status:status,desired:desiredCount,running:runningCount}'

# ── RDS ──
aws rds describe-db-instances \
  --query 'DBInstances[].{id:DBInstanceIdentifier,status:DBInstanceStatus,endpoint:Endpoint.Address}'

# ── SSM Parameter Store ──
aws ssm get-parameter --name /prod/order/db-password --with-decryption
aws ssm get-parameters-by-path --path /prod/order/ --with-decryption

# ── 공통 옵션 ──
--output json|text|table        # 출력 형식
--query 'expr'                  # JMESPath 필터 (jq 대신 서버사이드 필터링)
--region ap-northeast-2         # 리전 지정
--profile prod                  # 프로파일 지정
```

---

## 코드베이스 탐색 전략

낯선 코드베이스를 파악할 때의 순서:

```bash
# 1. 프로젝트 구조 파악
find . -name "build.gradle.kts" | head -20   # 모듈 목록
find . -name "*.kt" -path "*/domain/*" | head -30  # 도메인 레이어

# 2. 진입점 탐색
rg "fun main\|@SpringBootApplication" --type kotlin -l

# 3. 핵심 개념어 추적
rg "OrderOrder" --type kotlin -l | sort

# 4. 인터페이스/포트 파악
rg "interface.*Port\|interface.*Repository" --type kotlin

# 5. 의존성 방향 확인
rg "import.*infrastructure\|import.*adapter" --type kotlin -l
```

---

## 주의사항

- **결과 제한**: 대용량 결과는 `head -N`으로 먼저 샘플링
- **파이프 우선**: 중간 파일 없이 파이프로 바로 연결
- **오류 포함**: `2>&1`로 stderr도 함께 캡처해 에러 파악
- **운영 환경 주의**: `KEYS *`, `MONITOR`, `FLUSHDB` 등 Redis/MySQL 전체 스캔 명령은 운영 서버에서 사용 금지
- **병렬 처리**: `xargs -P`, `&`(백그라운드) 남용 시 리소스 고갈 주의
