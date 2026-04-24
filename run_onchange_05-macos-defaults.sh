#!/usr/bin/env bash
# macOS 시스템 defaults — 키보드 단축키 및 기본 동작 커스터마이즈.
# chezmoi의 run_onchange_* 메커니즘으로 이 파일 내용이 바뀔 때마다 재실행.
#
# 각 설정은 독립적으로 시도되며, 한 설정이 실패해도 다른 설정 적용은 계속됨.
# 마지막에 실패한 설정들을 요약해 보고하고, 하나라도 실패하면 exit 1.

# set -e 의도적으로 제외 — 개별 실패를 삼키지 않고 수집하기 위함
set -uo pipefail

[[ "$(uname)" == "Darwin" ]] || { echo "[SKIP] macOS 전용"; exit 0; }

PLIST="$HOME/Library/Preferences/com.apple.symbolichotkeys.plist"
PB="/usr/libexec/PlistBuddy"

say()  { printf "\033[1;34m[macos-defaults]\033[0m %s\n" "$*"; }
ok()   { printf "\033[1;32m  ✓\033[0m %s\n" "$*"; }
warn() { printf "\033[1;31m  ✗\033[0m %s  (exit %s)\n" "$1" "$2" >&2; }

declare -a FAILED=()

# 명령을 실행하고 실패 시 FAILED에 기록. 성공해도 진행, 실패해도 진행.
try() {
  local label=$1; shift
  local err ec
  if err=$("$@" 2>&1); then
    ok "$label"
  else
    ec=$?
    FAILED+=("$label")
    warn "$label" "$ec"
    if [[ -n "$err" ]]; then
      printf "      %s\n" "$err" | head -3 >&2
    fi
  fi
}

# ── PlistBuddy helpers — Set 실패 시 Add, 둘 다 실패하면 non-zero 반환 ──
pb_set_bool() {
  "$PB" -c "Set $1 $2" "$PLIST" 2>/dev/null && return 0
  "$PB" -c "Add $1 bool $2" "$PLIST"
}
pb_set_string() {
  "$PB" -c "Set $1 $2" "$PLIST" 2>/dev/null && return 0
  "$PB" -c "Add $1 string $2" "$PLIST"
}

# symbolichotkey 한 항목을 원하는 상태로 만듦. 중간 실패 시 non-zero.
set_shortcut() {
  local id=$1 enabled=$2 char=${3:-} keycode=${4:-} mods=${5:-}

  pb_set_bool ":AppleSymbolicHotKeys:$id:enabled" "$enabled" || return 1

  if [[ "$enabled" == "true" && -n "$char" ]]; then
    pb_set_string ":AppleSymbolicHotKeys:$id:value:type" "standard" || return 1
    "$PB" -c "Delete :AppleSymbolicHotKeys:$id:value:parameters" "$PLIST" 2>/dev/null || true
    "$PB" -c "Add :AppleSymbolicHotKeys:$id:value:parameters array" "$PLIST" || return 1
    "$PB" -c "Add :AppleSymbolicHotKeys:$id:value:parameters:0 integer $char"    "$PLIST" || return 1
    "$PB" -c "Add :AppleSymbolicHotKeys:$id:value:parameters:1 integer $keycode" "$PLIST" || return 1
    "$PB" -c "Add :AppleSymbolicHotKeys:$id:value:parameters:2 integer $mods"    "$PLIST" || return 1
  fi
}

say "적용 시작"

# ── 입력 소스 단축키 ──
try "symbolichotkey 60 (이전 입력 소스) 비활성" \
  set_shortcut 60 false

# 61: "입력 메뉴에서 다음 소스 선택" → F18
#   parameters = [char=65535(none), keycode=79(F18), modifiers=8388608(fn)]
#   Karabiner에서 Right Command → F18 리매핑과 조합해 한/영 전환 트리거
try "symbolichotkey 61 (다음 입력 소스) → F18" \
  set_shortcut 61 true 65535 79 8388608

# ── Spotlight (Raycast가 대체) ──
try "symbolichotkey 64 (Spotlight ⌘Space) 비활성" \
  set_shortcut 64 false
try "symbolichotkey 65 (Spotlight ⌘⌥Space) 비활성" \
  set_shortcut 65 false

# ── F1/F2 등을 표준 function 키로 ──
try "F1/F2 표준 function 키 모드" \
  defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true

# ── 키 반복 속도 최소 ──
try "KeyRepeat = 2 (반복 간격 ~30ms)" \
  defaults write NSGlobalDomain KeyRepeat -int 2
try "InitialKeyRepeat = 15 (반복 시작 지연 ~225ms)" \
  defaults write NSGlobalDomain InitialKeyRepeat -int 15
try "ApplePressAndHoldEnabled = false (악센트 선택 UI 비활성)" \
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# ── 트랙패드: 탭으로 클릭 ──
try "AppleMultitouchTrackpad Clicking (내장)" \
  defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
try "AppleBluetoothMultitouch.trackpad Clicking (Magic Trackpad)" \
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
try "com.apple.mouse.tapBehavior = 1 (로그인 화면 탭 클릭)" \
  defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# ── cfprefsd 캐시 무효화 (변경 사항 즉시 반영) ──
# killall 자체는 검증 가치가 크지 않아 try() 없이 실행
killall cfprefsd 2>/dev/null || true

# ── 결과 요약 ──
echo
if [[ ${#FAILED[@]} -eq 0 ]]; then
  say "전 항목 성공. 일부 설정은 로그아웃/재부팅 후 완전히 반영."
  exit 0
else
  say "실패한 항목 ${#FAILED[@]}개:"
  for f in "${FAILED[@]}"; do
    printf "  - %s\n" "$f"
  done
  echo
  say "나머지 설정은 정상 적용됨. 위 실패만 개별 확인 필요."
  exit 1
fi
