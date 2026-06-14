# CLI 도구 & 패턴 가이드

이 머신의 도구 카탈로그 + 백엔드 엔지니어가 자주 쓰는 패턴 모음.
Brewfile로 설치되는 것 + 이 dotfiles의 alias/설정 + Unix 기본 명령어 + 파이프라인 패턴.

## 목차
- [텍스트 / JSON / 검색](#텍스트--json--검색)
- [Git / GitHub](#git--github)
- [터미널 생산성](#터미널-생산성)
- [셸 / 스크립트](#셸--스크립트)
- [언어 런타임](#언어-런타임)
- [네트워크 / HTTP](#네트워크--http)
- [암호화 / 보안](#암호화--보안)
- [DB](#db)
- [Kafka](#kafka)
- [컨테이너 / Kubernetes](#컨테이너--kubernetes)
- [AWS / 클라우드](#aws--클라우드)
- [에디터](#에디터)
- [AI 도구](#ai-도구)
- [터미널 앱 / 프롬프트 / 폰트](#터미널-앱--프롬프트--폰트)
- [GUI 앱 (macOS)](#gui-앱-macos)
- [Unix 기본 명령어](#unix-기본-명령어)
- [macOS 전용 도구](#macos-전용-도구)
- [코드베이스 탐색 전략](#코드베이스-탐색-전략)
- [파이프라인 치트시트](#파이프라인-치트시트)
- [이 dotfiles가 설정한 alias / 환경](#이-dotfiles가-설정한-alias--환경)
- [주의사항](#주의사항)
- [더 공부할 곳](#더-공부할-곳)

---

## 텍스트 / JSON / 검색

### ripgrep (`rg`)
grep의 빠른 대체. `.gitignore` 자동 반영.
```bash
rg "TODO" .                                   # 현재 디렉토리 재귀 검색
rg -i "foo" --type rust                        # 대소문자 무시 + 언어 필터
rg -A3 -B2 "pattern"                           # 주변 라인 포함
rg --files | rg test                           # 파일명만 검색
rg "OrderService" --type kotlin -l             # 매칭 파일 목록만
rg "fun cancel" -A 10 -B 2 --type kotlin       # 함수 앞뒤 컨텍스트
rg "class\s+\w+Repository" --type kotlin       # 정규식
rg "TODO" --type kotlin --glob "!**/test/**"   # 디렉토리 제외
rg -w "cancel" --type kotlin                   # 단어 단위 매칭
```

### jq
JSON 쿼리/조작.
```bash
echo '{"a":1}' | jq '.a'
curl -s https://api.github.com/repos/torvalds/linux | jq '.stargazers_count'
jq '.[] | select(.age > 30) | .name' data.json
jq -s 'add' a.json b.json                      # 여러 파일 합치기

# 자주 쓰는 패턴
jq '.items[].orderId' response.json            # 배열에서 필드만
jq '.[] | select(.status == "FAILED")' results.json
jq '.order.pgResponse.resultCode' response.json   # 중첩 탐색
jq '.[] | {id: .orderId, amount: .totalAmount}' orders.json   # 재구성
jq '.items | length' response.json
jq '[.[] | select(.cancelledAt != null)]' orders.json   # null 제거
jq 'keys' response.json                        # 구조 파악
jq -r '.[] | .name' users.json                 # raw 출력
```

### yq
jq의 YAML 버전. JSON도 지원.
```bash
yq '.spring.datasource.url' application.yml
yq '.server.port' application-local.yml
yq '.spring.profiles.include[]' application.yml
yq -i '.server.port = 9002' application.yml    # 인플레이스
yq -P '.' data.json                            # JSON → YAML
yq -o json '.' application.yml                 # YAML → JSON
yq 'select(documentIndex == 0)' multi-doc.yml  # 멀티 도큐먼트
yq '.spec.containers[].image' deployment.yml   # k8s manifest
```

### fzf
퍼지 인터랙티브 검색.
```bash
# 파이프 사용
git log --oneline | fzf
vim $(fzf --preview 'cat {}')

# 키바인딩 (zsh)
# Ctrl-T: 현재 디렉토리 파일 검색 (atuin이 Ctrl-R 점유)
# Alt-C: 디렉토리로 cd

# 자주 쓰는 조합
git branch | fzf | xargs git checkout
git log --oneline | fzf --preview 'git show --stat $(echo {} | cut -d" " -f1)'
ps aux | fzf | awk '{print $2}' | xargs kill
docker ps --format "{{.Names}}" | fzf | xargs -I {} docker exec -it {} bash
rg "TODO" --type kotlin -l | fzf | xargs vim
```

내부 키: `Ctrl-J/K` 이동, `Tab` 다중 선택(`--multi`), `Enter` 확정, `Ctrl-/` 미리보기 토글.

### fd
find 대체. 직관적 문법, gitignore 인식.
```bash
fd "README"                                    # 이름에 README 포함
fd -e py                                       # 확장자 .py
fd -H ".env"                                   # hidden 포함
fd -x rm {}                                    # 매치된 파일에 명령 실행
fd -t f -S +100M                               # 100MB 이상 파일
```

### bat
cat 대체. 문법 하이라이트 + git 표시 + paging.
```bash
bat README.md
bat -l json response.txt                       # 언어 강제
# 이 dotfiles에서 alias cat='bat --paging=never'
```

### miller (`mlr`)
CSV/TSV/JSON 파이프라인.
```bash
mlr --csv --opprint cat data.csv               # 표 형태
mlr --csv filter '$age > 30' people.csv
mlr --csv sort-by -nr amount data.csv          # 금액 내림차순
mlr --csv stats1 -a sum,count,mean -f amount data.csv
mlr --csv cut -f order_id,status,amount data.csv
mlr --csv put '$total = $amount + $tax' data.csv
mlr --csv stats1 -a sum -f amount -g status data.csv   # 그룹별
mlr --c2j cat data.csv                         # CSV → JSON
mlr --json --ocsv cat data.json                # JSON → CSV
```

### tidy-viewer (`tv`)
CSV 컬러 표.
```bash
tv data.csv
tv -n 20 data.csv                              # 상위 20행
tv -e data.csv                                 # 모든 컬럼 (잘림 없이)
tv -e data.csv | less -S                       # 모든 컬럼 + 스크롤
```

### difftastic (`difft`)
AST 기반 구조적 diff. 줄 단위가 아닌 구문 단위.
```bash
git dft HEAD~3                                 # 이 dotfiles의 alias
git dlog
git dshow COMMIT
difft old.py new.py
```

### column (util-linux)
표 형식 정렬. macOS 기본 column은 기능 제한적이라 Linux판 설치.
```bash
mount | column -t
cat /etc/passwd | column -t -s ':'
column -t -s ',' data.csv
docker ps --format "{{.Names}}\t{{.Status}}\t{{.Ports}}" | column -t
env | sort | column -t -s '='
```

### watch
명령을 N초마다 반복 실행.
```bash
watch -n 2 df -h
watch -d 'kubectl get pods'                    # -d: 차이 강조
watch -n 1 'curl -s localhost:9001/health | jq .'
```

---

## Git / GitHub

### git
```bash
# 기본 흐름
git log --oneline -n 20
git log --graph --all
git diff HEAD~1
git stash / git stash pop
git bisect start

# 변경 이력 추적
git log --oneline -- path/to/file              # 특정 파일 이력
git diff --stat HEAD~1                         # 변경된 파일 목록
git log -S "cancelOrder" --oneline             # 특정 문자열 추가/삭제 커밋
git diff main..feature/x -- src/Foo.kt         # 브랜치 간 비교
git grep "TossPayClient" -- "*.kt"             # 코드베이스 패턴 검색
git show HEAD~3:path/to/file.kt                # 과거 커밋 시점 파일 내용
```

이 dotfiles의 alias:
- `git dft` — difftastic 구조적 diff
- `git dlog` — difftastic log
- `git dshow COMMIT` — difftastic show
- pager: `delta` (side-by-side, syntax highlight)

### gh (GitHub CLI)
```bash
# PR
gh pr list / gh pr view 123 / gh pr view --web
gh pr create --title "feat: ..." --body "..." --base main
gh pr checkout 123
gh pr status / gh pr checks 123
gh pr merge 123 --squash

# 이슈 / 릴리즈 / 워크플로우
gh issue list --assignee @me
gh issue create --title "Bug: ..." --label bug
gh release create v1.2.3 --notes "..."
gh workflow run deploy.yml --field env=prod

# API 직접 호출
gh api repos/{owner}/{repo}/pulls --jq '.[].title'
gh api -X POST repos/{owner}/{repo}/issues --field title="..." --field body="..."
```

### lazygit
Git TUI. 설정 없이 바로 사용. alias: `lg`.
- `?` 도움말, `c` 커밋, `a` stage all, `P` push, `p` pull

### delta
git diff 하이라이터. 이 dotfiles에서 pager로 자동 설정됨.
```ini
# ~/.gitconfig
[core]
    pager = delta
[delta]
    navigate = true
    side-by-side = true
    line-numbers = true
```
- `n` / `N`: 다음/이전 파일 (navigate=true 시)

---

## 터미널 생산성

### tmux
서버 접속, 장시간 작업, 멀티 창 분할에 필수. SSH 끊겨도 작업이 유지됨.
```bash
tmux new -s work                               # 세션 생성
tmux ls                                        # 세션 목록
tmux attach -t work                            # 재접속
tmux kill-session -t work
```

세션 내 키 바인딩 (prefix = `Ctrl-b`):
```
세션:    d detach,  s 세션 목록,  $ 이름 변경
창:      c 새 창,  n/p 이전/다음,  0-9 번호 이동,  , 이름 변경,  & 닫기
분할:    % 세로,  " 가로,  화살표 이동,  z zoom,  x 닫기,  {/} 위치 교환
스크롤:  [ 스크롤 모드 (q 종료),  Space 복사 시작,  Enter 복사 완료,  ] 붙여넣기
```

### btop / htop
인터랙티브 시스템 모니터.
```bash
btop                                            # 컬러풀 (htop 상위호환)
# m: CPU view, d: disk view, n: network view, q: quit

htop                                            # 클래식
htop -p <PID>                                   # 특정 프로세스
htop -u $(whoami)
# F3 검색, F4 필터, F5 트리, F6 정렬, F9 kill, F10 종료, Space 태그
```

### eza
ls 대체 (컬러, 아이콘, git 상태).
```bash
eza
eza -lah --git
eza --tree --level=2
```
이 dotfiles alias:
- `ls='eza --icons'`
- `ll='eza -lah --icons --git'`
- `lt='eza --tree --level=2 --icons'`

### zoxide
`cd` 대체 (학습된 자주 가는 디렉토리로 점프).
```bash
cd proj                                         # → ~/Workspace/proj 점프
cd -                                            # 이전 위치
z foo bar                                       # foo와 bar 모두 포함된 경로
zi                                              # 인터랙티브 선택
```

### atuin
히스토리 DB + 검색. `Ctrl-R`로 검색창.
```bash
atuin search "git push"
atuin stats
```

### gum
TUI 컴포넌트를 스크립트 안에 삽입.
```bash
CHOICE=$(gum choose "A" "B" "C")
gum confirm "진행?" && echo "ok"
gum spin --title "빌드 중..." -- sleep 3
gum input --placeholder "이름"
```

### just
Make 대체, `justfile` 문법이 단순.
```bash
# justfile
test:
    cargo test

deploy env:
    ./scripts/deploy.sh {{env}}

# 사용
just --list
just test
just deploy prod
```

### shellcheck
bash 스크립트 정적 분석.
```bash
shellcheck script.sh
shellcheck -x script.sh                        # source 파일까지 검사
```

### shfmt
bash 스크립트 포맷터.
```bash
shfmt -d script.sh                             # diff
shfmt -w -i 2 script.sh                        # 2칸 들여쓰기로 덮어쓰기
```

---

## 셸 / 스크립트

### zsh / oh-my-zsh
기본 셸. `~/.zshrc`로 설정, `~/.zshrc.d/*.zsh`로 모듈화. 플러그인 프레임워크 oh-my-zsh는 `plugins=(git)` 최소 구성.

### zsh-autosuggestions / zsh-syntax-highlighting
- 입력한 명령 뒤에 과거 히스토리 기반 자동완성 제안 (`→` 키로 수락)
- 입력 중 명령어 구문 실시간 하이라이트 (없는 명령은 빨강)

### starship
크로스쉘 프롬프트. 설정: `~/.config/starship.toml`.

### chezmoi
dotfiles 관리.
```bash
chezmoi apply                                   # 홈에 반영
chezmoi diff                                    # 적용 전 미리보기
chezmoi status
chezmoi edit ~/.zshrc                           # 소스 파일 편집
chezmoi add ~/.config/foo                       # 관리 편입
chezmoi cd                                      # 소스 디렉토리 이동
chezmoi update                                  # git pull + apply
chezmoi re-add ~/.zshrc                         # 홈 변경을 소스에 역반영
```

### I/O Redirection
```bash
# 기본
command > out.txt           # stdout 덮어쓰기
command >> out.txt          # stdout 추가
command 2> err.log          # stderr만
command > out 2>&1          # 둘 다 같은 파일
command &> out              # bash 단축형
command 2>/dev/null         # stderr 버리기
command > /dev/null 2>&1    # 둘 다 버리기
mysql -u u -p db < schema.sql   # stdin from file

# Here-doc
cat <<EOF
line1
line2
EOF

cat > config.yaml <<EOF
server:
  port: 9001
EOF

# Here-string
jq '.' <<< '{"key": "value"}'
grep "pattern" <<< "$VAR"

# tee — stdout 유지하며 파일에도
./gradlew build 2>&1 | tee build.log

# Process substitution — 출력을 파일처럼
diff <(git show HEAD:file.kt) <(cat file.kt)
diff <(sort a.txt) <(sort b.txt)
```

### set / source
```bash
# set 옵션
set -e                                          # 명령 실패 시 즉시 종료
set -u                                          # 미정의 변수 사용 시 오류
set -o pipefail                                 # 파이프 중간 실패 감지
set -euo pipefail                               # 스크립트 상단 관용구

# .env 파일 로드 패턴
set -a && source dev.env && set +a
# (또는)
export $(grep -v '^#' dev.env | xargs)

# set -x — 디버깅 (실행되는 명령 출력)
set -x; ./gradlew build; set +x

# source — 현재 쉘에서 실행
source ~/.zshrc                                 # 변수/함수가 현재 쉘에 반영
. ~/.zshrc                                      # POSIX 호환 표기

# source vs 그냥 실행
source script.sh   # 변수가 현재 쉘에 남음
./script.sh        # 서브쉘 → 변수 사라짐
```

### Shell 스크립팅 패턴
```bash
# 조건문
if [ -f "dev.env" ]; then
  source dev.env
else
  echo "dev.env not found" && exit 1
fi
[ -f file.txt ] && echo "exists"
[ -d ./build ] || mkdir -p ./build

# 루프
for f in *.sql; do echo "Processing $f"; done
for i in {1..5}; do echo "attempt $i"; sleep 1; done
ENVS=(dev stage prod); for e in "${ENVS[@]}"; do echo $e; done

# while + 재시도
RETRY=0
while [ $RETRY -lt 3 ]; do
  curl -sf http://localhost:9001/health && break
  RETRY=$((RETRY + 1)); sleep 2
done

# while로 파일 한 줄씩
while IFS= read -r line; do echo "$line"; done < ids.txt

# 함수
wait_for_port() {
  local PORT=$1 MAX=${2:-30}
  for i in $(seq 1 $MAX); do
    nc -z localhost "$PORT" 2>/dev/null && return 0
    sleep 1
  done
  return 1
}

# 문자열 처리
NAME="order-api"
echo "${NAME}-v2"            # 연결
echo "${NAME^^}"             # 대문자
echo "${NAME/api/service}"   # 치환
PORT=${PORT:-9001}           # 기본값
ENV=${1:-local}              # 첫 인자, 없으면 local

# 종료 시 정리
cleanup() { docker compose down 2>/dev/null; }
trap cleanup EXIT

# 스크립트 위치 기준 상대 경로
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 명령어 존재 확인
command -v jq >/dev/null 2>&1 || { echo "jq required"; exit 1; }

# getopts 인자 파싱
usage() { echo "Usage: $0 [-e env] [-p port]"; exit 1; }
while getopts "e:p:h" opt; do
  case $opt in
    e) ENV=$OPTARG ;;
    p) PORT=$OPTARG ;;
    *) usage ;;
  esac
done
```

---

## 언어 런타임

> 런타임은 전역으로 통일하지 않고 프로젝트별로 관리한다 (이 dotfiles는 버전 매니저를 두지 않음).

### uv
Python pkg/venv 매니저 (pip+poetry+pyenv 통합, 초고속).
```bash
uv venv .venv && source .venv/bin/activate
uv init                                         # pyproject.toml
uv add requests fastapi
uv run python main.py                           # venv 자동 활성
uv pip install -r req.txt                       # pip 호환
```

### gradle
JVM 빌드 도구.
```bash
# 빌드
./gradlew build                                 # 전체
./gradlew build -x test                         # 테스트 제외
./gradlew :order-api:build                      # 특정 모듈

# 실행 / JAR
./gradlew :order-api:bootJar
./gradlew :order-api:bootRun --args='--spring.profiles.active=local'

# 테스트
./gradlew test
./gradlew test --tests "*OrderServiceTest"
./gradlew test --tests "*OrderServiceTest.cancelOrder"
./gradlew test --info

# 의존성
./gradlew dependencies
./gradlew :order-api:dependencies --configuration runtimeClasspath
./gradlew dependencyInsight --dependency spring-boot

# 캐시 / 데몬
./gradlew clean
./gradlew --stop
rm -rf ~/.gradle/caches

# 최적화 / 분석
./gradlew build --parallel --max-workers=4
./gradlew build --profile                       # HTML 리포트
./gradlew build --scan                          # 온라인 리포트

# wrapper
./gradlew wrapper --gradle-version=8.5
```

### Kotlin
런타임은 이 dotfiles에서 설치하지 않음 — Gradle toolchain 또는 프로젝트별 설치 사용.
```bash
kotlinc -version
kotlin script.kts                               # 스크립트 실행
echo 'fun main() { println("hi") }' | kotlinc -script -
```

### ktlint
Kotlin 린터 + 포맷터.
```bash
ktlint                                          # 현재 dir 검사
ktlint -F                                       # 자동 수정
ktlint "src/**/*.kt"
ktlint --editorconfig=.editorconfig
```

### detekt
Kotlin 정적 분석.
```bash
detekt --input src/
detekt --generate-config
detekt -c detekt.yml --baseline baseline.xml
```

### JVM 진단 — jstack / jmap / jcmd
운영 중 CPU 과부하, 메모리 누수, 데드락 진단.
```bash
# 프로세스 확인
jps -l                                          # PID + 클래스명
jps -v                                          # JVM 옵션 포함

# 스레드 덤프 (CPU 스파이크, 데드락)
jstack <PID>
jstack -l <PID> > thread-dump.txt               # 락 정보 포함

# 반복 스레드 덤프 (CPU 스파이크 추적)
for i in 1 2 3; do
  jstack <PID> > thread-dump-$i.txt
  sleep 5
done

# 힙 덤프 (OOM, 메모리 누수)
jmap -dump:format=b,file=heap.hprof <PID>
jmap -dump:live,format=b,file=heap-live.hprof <PID>
jmap -heap <PID>                                # 힙 사용 현황
jmap -histo <PID> | head -30                    # 클래스별 인스턴스 수

# jcmd — 통합 진단 (Java 7+ 권장)
jcmd <PID> help
jcmd <PID> Thread.print
jcmd <PID> GC.heap_info
jcmd <PID> GC.run                               # GC 강제 실행
jcmd <PID> VM.flags
jcmd <PID> VM.system_properties

# GC 로그 (-Xlog:gc*:file=gc.log:time:filecount=5,filesize=20m 옵션 필요)
tail -f gc.log | grep -E "GC|Pause"
```

---

## 네트워크 / HTTP

### HTTP 클라이언트

#### curl (built-in)
```bash
curl -fsSL https://example.com                  # fail-silent-show-errors-location
curl -I https://example.com                     # 헤더만
curl -sI https://example.com | grep -i status

# POST / PUT JSON
curl -s -X POST https://api.example.com/pay \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"amount": 1000}'
curl -s -X POST https://api.example.com/pay -d @request.json

# 옵션
curl -u user:pass https://...                   # basic auth
curl -o file.tgz https://...                    # 저장
curl -sL https://short.url/abc                  # 리다이렉트
curl -s -o /dev/null -w "%{http_code}" https://api/health
curl --connect-timeout 5 --max-time 10 https://api/orders
curl --resolve host:443:1.2.3.4 ...             # DNS 오버라이드
```

#### wget
```bash
wget https://example.com/file.tgz
wget -c URL                                     # 이어받기
wget -r -l2 URL                                 # 재귀 2단계
wget --mirror --no-parent URL                   # 사이트 미러링
```

#### 추천 (Brewfile 미포함)
- **`httpie` (`http`)** — 인간친화적 JSON 중심. `http POST api/x name=John`
- **`xh`** — httpie 호환 + Rust로 빠름
- **`curlie`** — curl 문법 + httpie UX 하이브리드

### DNS

#### doggo (Brewfile)
```bash
doggo github.com                                # A 레코드
doggo MX gmail.com
doggo TXT _dmarc.example.com
doggo A example.com @1.1.1.1                    # 특정 resolver
doggo --json github.com
doggo --short github.com
```

#### dig / host / nslookup (built-in)
```bash
dig github.com / dig +short github.com
dig +trace github.com                           # 루트부터 추적
dig @8.8.8.8 github.com MX
dig -x 8.8.8.8                                  # 역방향
host github.com
nslookup github.com 1.1.1.1
```

#### scutil (macOS)
```bash
scutil --dns                                    # resolver configuration
scutil --nwi                                    # 네트워크 인터페이스 순위
```

### 경로 / 지연

#### gping (Brewfile)
```bash
gping google.com cloudflare.com github.com      # 동시 비교
gping -c 10 host
gping -i 0.5 api.example.com                    # 0.5초 간격
```

#### ping / traceroute (built-in)
```bash
ping -c 4 github.com
ping -i 0.2 host
traceroute github.com
sudo traceroute -I host                         # ICMP 사용
```

#### 추천 — mtr
traceroute + ping 결합. `brew install mtr`.
```bash
sudo mtr github.com
sudo mtr -rwc 100 host                          # 100패킷 report 후 종료
```

### 포트 / 연결 상태

#### nmap (Brewfile)
```bash
nmap -sT localhost                              # TCP connect (권한 불필요)
nmap -p 80,443 host
nmap -A 192.168.0.0/24                          # OS/버전 감지
nmap -p- host                                   # 전 포트 스캔
nmap --top-ports 100 host
```

#### lsof (built-in)
```bash
lsof -i                                         # 모든 네트워크 연결
lsof -i :8080                                   # 8080 포트 점유
lsof -i :9001-9010                              # 포트 범위
lsof -p <PID> -i                                # PID로 포트 확인
lsof -iTCP -sTCP:LISTEN                         # listen 중인 TCP만
```

#### netstat / ss (built-in)
```bash
netstat -an                                     # 모든 연결 (macOS)
netstat -rn                                     # 라우팅 테이블
ss -tlnp                                        # 리스닝 포트 (Linux)
ss -tnp | grep 9001
```

#### nc (netcat, built-in)
```bash
nc -zv host 22                                  # 포트 열림 체크
nc -zv -w 3 redis.internal 6379                 # 타임아웃 3초
nc -l 8080                                      # listen
nc -u host 53                                   # UDP
echo "GET / HTTP/1.0" | nc host 80
nc -vz host 20-25                               # 포트 범위
```

### 인터페이스 / 주소

```bash
ifconfig / ifconfig en0
ipconfig getifaddr en0                          # Wi-Fi IP만 (macOS)
networksetup -listallhardwareports              # 하드웨어 포트 (macOS)
arp -a                                          # 로컬 ARP 캐시
route get github.com                            # 특정 호스트 경로
```

### 대역폭 / 트래픽 (추천, 미포함)
- **bandwhich**: 프로세스별 라이브 대역폭. `sudo bandwhich`.
- **iperf3**: 호스트 간 대역폭 테스트. `iperf3 -s` ↔ `iperf3 -c host`.
- **speedtest-cli**: 인터넷 속도.

### 터널링 / 포트 포워딩 (SSH)
```bash
ssh -L 8080:localhost:3000 host                 # 로컬 8080 → 원격:3000
ssh -R 9000:localhost:3000 host                 # 원격 9000 → 로컬:3000
ssh -D 1080 host                                # SOCKS 프록시
ssh -fNL 5432:db:5432 bastion                   # 백그라운드 DB 터널
autossh -M 0 -fN -L 8080:localhost:8080 host    # 끊김 시 자동 재연결
```
`-f` 백그라운드, `-N` 명령 없음, `-M 0` autossh 모니터 비활성.

### 패킷 캡처 / 디버깅

#### tcpdump (built-in)
```bash
sudo tcpdump -i en0
sudo tcpdump -i en0 'port 443'
sudo tcpdump -nn -A 'port 80'                   # HTTP 평문
sudo tcpdump -i any -w capture.pcap             # Wireshark 포맷 저장
```

#### Wireshark (`wireshark-app`, Brewfile)
GUI 패킷 분석기. `tshark` CLI도 함께.
```bash
tshark -i en0
tshark -r capture.pcap -Y "http.request"
tshark -i en0 -w out.pcap
```

#### mitmproxy (추천)
HTTPS 가로채기/수정. `brew install mitmproxy`.
```bash
mitmproxy / mitmweb
```

### 빠른 레시피
```bash
# 내 공인 IP
curl -s ifconfig.me; echo
dig +short myip.opendns.com @resolver1.opendns.com

# SSL 인증서 만료일
echo | openssl s_client -connect github.com:443 2>/dev/null \
  | openssl x509 -noout -dates

# 특정 포트 점유 프로세스 죽이기
lsof -ti :3000 | xargs kill -9

# 로컬 네트워크 모든 장비
nmap -sn 192.168.0.0/24

# 간단 HTTP 서버
python3 -m http.server 8000

# 클립보드 ↔ 네트워크
pbpaste | curl -X POST -d @- https://...
curl -s URL | pbcopy
```

---

## 암호화 / 보안

### openssl (openssl@3)
```bash
# 인증서 체인
openssl s_client -connect google.com:443 -showcerts </dev/null

# 인증서 상세
openssl x509 -in cert.pem -noout -text
echo | openssl s_client -connect api.example.com:443 2>/dev/null | \
  openssl x509 -noout -subject -issuer -dates

# 해시 / 서명
openssl dgst -sha256 file
openssl rand -hex 32                            # 랜덤 토큰
openssl rand -base64 32
echo -n "msg" | openssl dgst -sha256 -hmac "secret"

# AES 암/복호화
openssl enc -aes-256-cbc -salt -in a -out a.enc
openssl enc -d -aes-256-cbc -in a.enc -out a
```

### base64 / JWT
```bash
echo -n "hello" | base64
echo "aGVsbG8=" | base64 --decode
base64 -i image.png -o image.b64

# URL-safe Base64
echo -n "hello" | base64 | tr '+/' '-_' | tr -d '='

# JWT payload 디코딩 (서명 검증 X)
TOKEN="eyJ..."
echo $TOKEN | cut -d'.' -f2 | base64 --decode 2>/dev/null | jq '.'
```

### ssh / ssh-keygen
```bash
ssh-keygen -t ed25519 -C "email" -f ~/.ssh/key_name
ssh -T git@github-personal                      # 인증 테스트
ssh -vvv host                                   # 상세 디버그
ssh-add -l                                      # agent에 로드된 키
ssh -L 8080:localhost:3000 host                 # 포트 포워딩

# SSH config (~/.ssh/config) 단축 설정
# Host bastion
#   HostName bastion.example.com
#   User ec2-user
#   IdentityFile ~/.ssh/prod-key.pem
```

---

## DB

### mysql-client (`mysql`)
```bash
# 접속
mysql -h 127.0.0.1 -P 3306 -u root -p
mysql -h host -u user -proot dbname

# 단일 쿼리 / 파일 / 저장
mysql -h host -u user -p -e "SELECT NOW()"
mysql -h host -u user -p db < schema.sql
mysql -h host -u user -p db -e "..." > result.tsv

# Docker 내 MySQL
docker exec -it mysql-container mysql -uroot -proot dbname

# 메타 / 분석
SHOW PROCESSLIST; / SHOW FULL PROCESSLIST;
DESCRIBE order_order;
SHOW CREATE TABLE order_order\G
SHOW INDEX FROM order_order;
EXPLAIN SELECT ...;
EXPLAIN ANALYZE SELECT ...;                     # MySQL 8.0+

# 출력 옵션
mysql --table       # 표 형식
mysql -s            # 헤더 제거
mysql -N            # 컬럼명 제거 (순수 데이터)
mysql --vertical    # 세로 (\G와 동일)
mysqldump -h host -u user -p db > dump.sql
```

### libpq (`psql`, `pg_dump`, `pg_restore`)
PostgreSQL 클라이언트. keg-only이므로 `tools.zsh`에서 PATH 추가됨.
```bash
psql -h host -U user -d db
psql -h host -U user -d db -c "SELECT now()"
pg_dump -h host -U user db > dump.sql
pg_restore -h host -U user -d newdb dump.pgc
psql postgres://user:pass@host/db               # URI 형식
```

### pgcli
psql 대체. 자동완성 + 구문 하이라이트 + 멀티라인.
```bash
pgcli -h host -U user -d db
pgcli postgres://user:pass@host/db
# meta:  \d table  \l  \dt  F3 multi-line 토글
```

### lazysql
TUI MySQL/Postgres/SQLite. alias: `lzs`.
```bash
lazysql mysql://root:root@127.0.0.1:3306/dbname
lazysql postgres://user:pass@localhost:5432/dbname
# Tab 패널 전환, e 쿼리 에디터, Enter 실행, q 종료
```

### redis-cli
```bash
# 접속
redis-cli -h 127.0.0.1 -p 6379
redis-cli -h host -a password ping

# 단일 명령
redis-cli GET "session:user:123"
redis-cli HGETALL "order:order:456"

# Docker
docker exec -it redis-container redis-cli

# 키 탐색 (운영 안전)
redis-cli SCAN 0 MATCH "*order*" COUNT 100
redis-cli SCAN 0 MATCH "*order*" COUNT 100 TYPE hash
# KEYS는 운영에서 금지 — 차단 발생

# 키 정보
redis-cli TTL key                               # -1=영구, -2=없음
redis-cli TYPE key                              # string/hash/list/set/zset
redis-cli OBJECT ENCODING key

# 데이터 조회
redis-cli GET key                               # String
redis-cli HGETALL hash_key / HGET hash_key field
redis-cli LRANGE list_key 0 -1
redis-cli SMEMBERS set_key
redis-cli ZRANGE zset_key 0 -1 WITHSCORES

# 서버 상태
redis-cli INFO / INFO memory / INFO keyspace
redis-cli DBSIZE
redis-cli MONITOR                               # 실시간 (운영 주의)

# 패턴 키 일괄 삭제 (개발 전용)
redis-cli --scan --pattern "session:*" | xargs redis-cli DEL
```

---

## Kafka

### kafka (kafka-*.sh 번들)
```bash
# 토픽
kafka-topics.sh --list --bootstrap-server localhost:9092
kafka-topics.sh --describe --topic t1 --bootstrap-server ...
kafka-topics.sh --create --topic t1 --partitions 3 --replication-factor 1 --bootstrap-server ...

# 컨슈머 그룹
kafka-consumer-groups.sh --list --bootstrap-server ...
kafka-consumer-groups.sh --describe --group g1 --bootstrap-server ...   # lag 확인

# Consume
kafka-console-consumer.sh --topic t1 --from-beginning --max-messages 10 --bootstrap-server ...
kafka-console-consumer.sh --topic t1 --bootstrap-server ...             # 최신부터
kafka-console-consumer.sh --topic t1 --partition 0 --offset 100 --bootstrap-server ...
kafka-console-consumer.sh --topic t1 \
  --property print.key=true --property key.separator=":" \
  --bootstrap-server ...

# Produce
kafka-console-producer.sh --topic t1 --bootstrap-server ...
kafka-console-producer.sh --topic t1 \
  --property parse.key=true --property key.separator=":" \
  --bootstrap-server ...
```

### kcat
유연한 Kafka CLI (Avro/Schema Registry 지원).
```bash
# Metadata
kcat -b localhost:9092 -L
kcat -b localhost:9092 -L -t topic              # 특정 토픽

# Consume
kcat -b ... -t topic -C -o beginning            # 처음부터
kcat -b ... -t topic -C -o -5                   # 마지막 5개
kcat -b ... -t topic -C -e                      # EOF에서 종료
kcat -b ... -t topic -C -p 0 -o 100             # 특정 파티션·오프셋
kcat -b ... -t topic -C -G my-group             # 컨슈머 그룹
kcat -b ... -t topic -C \
  -f 'Key: %k\nValue: %s\nPartition: %p, Offset: %o\n---\n'

# Produce
echo '{"orderId":"123"}' | kcat -b ... -t topic -P
echo 'k:v' | kcat -b ... -t topic -P -K ':'
kcat -b ... -t topic -P < messages.json

# Avro + Schema Registry
kcat -b ... -t topic -C -s avro -r http://sr:8081

# JSON 파싱 조합
kcat -b ... -t topic -C -o beginning -e | jq 'select(.status == "FAILED")'
```

---

## 컨테이너 / Kubernetes

### docker
```bash
# 상태
docker ps / docker ps -a
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
docker images

# 라이프사이클
docker run -it --rm alpine sh
docker start/stop/restart <name>
docker rm <name> / docker rmi <image-id>
docker exec -it <name> bash                     # bash 없으면 sh

# 로그
docker logs -f <name>
docker logs --tail 100 --since 10m <name>

# 정리
docker image prune
docker system prune -a

# compose
docker compose up -d
docker compose down / docker compose down -v    # -v: 볼륨까지 (데이터 초기화)
docker compose logs -f / logs -f <service>
docker compose ps

# 모니터링 / 파일 / 네트워크
docker stats / docker stats --no-stream
docker cp <name>:/path ./local/
docker cp ./local <name>:/path
docker volume ls / docker network ls
docker inspect <name>                           # IP 등 상세
```

### lazydocker
Docker TUI. alias: `lzd`.
- `h/l` 패널 전환, `j/k` 항목 이동, `Enter` 상세, `Tab` 하단 탭
- `d` 삭제, `s` start/stop, `r` restart, `a` attach, `e` exec
- `m` 로그 모드, `/` 검색, `R` 새로고침, `q` 종료

### kubectl
```bash
# 조회
kubectl get pods -A
kubectl get pods -n <ns> -l app=order-api
kubectl describe pod <pod>
kubectl get events --sort-by=.lastTimestamp

# 로그 / 셸
kubectl logs -f <pod> -c <container>
kubectl logs --tail=100 --since=10m <pod>
kubectl exec -it <pod> -- sh

# 포트 포워딩
kubectl port-forward svc/api 8080:80
kubectl port-forward pod/<pod> 9001:9001

# 적용 / 롤아웃
kubectl apply -f manifest.yaml
kubectl rollout restart deployment/api
kubectl rollout status deployment/api
kubectl rollout undo deployment/api

# 리소스 사용량
kubectl top pods / kubectl top nodes

# 설정 / 컨텍스트
kubectl config view
kubectl config current-context
```

### kubectx / kubens
```bash
kubectx                                         # 컨텍스트 목록
kubectx dev-cluster                             # 전환
kubectx -                                       # 직전 컨텍스트
kubens kube-system                              # 네임스페이스 전환
```

### k9s
Kubernetes TUI.
```bash
k9s                                             # 현재 컨텍스트
k9s -n order                                    # 특정 네임스페이스
k9s --context prod
```
키바인딩: `:pod` `:svc` `:deploy` `:ns`, `/pattern` 필터, `l` 로그, `s` 셸, `d` describe, `y` YAML, `Ctrl-d` 삭제, `?` 도움말.

### helm
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-release bitnami/mysql
helm upgrade --install r chart -f values.yaml
helm list
helm uninstall my-release
helm template chart -f values.yaml              # 렌더 결과 확인 (배포 X)
```

### eksctl
```bash
eksctl get cluster
eksctl create cluster -f config.yaml
eksctl utils write-kubeconfig --cluster=NAME
```

---

## AWS / 클라우드

### awscli (`aws`)
```bash
# 인증 / 프로파일
aws sts get-caller-identity
aws sts get-caller-identity --profile prod
export AWS_PROFILE=prod
aws configure list

# S3
aws s3 ls
aws s3 cp file.tgz s3://bucket/
aws s3 sync ./local/ s3://bucket/path/ --dryrun
aws s3 presign s3://bucket/key --expires-in 3600

# ECR
aws ecr describe-repositories
aws ecr list-images --repository-name myrepo
aws ecr get-login-password | \
  docker login --username AWS --password-stdin <account>.dkr.ecr.<region>.amazonaws.com

# EC2 / ECS
aws ec2 describe-instances --filters "Name=tag:Env,Values=prod"
aws ecs list-clusters
aws ecs describe-services --cluster c --services s \
  --query 'services[].{status:status,desired:desiredCount,running:runningCount}'

# CloudWatch Logs
aws logs tail /aws/ecs/my-service --follow
aws logs tail log-group --since 1h --filter-pattern '?ERROR ?WARN'
aws logs filter-log-events --log-group-name /ecs/order-api \
  --start-time $(date -v-10M +%s000) --filter-pattern "ERROR"

# RDS
aws rds describe-db-instances \
  --query 'DBInstances[].{id:DBInstanceIdentifier,status:DBInstanceStatus,endpoint:Endpoint.Address}'

# SSM Parameter Store
aws ssm get-parameter --name /prod/order/db-password --with-decryption
aws ssm get-parameters-by-path --path /prod/order/ --with-decryption

# 공통 옵션
--output json|text|table
--query 'expr'                                  # JMESPath 서버사이드 필터
--region ap-northeast-2 / --profile prod
```

### s5cmd
S3 고속 병렬 CLI — `aws s3`보다 10~20배 빠름 (bulk).
```bash
s5cmd ls s3://bucket/
s5cmd cp 'data/*' s3://bucket/dir/              # glob + 병렬
s5cmd sync ./local/ s3://bucket/path/
s5cmd cat s3://bucket/logs/2026-*.log | gzip -d | rg ERROR
s5cmd du s3://bucket/
s5cmd --numworkers 256 cp ...                   # 동시성 튜닝
```

### docker-credential-helper-ecr
ECR에 매번 `aws ecr get-login-password ... | docker login` 안 해도 자동 인증.
```json
// ~/.docker/config.json
{
  "credHelpers": {
    "<account>.dkr.ecr.<region>.amazonaws.com": "ecr-login"
  }
}
```
이후 `docker pull <account>.dkr.ecr.<region>.amazonaws.com/myrepo:tag` 자동 인증.

### session-manager-plugin (AWS SSM)
SSH 키 없이 EC2/ECS 컨테이너 접속. AWS IAM 권한으로 인증.
```bash
aws ssm start-session --target i-0123456789abcdef0
aws ssm start-session --target ecs:cluster_task_container

# 포트 포워딩
aws ssm start-session --target i-xxx \
  --document-name AWS-StartPortForwardingSession \
  --parameters '{"portNumber":["3306"],"localPortNumber":["13306"]}'
```
※ Brewfile cask가 deprecated이라 AWS 공식 pkg 수동 설치.

### saml2aws
SAML SSO → AWS 임시 자격증명.
```bash
saml2aws configure                              # 최초 설정
saml2aws login
saml2aws login --role=arn:aws:iam::...
```

---

## 에디터

### vim
```bash
vim file.kt
vim +50 file.kt                                 # 50번째 줄
vim +/pattern file.kt                           # 패턴 위치
```

```
모드:    i 삽입,  a 커서 뒤,  o 아래 줄,  O 위 줄,  Esc 노말
저장:    :w / :q / :wq / :q! / ZZ
이동:    h/j/k/l,  gg / G,  :50,  w / b,  0 / ^,  $,  Ctrl-d/u
편집:    dd 잘라내기,  yy 복사,  p / P 붙여넣기,  u / Ctrl-r 실행/취소
         x 글자 삭제,  dw 단어 삭제,  D 줄 끝까지,  C 줄 끝 + 삽입
검색:    /pat,  ?pat,  n / N,  * / # 커서 단어
치환:    :s/old/new/,  :s/old/new/g,  :%s/old/new/g
         :%s/old/new/gc 확인,  :10,20s/old/new/g 범위
선택:    v 문자,  V 줄,  Ctrl-v 블록 — 후 d/y/>
분할:    :split / :vsplit,  Ctrl-w w 창 전환,  :q 닫기
```

---

## AI 도구

### Claude Code (`claude-code`, cask)
Anthropic 공식 CLI. 코드베이스 컨텍스트 기반 에이전트 작업.
```bash
claude                                          # 현재 디렉토리에서 대화
claude -p "이 PR 리뷰해줘"                       # one-shot
claude --resume                                 # 직전 세션 이어가기
claude /help
```
- 프로젝트 메모리: `<repo>/CLAUDE.md`
- 글로벌 메모리/스킬/에이전트: `~/.claude/` (별도 저장소 `claude-skills`로 관리, symlink 배포)
- MCP 서버: `~/.claude/mcps` (별도 저장소로 관리, symlink 배포)
- 설정: `~/.claude/settings.json`

---

## 터미널 앱 / 프롬프트 / 폰트

### ghostty
GPU 가속 모던 터미널. 설정: `~/.config/ghostty/config`.
```
font-family = D2CodingLigature Nerd Font Mono
font-size   = 15
theme       = Gruvbox Dark Hard
```

### cmux
Ghostty 기반 터미널 + AI 에이전트용 vertical tabs + workspace.
- 설정: `~/.config/cmux/settings.json`
- Font는 ghostty config 상속 (libghostty 임베드)

### starship
이미 [셸 / 스크립트](#셸--스크립트) 섹션 참조.

### Nerd Fonts
- **MesloLG Nerd Font** — UI 폴백, 아이콘
- **D2CodingLigature Nerd Font** — 한글 + 프로그래밍 합자 (`->`, `=>`, `!=`)

---

## GUI 앱 (macOS)

### Raycast
Spotlight 대체. 설치 후 ⌘+Space를 Raycast에 넘김.

추천 extension: Clipboard History, Window Management, GitHub, Jira, Kill Process.

### Slack (`slack`, cask)
- 워크스페이스 추가: ⌘+Shift+S 후 도메인 입력
- ⌘+K 채널/DM 점프, ⌘+Shift+M 멘션, ⌘+/ 단축키 전체
- Huddle: ⌘+Shift+H

### Google Chrome (`google-chrome`, cask)
```bash
# 헤드리스
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless --disable-gpu --screenshot=out.png https://example.com

# 시크릿 창 열기
open -na "Google Chrome" --args --incognito "https://..."
```
- DevTools: ⌘+Option+I, 콘솔 ⌘+Option+J, 요소 선택 ⌘+Shift+C
- 프로필 분리로 업무/개인 격리

### Karabiner-Elements
키보드 리맵. 이 dotfiles의 프로파일:
- Caps Lock ↔ Left Control 스왑
- Right Command → F18 (macOS symbolichotkey 61과 연동, 한/영 전환)

설정: `~/.config/karabiner/karabiner.json` (chezmoi 관리).
**최초 실행 시 macOS 접근성 권한 수동 승인 필요.**

### macOS 시스템 defaults (이 dotfiles가 자동 적용)
`run_onchange_05-macos-defaults.sh`로 관리:
- 입력 소스 단축키 (이전 비활성, 다음 = F18)
- Spotlight 비활성 (Raycast 대체)
- F1/F2 표준 function 키
- 키 반복 속도 최소 (`KeyRepeat=2`, `InitialKeyRepeat=15`, `ApplePressAndHoldEnabled=false`)
- 트랙패드 탭 클릭

---

## Unix 기본 명령어

### awk
컬럼 기반 텍스트 처리.
```bash
# 기본
awk '{print $1}' file                           # 첫 컬럼
awk '{print $NF}' file                          # 마지막 컬럼
awk '{print NR, $0}' file                       # 줄 번호
awk -F',' '{print $1, $3}' data.csv             # 구분자
awk -F':' '{print $1}' /etc/passwd
awk -F'\t' '{print $2}' data.tsv

# 조건
awk '$3 > 1000' data.csv
awk '$2 == "ERROR"' app.log
awk '/order/' file
awk '!/^#/' config.yml

# 집계
awk '{sum += $2} END {print sum}' amounts.txt
awk '/ERROR/ {count++} END {print count}' app.log
awk '{sum += $2; n++} END {print sum/n}' amounts.txt
awk 'BEGIN{max=0} $2>max {max=$2} END{print max}' data.txt

# 포맷
awk -F',' '{printf "%-20s %-10s %8d\n", $1, $2, $3}' data.csv
awk -F',' 'BEGIN{OFS="\t"} {print $1, $3}' data.csv   # CSV → TSV

# 실전
ps aux | awk '{print $11, $6/1024 "MB"}' | sort -k2 -rn | head
awk '/ERROR/ {print substr($1,1,13)}' app.log | sort | uniq -c
```

### sed
stream editor (치환 주력).
```bash
sed 's/foo/bar/g' file.txt                      # 전체 치환 (출력만)
sed -i '' 's/foo/bar/g' file.txt                # 인플레이스 (macOS)
sed -i 's/foo/bar/g' file.txt                   # Linux

# 줄 범위 / 줄 단위
sed -n '50,80p' file.kt                         # 50~80번째만 출력
sed '1d' file                                   # 첫 줄 삭제 (헤더 제거)
sed '/^$/d' file                                # 빈 줄 제거
sed '/^#/d' config.yml                          # 주석 제거
sed '5s/old/new/' file                          # 5번째 줄만
sed '10,20s/old/new/g' file                     # 10~20번째 줄

# 줄 추가
sed '3a\new line' file                          # 3번째 줄 뒤
sed '1i\header' file                            # 1번째 줄 앞

# 블록 추출
cat app.log | sed -n '/ERROR/,/^$/p'            # ERROR부터 빈 줄까지
```

### grep
패턴 검색 (rg 못 쓸 때, POSIX).
```bash
grep -r "pattern" dir/
grep -iE "foo|bar" file
grep -A3 -B2 "x" file                           # 주변 라인
grep -v "exclude" file                          # 역매칭
grep -c "x" file                                # 카운트
grep -n "ERROR" app.log                         # 줄 번호
grep -h "txId=abc123" logs/*.log                # 파일명 제거
zgrep "ERROR" file.log.gz                       # gzip 파일 직접
```

### find
파일 검색 (fd 못 쓸 때, POSIX).
```bash
find . -name "*.py"
find . -type f -mtime -7                        # 7일 이내
find . -size +10M
find . -name "*.kt" -newer build.gradle.kts
find . -name "*.sql" -not -path "*/build/*"
find . -name "*.log" -exec rm {} \;
find . -name "*.js" -print0 | xargs -0 grep "pattern"
```

### ssh / scp / rsync
```bash
ssh user@host
ssh -p 2222 -i ~/.ssh/key.pem user@host
ssh user@host 'tail -100 /var/log/app.log'      # 원격 명령

scp file user@host:/path/
scp -r dir/ user@host:/path/
scp -P 2222 file user@host:/path/

rsync -avz --progress ./dir/ user@host:/path/
rsync -avz --delete src/ dst/                   # src 기준 동기화
rsync -avz --exclude='*.log' --exclude='build/' ./ user@host:/app/
# -a: 권한/타임스탬프 보존, -v: verbose, -z: 압축
```

### tar / gzip / zip
```bash
tar czvf archive.tgz dir/
tar xzvf archive.tgz
tar tzvf archive.tgz                            # 목록만
tar xzf archive.tgz -C /target/                 # 특정 경로 해제
tar xzf archive.tgz ./file.kt                   # 특정 파일만
tar czvf - dir/ | ssh host "cat > /tmp/x"       # 스트리밍

gzip -k file                                    # 원본 유지
gzip -d file.gz                                 # = gunzip
zcat file.log.gz | grep "ERROR"
zless file.log.gz

zip -r archive.zip ./dir/
unzip archive.zip -d /target/
unzip -l archive.zip
```

### ps / kill / pgrep / pkill
```bash
ps aux | grep node
ps aux | grep java | grep -v grep
ps auxf                                         # 부모-자식 트리 (Linux)
ps aux --sort=-%cpu | head -10
ps aux --sort=-%mem | head -10

pgrep -f "node"
pgrep -fl "node"                                # PID + 커맨드 라인
kill <PID> / kill -9 <PID>
killall java
pkill -f "node server"
kill $(lsof -t -i :9001)                        # 포트 점유 죽이기
```

### df / du
```bash
df -h
du -sh dir/
du -h --max-depth=1 .
du -sh * | sort -rh
du -sh */ | sort -rh | head -10
```

### xargs
stdin → 인자 변환.
```bash
cat urls.txt | xargs -I{} curl {}
find . -name '*.pyc' | xargs rm
echo "a b c" | xargs -n1                        # 개별 인자로
ls | xargs -P4 -I{} gzip {}                     # 병렬 4개
find . -name "*.kt" -print0 | xargs -0 grep "TODO"   # 공백 안전
find . -name "*.tmp" | xargs -p rm              # 확인 후 실행
cat endpoints.txt | xargs -P 8 -I {} curl -s -o /dev/null -w "%{http_code} {}\n" {}
```

### tee
stdin → 파일 + stdout.
```bash
command | tee output.log
command | tee -a append.log                     # append
make 2>&1 | tee build.log
```

### cut / sort / uniq / wc / tr / head / tail
```bash
# cut
cut -d',' -f2,4 data.csv                        # 2,4 컬럼
cut -d':' -f1 /etc/passwd
cut -c1-10 file                                 # 1~10번째 글자

# sort / uniq
sort -n file / sort -k2 -n / sort -t',' -k3 -n
sort -u file                                    # 정렬 + 중복 제거
sort | uniq -c | sort -rn                       # 빈도 카운트
sort | uniq -d                                  # 중복된 것만

# wc
wc -l file / wc -w file
find . -name "*.kt" | wc -l                     # 파일 개수

# tr / head / tail
echo "ABC" | tr 'A-Z' 'a-z'
head -n 20 file / head -c 1024 large.bin        # 앞 N줄/N바이트
tail -n 20 file
tail -f log.txt                                 # follow
tail -F log.txt                                 # 로테이션 따라감
tail -100 app.log | grep --line-buffered "ERROR"
```

### diff / patch
```bash
diff -u a.txt b.txt > changes.patch
diff -y a.txt b.txt                             # 나란히
diff -r dir1/ dir2/
diff -rq dir1/ dir2/                            # 다른 파일 목록만
diff <(git show HEAD~1:file) <(git show HEAD:file)
diff <(sort a) <(sort b)
patch < changes.patch
```

### date / cal
```bash
date
date -u +%FT%TZ                                 # UTC ISO 8601
date +"%Y-%m-%d %H:%M:%S"
date +%s                                        # epoch
date -r EPOCH                                   # epoch → 사람 시간 (macOS)
date -d "2026-03-30" +%s                        # 날짜 → epoch (Linux)
cal / cal 2026 / cal -3
```

### chmod / chown / ln
```bash
chmod +x script.sh
chmod 755 dir/
chmod -R u+rw dir/
chown user:group file
ln -s target link_name
```

### env / export / printenv
```bash
env | sort
printenv PATH
export VAR=value
unset VAR
```

### man / which / type / file
```bash
man curl
which python / which -a java                    # 모든 경로
type ls / type gradle                           # alias/builtin/file 구분
file /bin/bash
```

### history / job control
```bash
# history
history | grep ssh
!! / sudo !!                                     # 직전 명령
!$                                               # 직전 마지막 인자
!^                                               # 직전 첫 번째 인자
!ssh                                             # 마지막 ssh 시작 명령

# 잡 컨트롤
command &                                        # 백그라운드
jobs / fg %1
Ctrl-Z → bg                                      # 일시정지 → 백그라운드
nohup long-cmd > out.log 2>&1 &                  # 로그아웃 후에도 유지
disown %1
```

### nc (netcat)
```bash
nc -zv host 22                                   # 포트 열림 확인
nc -l 8080                                       # listen
echo "GET / HTTP/1.0" | nc host 80
nc -u host 53                                    # UDP
```

---

## macOS 전용 도구

```bash
# 클립보드
cat response.json | pbcopy
echo $TOKEN | pbcopy
pbpaste / pbpaste | jq '.' / pbpaste > out.txt
cat ~/.ssh/id_rsa.pub | pbcopy

# 파일/URL 열기
open .                                          # Finder
open ./build/reports/tests/                     # HTML
open https://github.com

# 시스템 정보
sw_vers / sw_vers -productVersion
sysctl -n hw.logicalcpu                         # CPU 코어 수
sysctl -n hw.memsize | awk '{print $0/1024/1024/1024 " GB"}'

# caffeinate — 슬립 방지
caffeinate -i ./gradlew build
caffeinate -s -t 3600                           # 1시간 슬립 방지

# DNS 캐시 초기화
sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder

# Spotlight DB로 빠른 탐색
mdfind -name "application-local.yml"
mdfind "kind:kotlin OrderService"

# 현재 프로세스 CPU/메모리
top -l 1 -pid $(pgrep -f "order-api") -stats pid,cpu,mem
```

---

## 코드베이스 탐색 전략

낯선 코드베이스 파악 순서:
```bash
# 1. 프로젝트 구조
find . -name "build.gradle.kts" | head -20      # 모듈 목록
find . -name "*.kt" -path "*/domain/*" | head -30   # 도메인 레이어

# 2. 진입점
rg "fun main|@SpringBootApplication" --type kotlin -l

# 3. 핵심 개념어
rg "OrderOrder" --type kotlin -l | sort

# 4. 인터페이스/포트
rg "interface.*Port|interface.*Repository" --type kotlin

# 5. 의존성 방향
rg "import.*infrastructure|import.*adapter" --type kotlin -l
```

---

## 파이프라인 치트시트

### 로그 분석
```bash
# JSON 라인 로그 에러 빈도 TOP
cat app.log | rg "ERROR" | jq -R 'fromjson?' \
  | jq 'select(.level == "error") | .msg' \
  | sort | uniq -c | sort -rn | head

# HTTP 상태 코드 빈도
awk '{print $9}' access.log | sort | uniq -c | sort -rn

# 시간대별 에러 빈도
grep "ERROR" app.log | awk '{print $1, $2}' | cut -c1-13 | sort | uniq -c

# 빌드 로그 에러 추출
./gradlew build 2>&1 | grep -E "error:|ERROR|FAILED"
```

### 프로세스 / 디스크 / 포트
```bash
# 메모리 상위 10
ps aux | sort -rk4 | head

# 포트 점유 프로세스
lsof -i :3000

# 디스크 큰 파일
du -sh * | sort -rh | head
fd -t f -S +100M

# 대량 파일 병렬 처리
fd -e log | xargs -P8 -I{} gzip {}
```

### 코드 / API
```bash
# Kotlin 파일에서 패턴 매칭 파일
rg "implements|extends" --type kotlin -l | sort

# git log 키워드 필터
git log --oneline | grep -i "cancel\|refund" | head -20

# 커밋 작성자 빈도
git log --format="%an" | sort | uniq -c | sort -rn | head -10

# JSON API 응답 가공
curl -s https://api.github.com/users/USER | jq

# JSON 배열 조건 + 필드만
cat response.json | jq -r '.[] | select(.amount > 1000) | .orderId'

# API 응답에서 에러만
curl -s https://api/logs | jq '[.[] | select(.level == "ERROR")]'
```

### Kafka / DB
```bash
# Kafka 마지막 N개
kcat -b broker:9092 -t topic -C -e -c 10

# Kafka 메시지 실시간 필터
kafka-console-consumer.sh --bootstrap-server ... --topic t \
  | jq 'select(.status == "FAILED")'

# Redis 패턴 키 일괄 삭제 (개발 전용)
redis-cli --scan --pattern "session:*" | xargs redis-cli DEL

# DB 결과를 JSON으로
mysql -h host -u u -p db -N -s -e "SELECT id, amount FROM t LIMIT 5" \
  | awk '{print "{\"id\":\""$1"\",\"amount\":"$2"}"}'
```

### k8s 디버깅
```bash
kubectl get pods -A | grep -i error
kubectl describe pod POD | less
stern POD-prefix --since 10m                    # stern 설치 시
```

---

## 이 dotfiles가 설정한 alias / 환경

### Zsh (`~/.zshrc.d/tools.zsh`)
```bash
# ls
alias ls='eza --icons'
alias ll='eza -lah --icons --git'
alias lt='eza --tree --level=2 --icons'

# cat
alias cat='bat --paging=never'

# Git / Docker / DB TUI
alias lg='lazygit'
alias lzd='lazydocker'
alias lzs='lazysql'

# cd → zoxide
eval "$(zoxide init zsh --cmd cd)"

# Ctrl-R → atuin
eval "$(atuin init zsh --disable-up-arrow)"

# fzf 키바인딩
source <(fzf --zsh)

# starship 프롬프트
eval "$(starship init zsh)"
```

### Git (`~/.gitconfig`)
```
pager = delta (side-by-side)
merge conflictstyle = zdiff3
alias:
  dft   = -c diff.external=difft diff
  dlog  = -c diff.external=difft log --ext-diff
  dshow = -c diff.external=difft show --ext-diff
```

---

## 주의사항

- **결과 제한**: 대용량 결과는 `head -N`으로 먼저 샘플링
- **파이프 우선**: 중간 파일 없이 파이프로 직결
- **오류 포함**: `2>&1`로 stderr도 함께 캡처
- **운영 환경 주의**: `KEYS *`, `MONITOR`, `FLUSHDB`, `DELETE` 미조건 등은 운영 서버에서 사용 금지
- **인플레이스 옵션 차이**: `sed -i` 문법이 macOS(`-i ''`)와 Linux 다름
- **마이그레이션 파일**: 기존 Flyway 마이그레이션 파일은 절대 수정 금지

---

## 더 공부할 곳

- [ripgrep 매뉴얼](https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md)
- [jq tutorial](https://stedolan.github.io/jq/tutorial/)
- [tmux cheatsheet](https://tmuxcheatsheet.com/)
- [just manual](https://just.systems/man/en/)
- [uv docs](https://docs.astral.sh/uv/)
- [Raycast Store](https://www.raycast.com/store)

---

*이 문서는 chezmoi 소스의 `docs/tools-guide.md`에 있으며, `docs/`는 `.chezmoiignore`에 의해 홈 디렉토리로 동기화되지 않음. 편집은 `chezmoi cd → docs/tools-guide.md`.*
