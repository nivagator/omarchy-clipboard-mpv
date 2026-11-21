#!/usr/bin/env bash
set -euo pipefail

action="${1:-video}"

notify() {
    if command -v notify-send >/dev/null 2>&1; then
        notify-send --app-name="Clipboard MPV" "Clipboard MPV" "$1" || :
    fi
}

fail() {
    printf 'Clipboard MPV: %s\n' "$1" >&2
    notify "$1"
    exit 1
}

case "$action" in
    status)
        if pgrep -u "$(id -u)" -x mpv >/dev/null 2>&1; then
            printf 'running\n'
        else
            printf 'stopped\n'
        fi
        exit 0
        ;;

    stop)
        pkill -u "$(id -u)" -x mpv 2>/dev/null || :
        exit 0
        ;;

    video|audio)
        ;;

    *)
        printf 'Usage: %s {video|audio|stop|status}\n' "$0" >&2
        exit 2
        ;;
esac

for dependency in wl-paste mpv yt-dlp; do
    command -v "$dependency" >/dev/null 2>&1 \
        || fail "Missing dependency: $dependency"
done

url="$(wl-paste --no-newline --type text 2>/dev/null)" \
    || fail "Could not read text from the clipboard."

# Trim surrounding whitespace without executing clipboard contents.
url="${url#"${url%%[![:space:]]*}"}"
url="${url%"${url##*[![:space:]]}"}"

[[ -n "$url" ]] || fail "The clipboard is empty."

[[ "$url" != *[[:space:]]* ]] \
    || fail "Copy a single URL, not a block of text."

[[ "$url" =~ ^https?://[^/[:space:]]+ ]] \
    || fail "The clipboard does not contain an HTTP or HTTPS URL."

mpv_args=(
    --hwdec=no
    --ytdl=yes
)

case "$action" in
    video)
        mpv_args+=(
            '--ytdl-format=bestvideo[height<=1080]+bestaudio/best[height<=1080]'
        )
        ;;

    audio)
        mpv_args+=(
            --vid=no
            --ytdl-format=bestaudio
        )
        ;;
esac

if mpv "${mpv_args[@]}" -- "$url"; then
    exit 0
else
    result=$?
    notify "mpv exited with an error. Run the helper in a terminal for details."
    exit "$result"
fi
