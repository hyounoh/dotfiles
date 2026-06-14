#!/usr/bin/env bash
# hyounoh/dotfiles bootstrap — set up a new Mac with chezmoi-managed dotfiles.
# personal: generates SSH key for GitHub account (read/write push access)
# work:     uses HTTPS (public repo, no auth needed for read-only pull)

set -euo pipefail

PERSONAL_REPO_URL="git@github-personal:hyounoh/dotfiles.git"
HTTPS_REPO_URL="https://github.com/hyounoh/dotfiles.git"
SSH_KEY_PATH="$HOME/.ssh/id_ed25519_personal"

say() { printf "\033[1;34m[bootstrap]\033[0m %s\n" "$*"; }
err() { printf "\033[1;31m[error]\033[0m %s\n" "$*" >&2; exit 1; }

# ── OS check ───────────────────────────────────────────────
[[ "$(uname)" == "Darwin" ]] || err "macOS 전용 (현재: $(uname))"

# ── 0. Profile 선택 ────────────────────────────────────────
echo
echo "이 머신 용도를 선택하세요:"
echo "  1) personal  — 내 개인 맥 (read/write, 개인 GitHub 계정 SSH 키)"
echo "  2) work      — 회사 맥 (read-only, HTTPS clone)"
echo
read -r -p "[1/2, 기본 1]: " choice
case "${choice:-1}" in
  1) PROFILE="personal" ;;
  2) PROFILE="work" ;;
  *) err "잘못된 선택: $choice" ;;
esac
say "선택된 profile: $PROFILE"

if [[ "$PROFILE" == "personal" ]]; then
  # ── 1. SSH 키 생성 ─────────────────────────────────────────
  if [[ ! -f "$SSH_KEY_PATH" ]]; then
    say "SSH 키 생성 중 ($SSH_KEY_PATH)"
    mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
    ssh-keygen -t ed25519 -f "$SSH_KEY_PATH" -C "hyounoh-personal" -N ""
  else
    say "SSH 키 이미 존재: $SSH_KEY_PATH"
  fi

  # ── 2. 공개키를 GitHub에 등록 ──────────────────────────────
  echo
  cat "$SSH_KEY_PATH.pub"
  echo
  if command -v pbcopy >/dev/null 2>&1; then
    pbcopy < "$SSH_KEY_PATH.pub"
    say "공개키가 클립보드에 복사됐습니다."
  fi
  say "GitHub SSH 등록 페이지를 엽니다: https://github.com/settings/ssh/new"
  echo "  Title 입력, Key에 공개키 붙여넣기"
  open "https://github.com/settings/ssh/new" 2>/dev/null || true
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
  IdentitiesOnly yes
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

  REPO_URL="$PERSONAL_REPO_URL"
else
  REPO_URL="$HTTPS_REPO_URL"
fi

# ── 5. chezmoi 설치 + 적용 ─────────────────────────────────
say "chezmoi 설치 및 dotfiles 적용 (수 분 소요)"
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply \
  --promptChoice "profile=$PROFILE" \
  "$REPO_URL"

# ── 6. 안내 ───────────────────────────────────────────────
echo
say "부트스트랩 완료. 후속 수동 단계:"
cat <<'EOF'
  1. 새 셸 띄우기 (zsh plugins/aliases 로드)
  2. $EDITOR ~/.zshrc.d/secrets.zsh        # 시크릿 값 채우기
  3. (회사 맥) 회사 GitHub 계정용 SSH 키 별도 생성 + 등록
EOF
