# dotfiles

chezmoi로 관리하는 개발 환경 설정. 이 저장소는 **private**이므로 새 맥에서
부트스트랩하려면 개인 GitHub 계정의 SSH 키가 먼저 등록돼 있어야 한다.

## 새 맥 부트스트랩

한 줄로:

```bash
bash <(curl -fsSL https://gist.githubusercontent.com/hyounoh/38d3fcec52d6d194c69f2150a5aab089/raw/bootstrap.sh)
```

스크립트 동작:
1. **profile 선택** — `personal` (내 개인 맥, read/write) vs `work` (회사 맥, read-only)
2. SSH 키 생성 (`~/.ssh/id_ed25519_personal`)
3. 공개키 클립보드 복사 + GitHub 등록 페이지 자동 오픈:
   - personal → 개인 계정 SSH Key 등록
   - work → dotfiles repo **Deploy Key** 등록 (write 권한 체크 해제)
4. 임시 SSH config 작성 + 인증 테스트 (이후 chezmoi가 건드리지 않음 — 자유 편집 가능)
5. chezmoi 설치 + `git@github-personal:hyounoh/dotfiles.git` 기반 `init --apply --promptChoice profile=<선택값>`

init 중 추가 프롬프트:
- `git user.name` / `git user.email`:
  - personal profile → 개인 기본값(`hyounoh` / `hyounoh@users.noreply.github.com`) 제안, Enter로 수락
  - work profile → 기본값 없음, 현재 회사 이메일/이름 명시적으로 입력

자동 실행되는 chezmoi scripts:
- Homebrew 설치 (없으면) — `run_once_01`
- Brewfile 기반 패키지 일괄 설치 — `run_onchange_02` (Brewfile 해시 변경 시 재실행)
- oh-my-zsh 설치 — `run_once_03`
- `~/.zshrc.d/secrets.zsh` 템플릿 생성 — `run_once_04`
- macOS defaults 적용 (키보드/트랙패드 등) — `run_onchange_05`

### 후속 수동 단계

```bash
# 새 셸 띄우기 (zsh plugins/aliases 로드)

# 언어 런타임 설치 (mise.lock 기반)
mise install

# 머신별 시크릿 값 채우기
$EDITOR ~/.zshrc.d/secrets.zsh

# 회사 머신이면: 회사 GitHub 계정용 SSH 키도 별도 생성/등록
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "hyounoh@your-company.co.kr"
```

### bootstrap.sh 수정 시 주의

저장소 루트의 `bootstrap.sh`를 수정하면 위 gist 내용도 수동 갱신해야 함
(gist는 별도 public mirror). gist URL: https://gist.github.com/hyounoh/38d3fcec52d6d194c69f2150a5aab089

## 프로파일과 git identity

| profile | 용도 | 키 종류 | `~/.gitconfig` identity | push |
|---------|------|---------|------------------------|------|
| `personal` | 개인 맥 | 개인 계정 SSH Key | 기본값: `hyounoh <hyounoh@users.noreply.github.com>` | ✅ |
| `work` | 회사 맥 | dotfiles repo Deploy Key | 프롬프트 입력값 (소속마다 다름) | ❌ (서버 차단) |

### 설계 원칙
회사 맥은 **소비 전용(pull-only)**. 편집/커밋은 개인 맥에서만 하고, 회사 맥은 `chezmoi update`로 받아쓰기만.
Deploy Key는 서버 레벨에서 push를 거부하므로, 회사 맥에서 git identity override 같은 복잡한 설정이 불필요함.

소스는 **회사 중립적(company-agnostic)**. 특정 회사 이름/이메일이 소스에 하드코딩돼 있지 않아,
이직해도 소스 수정 없이 같은 부트스트랩 흐름으로 새 회사 맥을 세팅할 수 있음.

### 회사 맥에서 편집해야 할 일이 생기면
- dotfiles 내용 수정 → diff 저장 → 개인 맥으로 전달 → 거기서 commit/push
- 또는 임시로 deploy key를 write 권한으로 업그레이드 (비권장)

## 이직 시 체크리스트

새 회사 맥을 받으면:
1. 부트스트랩 1줄 실행 → profile은 `work` 선택
2. `git user.name` / `git user.email` 프롬프트에 **새 회사 정보** 입력
3. `~/.ssh/config`에 새 회사 GHE 호스트 + 키 추가 (이 파일은 chezmoi가 관리 안 하므로 자유 편집)
4. `~/.zshrc.d/secrets.zsh`에 새 회사 전용 환경변수/시크릿 채우기

구 회사 맥을 더 안 쓰게 되면:
- 개인 dotfiles repo의 Deploy Keys에서 해당 머신 키 삭제:
  https://github.com/hyounoh/dotfiles/settings/keys

## 환경변수 프로파일 (mise)

DB 접속정보는 `~/.config/mise/config.{local,dev,prod}.toml`에 템플릿으로 존재:

```bash
export MISE_ENV=dev        # or local, prod
echo $DB_USER              # 해당 환경 값 주입
```

## macOS 시스템 설정 자동화

`run_onchange_05-macos-defaults.sh`가 시스템 defaults를 **idempotent하게** 적용.
각 설정이 독립적으로 시도되며, 하나가 실패해도 다른 항목은 계속 적용됨.
실패 시 어느 항목이 실패했는지 요약 리포트.

현재 포함된 항목:
- 키보드 단축키
  - ⌃Space (이전 입력 소스) 비활성
  - 다음 입력 소스를 **F18**로 (Karabiner의 Right Command → F18과 연동 → 한/영 전환)
  - Spotlight ⌘Space / ⌘⌥Space 비활성 (Raycast가 대체)
  - F1/F2 등을 표준 function 키로
- 키 반복 속도: `KeyRepeat=2`, `InitialKeyRepeat=15`, `ApplePressAndHoldEnabled=false`
- 트랙패드 탭 클릭: 내장 + Bluetooth 양쪽

Karabiner 프로파일은 `private_dot_ssh`와 동일한 0600 패턴으로 `dot_config/private_karabiner/`에 관리. 최초 실행 시 macOS 접근성 권한 수동 부여 필요.

## git 구조적 diff (difftastic)

AST 기반 구조적 diff는 `~/.gitconfig`의 alias로 제공:

```bash
git dft HEAD~3            # 구조적 diff
git dlog                   # 구조적 log
git dshow COMMIT           # 구조적 show
```
기본 `git diff`는 여전히 `delta`(line-based + 사이드바이사이드).

## 일상 사용

```bash
chezmoi edit ~/.zshrc       # 설정 편집 (소스 파일을 에디터로 오픈)
chezmoi apply               # 변경사항 홈으로 반영
chezmoi diff                # 적용 전 미리보기
chezmoi status              # 변경 필요한 파일 리스트
chezmoi add ~/.config/xxx   # 새 파일을 관리 대상에 추가
chezmoi cd                  # 소스 디렉토리로 이동 (git push 등)
chezmoi update              # git pull + apply
chezmoi re-add ~/.zshrc     # 홈에서 편집한 내용을 역으로 소스에 반영
```

## 관리 제외 파일

`.chezmoiignore` 참고. 대표:
- `Brewfile` — 소스엔 있지만 홈엔 배치 안 됨 (스크립트가 직접 참조)
- `bootstrap.sh` — 새 맥 부트스트랩 스크립트, 홈 배치 불필요
- `docs/` — 메모/가이드 (`docs/tools-guide.md` 포함)
- `README.md` — 이 파일
- `~/.ssh/config` — bootstrap이 초기 1회 작성 후 사용자 소유 (회사 GHE 추가 자유)
- `~/.zshrc.d/secrets.zsh` — 아예 추가하지 않음 (머신별 시크릿)
- `~/.ssh/id_ed25519*` — 개인키는 관리 밖

## 참고 문서

- `docs/tools-guide.md` — 설치된 모든 도구(Brewfile) + Unix 기본 명령어에 대한 빠른 레퍼런스
- `docs/terminal-engineering-guide.md` — 터미널 엔지니어링 가이드
