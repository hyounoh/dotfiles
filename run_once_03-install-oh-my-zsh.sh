#!/usr/bin/env bash
set -euo pipefail

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "[INFO] oh-my-zsh 설치 중..."
  RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "[SKIP] oh-my-zsh 이미 설치됨"
fi
