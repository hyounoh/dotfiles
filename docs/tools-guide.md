# 도구 가이드 (Tools Reference)

이 머신에서 사용 가능한 도구들의 빠른 참조. Brewfile로 설치되는 것 + 이 dotfiles의 alias/설정 + Unix 기본 명령어.

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
- [터미널 앱 / 프롬프트 / 폰트](#터미널-앱--프롬프트--폰트)
- [GUI 앱 (macOS)](#gui-앱-macos)
- [Unix 기본 명령어](#unix-기본-명령어)
- [이 dotfiles가 설정한 alias / 환경](#이-dotfiles가-설정한-alias--환경)

---

## 텍스트 / JSON / 검색

### ripgrep (`rg`)
grep의 빠른 대체. `.gitignore` 자동 반영.
```bash
rg "TODO" .                  # 현재 디렉토리 재귀 검색
rg -i "foo" --type rust       # 대소문자 무시 + 언어 필터
rg -A3 -B2 "pattern"          # 주변 라인 포함
rg --files | rg test          # 파일명만 검색
```

### jq
JSON 쿼리/조작.
```bash
echo '{"a":1}' | jq '.a'
curl https://api.github.com/repos/torvalds/linux | jq '.stargazers_count'
jq '.[] | select(.age > 30) | .name' data.json
jq -s 'add' a.json b.json     # 여러 파일 합치기
```

### yq
jq의 YAML 버전. JSON도 지원.
```bash
yq '.services.web.image' docker-compose.yml
yq -i '.version = "1.0"' config.yml
```

### fzf
퍼지 인터랙티브 검색. 파이프/키바인딩 둘 다 유용.
```bash
# 파이프 사용
git log --oneline | fzf
vim $(find . -type f | fzf)

# 키바인딩 (zsh)
# Ctrl-T: 현재 디렉토리 파일 검색 (atuin이 Ctrl-R 점유)
# Alt-C: 디렉토리로 cd
```

### fd
find 대체. 직관적 문법, gitignore 인식.
```bash
fd "README"                   # 이름에 README 포함 파일
fd -e py                       # 확장자 .py
fd -H ".env"                   # hidden 포함
fd -x rm {}                    # 매치된 파일에 명령 실행
```

### bat
cat 대체. 문법 하이라이트 + git 표시 + paging.
```bash
bat README.md
bat -l json response.txt       # 언어 강제
# 이 dotfiles에서 alias cat='bat --paging=never'
```

### miller (`mlr`)
CSV/TSV/JSON 파이프라인.
```bash
mlr --csv cat file.csv                    # 예쁘게 출력
mlr --csv filter '$age > 30' people.csv   # 필터
mlr --c2j cat data.csv                     # CSV → JSON
mlr --csv stats1 -a mean,sum -f price      # 통계
```

### tidy-viewer (`tv`)
CSV 컬러 표.
```bash
tv data.csv
tv -n 20 data.csv             # 상위 20행
```

### difftastic (`difft`)
AST 기반 구조적 diff. 줄 단위가 아닌 구문 단위.
```bash
git dft HEAD~3                 # 이 dotfiles에 alias 설정
git dlog                        # difft 기반 log
git dshow COMMIT
difft old.py new.py             # 직접 호출
```

### column (util-linux)
표 형식 정렬. macOS 기본 column은 기능 제한적이라 Linux판 설치.
```bash
mount | column -t
cat /etc/passwd | column -t -s ':'
```

### watch
명령을 N초마다 반복 실행.
```bash
watch -n 2 df -h
watch -d 'kubectl get pods'    # -d: 차이 강조
```

---

## Git / GitHub

### git
```bash
git log --oneline -n 20
git log --graph --all
git diff HEAD~1                 # 이전 커밋과 비교
git stash / git stash pop
git bisect start
```

이 dotfiles의 alias:
- `git dft` — difftastic 구조적 diff
- `git dlog` — difftastic log
- `git dshow COMMIT` — difftastic show
- pager: `delta` (side-by-side, syntax highlight)

### gh (GitHub CLI)
```bash
gh pr create --title "feat: ..." --body "..."
gh pr view --web
gh pr checkout 123
gh issue list --assignee @me
gh repo clone owner/repo
gh api repos/owner/repo/releases
gh copilot suggest "..."        # 확장 설치 후: gh extension install github/gh-copilot
```

### lazygit
Git TUI. 설정 없이 바로 사용 가능.
- `?` 도움말, `c` 커밋, `a` stage all, `P` push, `p` pull
- alias: `lg`

### delta
git diff의 하이라이터. 이 dotfiles에서 pager로 자동 설정됨.
```ini
# ~/.gitconfig 일부
[core]
    pager = delta
[delta]
    navigate = true
    side-by-side = true
```

---

## 터미널 생산성

### tmux
터미널 세션 관리.
```bash
tmux new -s work                # 세션 생성
tmux ls                          # 세션 목록
tmux attach -t work              # 붙기
tmux kill-session -t work

# 세션 안에서 (prefix = Ctrl-b)
# Ctrl-b %  세로 분할
# Ctrl-b "  가로 분할
# Ctrl-b o  다음 pane
# Ctrl-b d  detach
# Ctrl-b [  copy mode (vi 키)
```

### btop
인터랙티브 시스템 모니터 (top/htop 상위호환).
```bash
btop
# m: CPU view, d: disk view, n: network view, q: quit
```

### eza
ls 대체 (컬러, 아이콘, git 상태).
```bash
eza                              # 기본
eza -lah --git                   # 상세 + hidden + git status
eza --tree --level=2             # 트리 뷰
```
이 dotfiles alias:
- `ls='eza --icons'`
- `ll='eza -lah --icons --git'`
- `lt='eza --tree --level=2 --icons'`

### zoxide
`cd` 대체 (학습된 자주 가는 디렉토리로 점프).
```bash
cd proj                         # → ~/Workspace/proj 로 이동 (히스토리 학습)
cd -                             # 이전 위치
z foo bar                        # foo와 bar 둘 다 포함된 경로로
zi                               # 인터랙티브 선택
```

### atuin
히스토리 DB + 검색. `Ctrl-R`로 검색창.
```bash
# Ctrl-R: 인터랙티브 검색
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
shellcheck -x script.sh         # source 파일까지 검사
```

### shfmt
bash 스크립트 포맷터.
```bash
shfmt -d script.sh              # diff
shfmt -w -i 2 script.sh          # 2칸 들여쓰기로 덮어쓰기
```

---

## 셸 / 스크립트

### zsh
기본 셸. `~/.zshrc`로 설정, `~/.zshrc.d/*.zsh`로 모듈화.

### oh-my-zsh
플러그인 프레임워크. 현재 `plugins=(git)` 최소 구성.

### zsh-autosuggestions
입력한 명령 뒤에 과거 히스토리 기반 자동완성 제안 (`→` 키로 수락).

### zsh-syntax-highlighting
입력 중 명령어 구문을 실시간 하이라이트 (존재하지 않는 명령은 빨강).

### starship
프롬프트. 설정: `~/.config/starship.toml`.

### chezmoi
dotfiles 관리.
```bash
chezmoi apply                   # 홈에 반영
chezmoi diff                     # 적용 전 미리보기
chezmoi status                   # 변경 필요 파일
chezmoi edit ~/.zshrc            # 소스 파일 편집
chezmoi add ~/.config/foo        # 관리 편입
chezmoi cd                       # 소스 디렉토리 이동
chezmoi update                   # git pull + apply
chezmoi re-add ~/.zshrc          # 홈 변경을 소스에 역반영
```

---

## 언어 런타임

### mise
다국어 런타임 버전 관리.
```bash
mise ls                         # 설치된 것
mise ls-remote java             # 사용 가능 버전
mise use -g java@21 node@22     # 전역 설치 + 사용
mise use java@17                # 현재 디렉토리 고정 (mise.toml 생성)
mise install                    # mise.toml 기반 일괄 설치
mise current                    # 지금 유효한 버전
mise env                        # 현재 주입되는 PATH/환경변수
mise lock -g                    # lockfile 재생성
```
이 dotfiles에서 관리: java 21, python 3.13, node 22, go 1.25, TypeScript.

### uv
Python pkg/venv 매니저 (pip+poetry+pyenv 통합, 초고속).
```bash
uv venv .venv && source .venv/bin/activate
uv init                         # pyproject.toml 생성
uv add requests fastapi
uv run python main.py           # venv 자동 활성
uv pip install -r req.txt       # pip 호환
```

### gradle
JVM 빌드 도구.
```bash
gradle build
gradle test --tests "com.example.*"
gradle dependencies
./gradlew wrapper --gradle-version=8.5
```

---

## 네트워크 / HTTP

### curl
HTTP 클라이언트 (가장 표준).
```bash
curl -fsSL https://example.com
curl -I https://example.com             # 헤더만
curl -X POST -H "Content-Type: application/json" \
     -d '{"a":1}' https://api.example.com
curl -u user:pass https://...           # basic auth
curl -o file.tgz https://...            # 저장
curl -v https://...                     # 상세 로그
```

### wget
파일 다운로드 (curl과 다름: resumable, mirror 지원).
```bash
wget https://example.com/file.tgz
wget -c URL                              # 이어받기
wget -r -l2 URL                          # 재귀 다운로드
```

### nmap
포트 스캔.
```bash
nmap -sT localhost                       # TCP connect scan
nmap -p 80,443 host                      # 특정 포트
nmap -A 192.168.0.0/24                    # OS/버전 감지
```

### gping
ping 그래프.
```bash
gping google.com cloudflare.com github.com
```

### doggo
모던 DNS 클라이언트 (dig 대체).
```bash
doggo github.com
doggo MX gmail.com
doggo A example.com @1.1.1.1            # 특정 resolver
doggo --json github.com
```

---

## 암호화 / 보안

### openssl (openssl@3)
```bash
# 인증서 체인 확인
openssl s_client -connect google.com:443 -showcerts </dev/null

# 인증서 상세
openssl x509 -in cert.pem -noout -text

# 해시
openssl dgst -sha256 file
openssl rand -hex 32                     # 랜덤 토큰

# AES 암/복호화
openssl enc -aes-256-cbc -salt -in a -out a.enc
openssl enc -d -aes-256-cbc -in a.enc -out a
```

### ssh / ssh-keygen
```bash
ssh-keygen -t ed25519 -C "email" -f ~/.ssh/key_name
ssh -T git@github-personal              # 인증 테스트
ssh -vvv host                            # 상세 디버그
ssh-add -l                               # agent에 로드된 키
ssh -L 8080:localhost:3000 host          # 로컬 포트 포워딩
```

---

## DB

### mysql-client (`mysql`)
```bash
mysql -h host -u user -p database
mysql -h host -u user -p -e "SELECT NOW()"
mysqldump -h host -u user -p db > dump.sql
```

### lazysql
TUI로 MySQL/Postgres/SQLite 관리. alias: `lzs`.

### redis-cli
```bash
redis-cli
redis-cli -h host -p 6379 ping
redis-cli --scan --pattern "user:*"
redis-cli monitor                        # 실시간 명령 관찰
```

---

## Kafka

### kafka (kafka-*.sh 번들)
```bash
kafka-topics.sh --list --bootstrap-server localhost:9092
kafka-topics.sh --create --topic t1 --partitions 3 --replication-factor 1 --bootstrap-server ...
kafka-console-consumer.sh --topic t1 --from-beginning --bootstrap-server ...
kafka-console-producer.sh --topic t1 --bootstrap-server ...
kafka-consumer-groups.sh --describe --group g1 --bootstrap-server ...
```

### kcat
유연한 Kafka CLI (Avro/Schema Registry 지원).
```bash
kcat -b localhost:9092 -L                # 메타 나열
kcat -b localhost:9092 -t topic -C       # consume
kcat -b localhost:9092 -t topic -P < msg # produce
kcat -b ... -s avro -r http://sr:8081 -C # Avro + SR
```

---

## 컨테이너 / Kubernetes

### docker (Docker Desktop에 포함)
```bash
docker ps / docker ps -a
docker images
docker run -it --rm alpine sh
docker exec -it CONTAINER sh
docker logs -f CONTAINER
docker compose up -d / docker compose logs -f
docker system prune -a                    # 정리
```

### lazydocker
Docker TUI. alias: `lzd`.

### kubectl
```bash
kubectl get pods -A
kubectl describe pod PODNAME
kubectl logs -f POD -c CONTAINER
kubectl exec -it POD -- sh
kubectl port-forward svc/api 8080:80
kubectl apply -f manifest.yaml
kubectl rollout restart deployment/api
kubectl top pods / kubectl top nodes
```

### kubectx / kubens
```bash
kubectx                                   # 컨텍스트 목록
kubectx dev-cluster                       # 전환
kubens kube-system                        # 네임스페이스 전환
```

### k9s
Kubernetes TUI.
- `?` 도움말, `0-9` 리소스 전환, `:` 명령 모드
- `l` 로그, `d` describe, `Ctrl-k` kill

### helm
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-release bitnami/mysql
helm upgrade --install r chart -f values.yaml
helm list
helm uninstall my-release
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
aws s3 ls
aws s3 cp file.tgz s3://bucket/
aws ec2 describe-instances
aws ecr get-login-password | docker login --username AWS --password-stdin <ecr-url>
aws logs tail log-group --follow
aws sts get-caller-identity              # 현재 자격증명 확인
```

### saml2aws
SAML SSO → AWS 임시 자격증명.
```bash
saml2aws configure                       # 최초 설정
saml2aws login                           # 자격증명 획득
saml2aws login --role=arn:aws:iam::...   # 역할 지정
```

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
- Font는 ghostty config 상속 (cmux가 libghostty를 임베드)

### starship
크로스쉘 프롬프트. 설정: `~/.config/starship.toml`.

### font (Nerd Fonts)
- **MesloLG Nerd Font** — UI 폴백, 아이콘
- **D2CodingLigature Nerd Font** — 한글 + 프로그래밍 합자 (`->`, `=>`, `!=`)

---

## GUI 앱 (macOS)

### Raycast
Spotlight 대체. 설치 후 ⌘+Space를 Raycast에 넘김.

추천 extension:
- Clipboard History
- Window Management
- GitHub (PR/issue 검색)
- Jira (티켓 검색)
- Kill Process

---

## Unix 기본 명령어

엔지니어가 일상에서 자주 쓰는 POSIX/macOS 기본 도구들.

### awk
컬럼 기반 텍스트 처리.
```bash
awk '{print $1}' file.txt                # 첫 컬럼
awk -F',' '{print $2}' data.csv          # 구분자 지정
ps aux | awk '$3 > 50'                    # CPU 50% 초과 프로세스
awk 'NR>1 {sum+=$3} END {print sum}' f    # 헤더 제외 합계
df -h | awk 'NR>1 {print $5, $NF}'        # 여러 컬럼
```

### sed
stream editor (치환 주력).
```bash
sed 's/foo/bar/g' file.txt                # 출력만
sed -i '' 's/foo/bar/g' file.txt          # 인플레이스 (macOS 문법)
sed -n '10,20p' file.txt                  # 10~20줄만
sed '/pattern/d' file.txt                 # 매칭 라인 삭제
```

### grep
패턴 검색 (ripgrep 쓸 수 없을 때).
```bash
grep -r "pattern" dir/
grep -iE "foo|bar" file
grep -A3 -B2 "x" file                     # 주변 라인
grep -v "exclude" file                    # 역매칭
grep -c "x" file                          # 카운트
```

### find
파일 검색 (fd 쓸 수 없을 때, POSIX 표준).
```bash
find . -name "*.py"
find . -type f -mtime -7                  # 7일 이내 수정
find . -size +10M                          # 10MB 이상
find . -name "*.log" -exec rm {} \;        # 일괄 삭제
find . -name "*.js" -print0 | xargs -0 grep "pattern"
```

### curl / wget (위 네트워크 섹션 참고)

### ssh / scp / rsync
```bash
ssh user@host
scp file user@host:/path/
scp -r dir/ user@host:/path/
rsync -avz --progress ./dir/ user@host:/path/
rsync -avz --delete src/ dst/             # src 기준 동기화, dst 잉여 삭제
```

### tar / gzip
```bash
tar czvf archive.tgz dir/                 # 압축
tar xzvf archive.tgz                      # 해제
tar tzvf archive.tgz                      # 목록만
tar czvf - dir/ | ssh host "cat > /tmp/x" # 스트리밍
gzip file / gunzip file.gz
```

### ps / kill / pgrep / pkill
```bash
ps aux | grep node
pgrep -f "node"                          # 이름 패턴 → PID
pgrep -fl "node"                         # PID + 커맨드 라인
kill -9 PID
pkill -f "node server"                    # 패턴 매칭 kill
```

### lsof
열린 파일/소켓/포트.
```bash
lsof -i :8080                            # 8080 쓰는 프로세스
lsof -i tcp                              # 모든 TCP
lsof -p PID                              # 특정 PID
lsof +D /some/dir                         # 그 디렉토리 여는 프로세스
```

### df / du
```bash
df -h                                     # 마운트별 디스크 사용량
du -sh dir/                               # 디렉토리 크기
du -h --max-depth=1 .                     # 1단계까지
du -sh * | sort -rh                       # 큰 순 정렬
```

### xargs
stdin → 인자로 변환.
```bash
cat urls.txt | xargs -I{} curl {}
find . -name '*.pyc' | xargs rm
echo "a b c" | xargs -n1                  # 개별 인자로
ls | xargs -P4 -I{} gzip {}              # 병렬 4개
```

### tee
stdin → 파일 + stdout 동시.
```bash
command | tee output.log
command | tee -a append.log               # append
make 2>&1 | tee build.log                  # stderr도 포함
```

### cut / sort / uniq / wc / tr / head / tail
```bash
cut -d',' -f2,4 data.csv                  # 2,4 컬럼
cut -c1-10 file                            # 1~10 글자
sort file / sort -n / sort -k2             # 숫자 / 2번째 키
sort | uniq -c | sort -rn                  # 빈도 카운트
wc -l file / wc -w file                    # 라인/단어 수
echo "ABC" | tr 'A-Z' 'a-z'                # 소문자 변환
head -n 20 file / tail -n 20 file
tail -f log.txt                            # follow
tail -F log.txt                            # 로테이션 따라감
```

### diff / patch
```bash
diff -u a.txt b.txt > changes.patch
patch < changes.patch                      # 적용
diff -r dir1/ dir2/                        # 디렉토리 비교
```

### nc (netcat)
```bash
nc -zv host 22                             # 포트 열림 확인
nc -l 8080                                 # 8080에서 listen
echo "GET / HTTP/1.0" | nc host 80        # 수동 요청
```

### date / cal
```bash
date                                       # 로컬 시간
date -u +%FT%TZ                            # UTC ISO 8601
date -r EPOCH                               # epoch → 사람 시간 (macOS)
cal / cal 2026 / cal -3
```

### chmod / chown / ln
```bash
chmod +x script.sh
chmod 755 dir/
chmod -R u+rw dir/                         # 재귀 + 사용자에게 rw
chown user:group file
ln -s target link_name                      # 심볼릭 링크
```

### env / export / printenv
```bash
env | sort                                 # 모든 환경변수
printenv PATH
export VAR=value
unset VAR
```

### man / which / type / file
```bash
man curl
which python                               # 실행 파일 경로
type ls                                    # alias/builtin/file 구분
file /bin/bash                             # 파일 종류
```

### history
```bash
history | grep ssh
!!                                          # 직전 명령 재실행
!$                                          # 직전 명령의 마지막 인자
!ssh                                        # 마지막 ssh 시작 명령 재실행
```

### jobs / bg / fg / disown / nohup
```bash
command &                                   # 백그라운드 실행
jobs                                         # 실행 중 작업
fg %1                                        # 1번 작업 포그라운드로
Ctrl-Z → bg                                  # 일시정지 → 백그라운드
nohup long-command > out.log 2>&1 &         # 로그아웃 후에도 유지
disown %1                                    # 현재 셸과 분리
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

# cd → zoxide (학습된 디렉토리 점프)
eval "$(zoxide init zsh --cmd cd)"

# Ctrl-R → atuin
eval "$(atuin init zsh --disable-up-arrow)"

# fzf 키바인딩
source <(fzf --zsh)

# mise 활성화
eval "$(mise activate zsh)"

# starship 프롬프트
eval "$(starship init zsh)"
```

### Git (`~/.gitconfig`)
```
pager = delta (side-by-side)
merge conflictstyle = zdiff3
alias:
  dft = -c diff.external=difft diff
  dlog = -c diff.external=difft log --ext-diff
  dshow = -c diff.external=difft show --ext-diff
```

### mise 환경 프로파일 (`~/.config/mise/config.{env}.toml`)
```bash
MISE_ENV=local mise env         # DB_USER/HOST/PASS 주입
MISE_ENV=dev   ...
MISE_ENV=prod  ...
```

---

## 빠른 치트시트

### 로그 분석 파이프라인
```bash
cat app.log \
  | rg "ERROR" \
  | jq -R 'fromjson?' \
  | jq 'select(.level == "error") | .msg' \
  | sort | uniq -c | sort -rn | head
```

### HTTP 상태 코드 빈도
```bash
awk '{print $9}' access.log | sort | uniq -c | sort -rn
```

### 프로세스 메모리 상위 10
```bash
ps aux | sort -rk4 | head
```

### 포트 점유 프로세스 찾기
```bash
lsof -i :3000
```

### 디스크 큰 파일 찾기
```bash
du -sh * | sort -rh | head
fd -t f -S +100M                           # 100MB 이상 파일
```

### 대량 파일 병렬 처리
```bash
fd -e log | xargs -P8 -I{} gzip {}
```

### JSON API 응답 탐색
```bash
curl -s https://api.github.com/users/USER | jq
curl -s https://api.github.com/users/USER | jless   # jless 설치 시
```

### Kafka 토픽 빠른 확인
```bash
kcat -b broker:9092 -t topic -C -e -c 10   # 마지막 10개 메시지
```

### k8s 디버깅
```bash
kubectl get pods -A | grep -i error
kubectl describe pod POD | less
stern POD-prefix --since 10m                # stern 설치 시
```

---

## 더 공부할 곳

- [ripgrep 매뉴얼](https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md)
- [jq tutorial](https://stedolan.github.io/jq/tutorial/)
- [tmux cheatsheet](https://tmuxcheatsheet.com/)
- [just manual](https://just.systems/man/en/)
- [mise docs](https://mise.jdx.dev/)
- [uv docs](https://docs.astral.sh/uv/)
- [Raycast Store](https://www.raycast.com/store)

---

*이 문서는 chezmoi 소스의 `docs/tools-guide.md`에 있으며, `docs/`는 `.chezmoiignore`에 의해 홈 디렉토리로 동기화되지 않음. 편집은 `chezmoi cd → docs/tools-guide.md`.*
