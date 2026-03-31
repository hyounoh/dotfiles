# ── PATH ──────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"
export PATH="$(brew --prefix)/opt/mysql-client/bin:$PATH"

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
