# ── Homebrew prefix (한 번만 평가 — brew --prefix subprocess 반복 호출 제거) ──
BREW_PREFIX="$(brew --prefix)"

# ── PATH ──────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"
export PATH="$BREW_PREFIX/opt/mysql-client/bin:$PATH"
export PATH="$BREW_PREFIX/opt/libpq/bin:$PATH"   # psql, pg_dump (keg-only)

# 미설치 도구로 셸 init이 깨지지 않도록 각 초기화에 존재 가드를 둔다
# (첫 부트스트랩 중 brew bundle 완료 전 새 셸에서도 안전).

# ── fzf ──────────────────────────────────────────────────
command -v fzf >/dev/null && source <(fzf --zsh)

# ── zoxide (cd 대체) ──────────────────────────────────────
command -v zoxide >/dev/null && eval "$(zoxide init zsh --cmd cd)"
# autosuggestions/highlighting/starship가 의도적으로 zoxide init 뒤에 와야 하므로
# "끝에 두라"는 zoxide doctor 경고는 오탐 → 비활성화.
export _ZO_DOCTOR=0

# ── atuin (히스토리 검색) ─────────────────────────────────
command -v atuin >/dev/null && eval "$(atuin init zsh --disable-up-arrow)"

# ── Plugins ──────────────────────────────────────────────
[[ -f "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] \
  && source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# ── starship (프롬프트) ───────────────────────────────────
command -v starship >/dev/null && eval "$(starship init zsh)"

# ── zsh-syntax-highlighting (반드시 맨 마지막 — ZLE 위젯 정의 이후 source) ──
[[ -f "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] \
  && source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# ── Aliases ──────────────────────────────────────────────
alias ls='eza --icons'
alias ll='eza -lah --icons --git'
alias lt='eza --tree --level=2 --icons'
alias cat='bat --paging=never'
alias lg='lazygit'
alias lzd='lazydocker'
alias lzs='lazysql'
