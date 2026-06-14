# dotfiles

chezmoi로 관리하는 개발 환경 설정.

## 새 맥 부트스트랩

한 줄로:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/hyounoh/dotfiles/main/bootstrap.sh)
```

스크립트 동작:
1. **profile 선택** — `personal` (내 개인 맥, read/write) vs `work` (회사 맥, read-only)
2. `personal`: SSH 키 생성 (`~/.ssh/id_ed25519_personal`) → 개인 계정 SSH Key 등록 → SSH config 작성 + 인증 테스트
   `work`: SSH 불필요 — HTTPS로 public repo clone
3. chezmoi 설치 + `init --apply --promptChoice profile=<선택값>`

init 중 추가 프롬프트:
- `git user.name` / `git user.email` — 두 프로필 모두 기본값 없음. 프로필에 맞는
  이름/이메일을 명시적으로 입력 (personal은 개인 계정, work는 회사 계정).

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

# Karabiner-Elements — sudo 프롬프트 필요한 cask라 Brewfile에서 제외됨.
# 대화형 터미널에서 직접 설치 (설치 후 시스템 설정에서 접근성 권한 승인):
brew install --cask karabiner-elements
```

## 프로파일과 git identity

| profile | 용도 | dotfiles 접근 | `~/.gitconfig` identity | push |
|---------|------|--------------|------------------------|------|
| `personal` | 개인 맥 | SSH (`git@github-personal`) | 프롬프트 입력값 (개인 계정) | ✅ |
| `work` | 회사 맥 | HTTPS (public repo) | 프롬프트 입력값 (소속마다 다름) | ❌ |

### 설계 원칙
회사 맥은 **소비 전용(pull-only)**. 편집/커밋은 개인 맥에서만 하고, 회사 맥은 `chezmoi update`로 받아쓰기만.

소스는 **회사 중립적(company-agnostic)**. 특정 회사 이름/이메일이 소스에 하드코딩돼 있지 않아,
이직해도 소스 수정 없이 같은 부트스트랩 흐름으로 새 회사 맥을 세팅할 수 있음.

### 회사 맥에서 편집해야 할 일이 생기면
- dotfiles 내용 수정 → diff 저장 → 개인 맥으로 전달 → 거기서 commit/push

## 이직 시 체크리스트 / 새 회사 맥 개발 세팅

### Phase A — chezmoi 부트스트랩 (필수 기본기)

1. **부트스트랩 1줄** 실행 → profile은 `work` 선택 (HTTPS로 clone, SSH 불필요)
2. `git user.name` / `git user.email` 프롬프트에 **새 회사 정보** 입력
3. Karabiner 수동 설치 (Brewfile에 없음, sudo 프롬프트 필요):
   ```bash
   brew install --cask karabiner-elements
   # 시스템 설정 → 개인정보 보호 및 보안 → 접근성 / 입력 모니터링에서
   # Karabiner-Elements, karabiner_grabber, karabiner_observer 승인
   ```
4. `mise install` — 언어 런타임 설치 (mise.lock 기반, Java/Kotlin/Python/Node/Go/TS)

### Phase B — 회사 Git 계정 연결

5. **회사용 SSH 키** 생성 + 회사 GitHub/GHE에 등록:
   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "email@company.co.kr"
   pbcopy < ~/.ssh/id_ed25519.pub
   # 회사 GHE 또는 github.com 계정의 SSH Keys에 붙여넣기
   ```
6. **`~/.ssh/config`에 회사 host alias 추가** (chezmoi 관리 밖이라 자유 편집):
   ```ssh-config
   Host <회사-alias>
     HostName <회사-GHE-호스트>
     User git
     IdentityFile ~/.ssh/id_ed25519
     IdentitiesOnly yes
   ```
7. **`gh` CLI 회사 인증**:
   ```bash
   gh auth login --hostname <회사-GHE-호스트>
   ```

### Phase C — AWS / 클라우드 접근 (해당 시)

8. **SAML SSO → 임시 자격증명**:
   ```bash
   saml2aws configure                         # 최초 설정
   saml2aws login
   aws sts get-caller-identity                # 검증
   ```
9. **Docker ECR 자동 로그인** (`~/.docker/config.json`):
   ```json
   { "credHelpers": { "<account>.dkr.ecr.<region>.amazonaws.com": "ecr-login" } }
   ```
10. **K8s 클러스터 등록** (EKS 기준):
    ```bash
    aws eks update-kubeconfig --name <cluster> --region <region>
    kubectl config get-contexts
    ```

### Phase D — 추가 개발 도구

11. **Docker Desktop** (Brewfile 밖):
    ```bash
    brew install --cask docker
    open -a Docker    # 최초 실행 권한 승인, 리소스 할당 조정
    ```

### Phase E — 프로젝트 & 시크릿

13. **머신별 시크릿 채우기** — `$EDITOR ~/.zshrc.d/secrets.zsh`
    (예: `DATABASE_URL`, `REDIS_URL`, `ANTHROPIC_BASE_URL`, 회사 프록시 등)
14. **프로젝트 repo clone + 빌드**:
    ```bash
    git clone git@<회사-alias>:<org>/<repo>.git
    cd <repo>
    mise install                                # 프로젝트 mise.toml 있으면
    ./gradlew build
    docker compose up -d                         # 로컬 DB/Redis 필요 시
    ```

### Phase F — 회사 정책 종속

15. VPN, 1Password, MFA 도구 등 회사 요구사항

---

### 구 회사 맥 정리 (이직 후 반납 전)

- `~/.zshrc.d/secrets.zsh` 확인 후 제거 (회사 자격증명 남아있으면 안 됨)
- 회사 SSH 키 삭제 (`~/.ssh/id_ed25519*`)

### 예상 소요 시간

| Phase | 소요 |
|-------|------|
| A (chezmoi + Karabiner + mise) | ~15분 |
| B (회사 Git) | ~10분 |
| C (AWS/K8s) | ~20분 (팀별 편차 큼) |
| D (Docker) | ~15분 |
| E (프로젝트 빌드) | 프로젝트별 (대개 ~30분) |
| F (사내 도구) | 회사 정책별 |
| **Phase A~E 합계** | **약 1.5~2시간** |

매 이직마다 위 절차가 **동일** — 개인 dotfiles가 변하지 않기 때문. 회사별 차이는 Phase B/C/E에만 존재.

## mise — 런타임 버전 + 환경변수

### 전역 vs 프로젝트 런타임

`~/.config/mise/config.toml`이 머신 전체 기본 런타임을 정의 (java 21, kotlin 2.3,
python 3.13, node 22, go 1.25). Phase A의 `mise install`이 이걸 채움.

repo clone 후의 `mise install`은 그 repo의 `.mise.toml` / `.tool-versions` /
legacy 파일(`.java-version` 등)을 읽어 **부족한 것만** 채우는 멱등 명령.
PATH는 mise shim이 프록시하므로 디렉터리 진입/이탈 시 JDK·Node 버전이 자동 전환됨.

### 프로젝트에 mise 파일이 없을 때

대부분의 기존 Java/Kotlin repo는 `.mise.toml`이 없음. 동작은 이렇게 분기:

- **전역 설정이 fallback** — `mise install`은 사실상 no-op. 전역 버전이
  프로젝트 요구와 같으면 그대로 빌드 가능.
- **프로젝트 요구 버전이 전역과 다르면** `mise use`로 직접 핀:
  ```bash
  cd <repo>
  mise use java=temurin-17   # .mise.toml 생성 + 설치 + 활성화를 한 번에
  ```
  여러 프로젝트의 JDK 버전이 섞여 있으면(예: 일부 17, 일부 21) repo마다
  핀을 박아두면 디렉터리 전환만으로 JDK가 바뀌어 전환 비용 0.
- **Gradle toolchain이 선언된 repo**는 Gradle이 알아서 필요한 JDK를 다운받음.
  `build.gradle.kts`의 `jvmToolchain(...)` 또는 `languageVersion` 확인.
  이 경우 mise 개입 불필요.

clone 직후 판정용:
```bash
ls .mise.toml .tool-versions 2>/dev/null
grep -E "jvmToolchain|languageVersion" build.gradle.kts 2>/dev/null
```

### 환경변수 프로파일

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

- `docs/tools-guide.md` — CLI 도구 카탈로그(Brewfile) + Unix 기본 명령어 + 백엔드 엔지니어 파이프라인 패턴 통합 레퍼런스
