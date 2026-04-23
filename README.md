# dotfiles

chezmoi로 관리하는 개발 환경 설정. 이 저장소는 **private**이므로 새 맥에서
부트스트랩하려면 개인 GitHub 계정의 SSH 키가 먼저 등록돼 있어야 한다.

## 새 맥 부트스트랩

### 1) 개인 SSH 키 생성 + GitHub 등록

```bash
# (이미 생성돼 있으면 skip)
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_personal -C "hyounoh-personal" -N ""

# 공개키 복사 후 GitHub에 등록
pbcopy < ~/.ssh/id_ed25519_personal.pub
open https://github.com/settings/ssh/new
```

GitHub 페이지에서 키 붙여넣고 저장.

### 2) 임시 SSH config (chezmoi가 이후 덮어씀)

```bash
mkdir -p ~/.ssh && chmod 700 ~/.ssh
cat >> ~/.ssh/config <<'EOF'
Host github-personal
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_personal
EOF
```

### 3) chezmoi init

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply \
  git@github-personal:hyounoh/dotfiles.git
```

프롬프트:
- `machine profile [work,personal]`: 머신 용도 선택
- `git user.name` / `git user.email`: 기본값 표시됨, Enter로 수락

자동 실행되는 것:
- dotfiles 배치 (`.zshrc`, `.vimrc`, `.gitconfig`, mise config 등)
- Homebrew 설치 (없으면)
- Brewfile 기반 46개 패키지 설치
- oh-my-zsh 설치
- `~/.zshrc.d/secrets.zsh` 템플릿 생성 (관리 밖, 머신별 값)

### 4) 후속 수동 단계

```bash
# 언어 런타임 설치 (mise.lock 기반)
mise install

# 머신별 시크릿 값 채우기
$EDITOR ~/.zshrc.d/secrets.zsh

# 회사 머신이면: 회사 GitHub 계정용 SSH 키도 별도 생성/등록
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "hyounoh@users.noreply.github.com"
```

## 프로파일과 git identity

| profile | 기본 identity | 특이사항 |
|---------|--------------|----------|
| `work` | `hyounoh <hyounoh@users.noreply.github.com>` | `github-personal:` 원격 repo만 개인 identity로 자동 오버라이드 |
| `personal` | `hyounoh <hyounoh@users.noreply.github.com>` | 모든 repo에서 개인 identity |

오버라이드는 `~/.gitconfig`의 `[includeIf "hasconfig:remote.*.url:git@github-personal:*/**"]`로 구현. Git 2.36 이상 필요.

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
