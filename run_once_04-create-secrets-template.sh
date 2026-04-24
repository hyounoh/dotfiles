#!/usr/bin/env bash
set -euo pipefail

SECRETS="$HOME/.zshrc.d/secrets.zsh"
if [[ ! -f "$SECRETS" ]]; then
  mkdir -p "$HOME/.zshrc.d"
  cat > "$SECRETS" <<'EOF'
# 이 파일은 chezmoi 관리 대상이 아닙니다.
# 머신/회사별 환경변수와 시크릿을 여기에 추가하세요.
#
# 예시:
# export ANTHROPIC_BASE_URL="..."
# export DB_USER="..."
# export DB_HOST="..."
# export DB_PASS="..."
EOF
  echo "[INFO] secrets 템플릿 생성: $SECRETS"
else
  echo "[SKIP] secrets.zsh 이미 존재"
fi
