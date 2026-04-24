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
- Homebrew 설치 (없으면)
- Brewfile 기반 46개 패키지 설치
- oh-my-zsh 설치
- `~/.zshrc.d/secrets.zsh` 템플릿 생성 (관리 밖, 머신별 값)

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
- `docs/` — 메모/가이드
- `README.md` — 이 파일
- `~/.zshrc.d/secrets.zsh` — 아예 추가하지 않음 (머신별 시크릿)
- `~/.ssh/id_ed25519*` — 개인키는 관리 밖
