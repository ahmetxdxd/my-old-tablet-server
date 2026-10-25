#!/bin/bash
# ==============================================================================
# My Tablet Server - Silent Action Runner for Desktop Shortcuts
# ==============================================================================
# Runs actions silently in background without opening a terminal window,
# and displays desktop notifications via notify-send.
# ==============================================================================

# Locate repository root robustly (works even if called from symlinks or subdirs)
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
DIR="$(cd "$(dirname "$SCRIPT_PATH")/../.." && pwd)"

ACTION="$1"
shift || true
TITLE="$1"
shift || true
NOTIFY_MSG="$1"
shift || true

# Helper: show native desktop notification
notify() {
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -a "My Tablet Server" "${TITLE:-Tablet}" "${NOTIFY_MSG:-Starting action...}" 2>/dev/null || true
    fi
}

# Helper: launch interactive command in user's default terminal emulator
run_in_terminal() {
    if command -v x-terminal-emulator >/dev/null 2>&1; then
        x-terminal-emulator -e "$@" &
    elif command -v konsole >/dev/null 2>&1; then
        konsole -e "$@" &
    elif command -v gnome-terminal >/dev/null 2>&1; then
        gnome-terminal -- "$@" &
    elif command -v xfce4-terminal >/dev/null 2>&1; then
        xfce4-terminal -e "$*" &
    elif command -v alacritty >/dev/null 2>&1; then
        alacritty -e "$@" &
    elif command -v kitty >/dev/null 2>&1; then
        kitty "$@" &
    elif command -v foot >/dev/null 2>&1; then
        foot "$@" &
    elif command -v xterm >/dev/null 2>&1; then
        xterm -e "$@" &
    else
        "$@" &
    fi
}

notify

case "$ACTION" in
    second-screen-usb)
        nohup "$DIR/bin/second-screen" usb >/dev/null 2>&1 &
        ;;
    second-screen-wifi)
        nohup "$DIR/bin/second-screen" wifi >/dev/null 2>&1 &
        ;;
    second-screen-stop)
        nohup "$DIR/bin/second-screen" stop >/dev/null 2>&1 &
        ;;
    stereo-speakers-start)
        nohup "$DIR/bin/stereo-speakers" start >/dev/null 2>&1 &
        ;;
    stereo-speakers-stop)
        nohup "$DIR/bin/stereo-speakers" stop >/dev/null 2>&1 &
        ;;
    cava)
        run_in_terminal "$DIR/bin/stereo-speakers" cava
        ;;
    tablet-terminal)
        run_in_terminal "$DIR/bin/tablet-terminal"
        ;;
    tablet-menu)
        run_in_terminal "$DIR/bin/tablet-menu"
        ;;
    auto-downloader)
        run_in_terminal "$DIR/bin/auto-downloader"
        ;;
    debloat-tablet|debloat)
        run_in_terminal "$DIR/bin/debloat-tablet"
        ;;
    anime|anime\ *)
        SUB="${ACTION#anime}"
        SUB="${SUB# }"
        nohup "$DIR/bin/anime" ${SUB:-app} >/dev/null 2>&1 &
        ;;
    *)
        nohup "$DIR/bin/tablet" run $ACTION "$@" >/dev/null 2>&1 &
        ;;
esac
