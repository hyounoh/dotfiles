# ── Locale: 메시지는 영어로 고정 (한글 입력/정렬은 시스템 LANG 그대로) ─
# macOS 시스템 언어/Region을 한국어로 두면 터미널이 LANG=ko_KR.UTF-8을
# 자동 주입함 → git/brew 메시지가 한글로 나옴. LC_MESSAGES만 오버라이드.
export LC_MESSAGES=en_US.UTF-8

# ── PATH ──────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"
export PATH="$(brew --prefix)/opt/mysql-client/bin:$PATH"
export PATH="$(brew --prefix)/opt/libpq/bin:$PATH"   # psql, pg_dump (keg-only)

# ── fzf ──────────────────────────────────────────────────
source <(fzf --zsh)

# ── mise (런타임 버전 관리) ──────────────────────────────
eval "$(mise activate zsh)"

# ── zoxide (cd 대체) ──────────────────────────────────────
eval "$(zoxide init zsh --cmd cd)"

# ── atuin (히스토리 검색) ─────────────────────────────────
eval "$(atuin init zsh --disable-up-arrow)"

# ── Plugins ──────────────────────────────────────────────
source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# ── starship (프롬프트) ───────────────────────────────────
eval "$(starship init zsh)"

# ── Aliases ──────────────────────────────────────────────
alias ls='eza --icons'
alias ll='eza -lah --icons --git'
alias lt='eza --tree --level=2 --icons'
alias cat='bat --paging=never'
alias lg='lazygit'
alias lzd='lazydocker'
alias lzs='lazysql'
