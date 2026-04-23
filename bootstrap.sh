#!/usr/bin/env bash
# hyounoh/dotfiles bootstrap — set up personal SSH key, register at GitHub,
# then install chezmoi and apply the private dotfiles repo.
#
# Public mirror (for curl|bash on fresh machines) kept in sync at:
#   https://gist.github.com/hyounoh/38d3fcec52d6d194c69f2150a5aab089
# When this file changes, paste the updated contents into that gist.

set -euo pipefail

REPO_URL="git@github-personal:hyounoh/dotfiles.git"
SSH_KEY_PATH="$HOME/.ssh/id_ed25519_personal"
SSH_KEY_COMMENT="hyounoh-personal"
GITHUB_SSH_URL="https://github.com/settings/ssh/new"

say() { printf "\033[1;34m[bootstrap]\033[0m %s\n" "$*"; }
err() { printf "\033[1;31m[error]\033[0m %s\n" "$*" >&2; exit 1; }

# ── OS check ───────────────────────────────────────────────
[[ "$(uname)" == "Darwin" ]] || err "macOS 전용 (현재: $(uname))"

# ── 1. 개인 SSH 키 ─────────────────────────────────────────
if [[ ! -f "$SSH_KEY_PATH" ]]; then
  say "개인 SSH 키 생성 중 ($SSH_KEY_PATH)"
  mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
  ssh-keygen -t ed25519 -f "$SSH_KEY_PATH" -C "$SSH_KEY_COMMENT" -N ""
else
  say "개인 SSH 키 이미 존재: $SSH_KEY_PATH"
fi

# ── 2. 공개키를 GitHub에 등록 ──────────────────────────────
echo
cat "$SSH_KEY_PATH.pub"
echo
if command -v pbcopy >/dev/null 2>&1; then
  pbcopy < "$SSH_KEY_PATH.pub"
  say "공개키가 클립보드에 복사됐습니다."
fi
say "GitHub SSH 설정 페이지를 엽니다. 키를 붙여넣고 저장하세요."
open "$GITHUB_SSH_URL" 2>/dev/null || true
read -r -p "등록 완료 후 Enter를 누르세요... " _

# ── 3. 임시 SSH config ─────────────────────────────────────
if ! grep -q "Host github-personal" "$HOME/.ssh/config" 2>/dev/null; then
  say "임시 SSH config에 github-personal alias 추가"
  touch "$HOME/.ssh/config"
  chmod 600 "$HOME/.ssh/config"
  cat >> "$HOME/.ssh/config" <<EOF

Host github-personal
  HostName github.com
  User git
  IdentityFile $SSH_KEY_PATH
EOF
else
  say "SSH config의 github-personal alias 이미 존재"
fi

# ── 4. SSH 인증 테스트 ────────────────────────────────────
say "GitHub SSH 인증 확인 중..."
if ! ssh -o StrictHostKeyChecking=accept-new -T git@github-personal 2>&1 \
      | grep -q "successfully authenticated"; then
  err "SSH 인증 실패. 공개키가 GitHub에 등록됐는지 확인하세요."
fi
say "SSH 인증 성공"

# ── 5. chezmoi 설치 + 적용 ─────────────────────────────────
say "chezmoi 설치 및 dotfiles 적용 (수 분 소요)"
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply "$REPO_URL"

# ── 6. 안내 ───────────────────────────────────────────────
echo
say "부트스트랩 완료. 후속 수동 단계:"
cat <<'EOF'
  1. 새 셸 띄우기 (zsh plugins/aliases 로드)
  2. mise install                        # 언어 런타임 설치 (mise.lock 기반)
  3. $EDITOR ~/.zshrc.d/secrets.zsh       # 시크릿 값 채우기
  4. (회사 머신) 회사 GitHub 계정용 SSH 키 별도 생성 + 등록
EOF
