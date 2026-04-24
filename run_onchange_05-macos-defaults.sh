#!/usr/bin/env bash
# macOS 시스템 defaults — 키보드 단축키 및 기본 동작 커스터마이즈.
# chezmoi의 run_onchange_* 메커니즘으로 이 파일 내용이 바뀔 때마다 재실행.
# cfprefsd가 변경을 캐시할 수 있어 끝에서 명시적으로 kill.

set -euo pipefail

[[ "$(uname)" == "Darwin" ]] || { echo "[SKIP] macOS 전용"; exit 0; }

PLIST="$HOME/Library/Preferences/com.apple.symbolichotkeys.plist"
PB="/usr/libexec/PlistBuddy"

say() { printf "\033[1;34m[macos-defaults]\033[0m %s\n" "$*"; }

# ── PlistBuddy helpers (키 존재 시 Set, 없으면 Add) ──
pb_set_bool()   { "$PB" -c "Set $1 $2" "$PLIST" 2>/dev/null || "$PB" -c "Add $1 bool $2" "$PLIST"; }
pb_set_string() { "$PB" -c "Set $1 $2" "$PLIST" 2>/dev/null || "$PB" -c "Add $1 string $2" "$PLIST"; }

# symbolichotkey 항목 설정.
# 인자: id, enabled(true|false), [char, keycode, modifiers]
set_shortcut() {
  local id=$1 enabled=$2 char=${3:-} keycode=${4:-} mods=${5:-}

  pb_set_bool ":AppleSymbolicHotKeys:$id:enabled" "$enabled"

  if [[ "$enabled" == "true" && -n "$char" ]]; then
    pb_set_string ":AppleSymbolicHotKeys:$id:value:type" "standard"
    "$PB" -c "Delete :AppleSymbolicHotKeys:$id:value:parameters" "$PLIST" 2>/dev/null || true
    "$PB" -c "Add :AppleSymbolicHotKeys:$id:value:parameters array" "$PLIST"
    "$PB" -c "Add :AppleSymbolicHotKeys:$id:value:parameters:0 integer $char"    "$PLIST"
    "$PB" -c "Add :AppleSymbolicHotKeys:$id:value:parameters:1 integer $keycode" "$PLIST"
    "$PB" -c "Add :AppleSymbolicHotKeys:$id:value:parameters:2 integer $mods"    "$PLIST"
  fi
}

# ── 입력 소스 단축키 ──
# 60: "이전 입력 소스 선택" — 비활성 (실수로 눌릴 일 방지)
say "symbolichotkey 60 (이전 입력 소스) 비활성"
set_shortcut 60 false

# 61: "입력 메뉴에서 다음 소스 선택" → F18
#   parameters = [char=65535(none), keycode=79(F18), modifiers=8388608(fn)]
#   Karabiner에서 Right Command → F18 리매핑과 조합해 한/영 전환 트리거
say "symbolichotkey 61 (다음 입력 소스) → F18"
set_shortcut 61 true 65535 79 8388608

# ── Spotlight (Raycast가 대체) ──
# 64: Show Spotlight search (⌘ Space)
# 65: Show Finder search window (⌘⌥ Space)
say "symbolichotkey 64, 65 (Spotlight) 비활성"
set_shortcut 64 false
set_shortcut 65 false

# ── F1/F2 등을 표준 function 키로 ──
say "F1/F2 등 표준 function 키 모드 on"
defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true

# ── 키 반복 속도 최소 ──
# KeyRepeat: 반복 간격. 2 = 30ms (가장 빠름 중 안정값)
# InitialKeyRepeat: 반복 시작 지연. 15 = 225ms
# ApplePressAndHoldEnabled false: 악센트 선택 UI 비활성 (길게 누를 때 그냥 반복 입력)
say "키 반복 속도 최소 (KeyRepeat=2, InitialKeyRepeat=15)"
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# ── 트랙패드: 탭으로 클릭 (물리적 누름 대신) ──
# 내장 트랙패드 + Bluetooth(Magic Trackpad 등) 둘 다 적용
# NSGlobalDomain의 mouse.tapBehavior=1은 로그인 화면에서도 탭 클릭 허용
say "트랙패드 탭 클릭 활성"
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# ── cfprefsd 캐시 무효화 (변경 사항 즉시 반영) ──
say "cfprefsd 재시작 (캐시 flush)"
killall cfprefsd 2>/dev/null || true

echo
say "완료. 일부 설정은 로그아웃/재부팅 후 완전히 적용됨."
