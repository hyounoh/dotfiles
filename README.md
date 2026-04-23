# dotfiles

chezmoi로 관리하는 개발 환경 설정. 이 저장소는 **private**이므로 새 맥에서
부트스트랩하려면 개인 GitHub 계정의 SSH 키가 먼저 등록돼 있어야 한다.

## 새 맥 부트스트랩

한 줄로:

```bash
bash <(curl -fsSL https://gist.githubusercontent.com/hyounoh/38d3fcec52d6d194c69f2150a5aab089/raw/gistfile1.txt)
```

스크립트가 자동으로 해주는 것:
1. 개인 SSH 키 생성 (`~/.ssh/id_ed25519_personal`)
2. 공개키를 클립보드에 복사 + GitHub SSH 설정 페이지 오픈
3. 사용자가 키 등록하면 Enter → 임시 SSH config 작성 + 인증 테스트
4. chezmoi 설치 + `git@github-personal:hyounoh/dotfiles.git` 기반 `init --apply`

init 중 프롬프트:
- `machine profile [work,personal]`: 머신 용도 선택
- `git user.name` / `git user.email`: 기본값 표시됨, Enter로 수락

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
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "hyounoh@users.noreply.github.com"
```

### bootstrap.sh 수정 시 주의

저장소 루트의 `bootstrap.sh`를 수정하면 위 gist 내용도 수동 갱신해야 함
(gist는 별도 public mirror). gist URL: https://gist.github.com/hyounoh/38d3fcec52d6d194c69f2150a5aab089

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
