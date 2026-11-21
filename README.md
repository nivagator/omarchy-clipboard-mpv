# Clipboard MPV

A native Omarchy Quattro bar widget for playing a copied video URL in mpv.

Copy a URL, then click the YouTube icon in the bar. No terminal or URL prompt
is needed.

## Controls

| Action | Behavior |
| --- | --- |
| Left-click | Play the clipboard URL as video, requesting up to 1080p |
| Middle-click | Play the clipboard URL as audio only |
| Right-click | Stop all mpv processes owned by your user |
| White icon | No mpv process detected for your user |
| Red icon | An mpv process is running under your user |

Status refreshes every three seconds.

## Requirements

- Omarchy with the Quattro / Quickshell plugin system
- mpv
- yt-dlp
- wl-clipboard (`wl-paste`)
- Bash
- procps-ng (`pgrep` and `pkill`)
- Optional: libnotify (`notify-send`) for error notifications

Tested on Omarchy 4.5.0-3.

This is not a Waybar or Polybar module.

## Installation

Once this repository is public:

```bash
omarchy plugin add [https://github.com/nivagator/omarchy-clipboard-mpv.git](https://github.com/nivagator/omarchy-clipboard-mpv.git) --enable
omarchy bar put nivagator.clipboard-mpv --after omarchy.clock
omarchy restart shell
```

The bar briefly disappears while the shell restarts.

## Usage

1. Copy a single HTTP or HTTPS media URL using your browser's normal Copy action.
2. Left-click the bar icon for video, or middle-click for audio only.
3. Right-click to stop your mpv players.

The widget reads the regular Wayland clipboard, not the primary selection.
Highlighting text without copying it is not sufficient.

## Important behavior

- Right-click stops every mpv process owned by your user, including players
  opened outside this plugin.
- The red icon indicates that an mpv process exists. It does not distinguish
  playing, paused, buffering, or plugin-launched players.
- Video requests are limited to 1080p by the configured format selector.
- Hardware decoding is explicitly disabled with `--hwdec=no`.
- Audio-only mode uses `--vid=no` and requests `bestaudio`.
- Website compatibility depends on mpv, yt-dlp, and the source website.
- This plugin does not configure authentication, browser-cookie extraction,
  or DRM handling.
- Empty or invalid clipboard contents do not launch mpv.
- Clipboard contents are not written to a diagnostic log by the helper.
- Stop works even when the clipboard is empty.

## Troubleshooting

### The icon does not appear after installation or a QML edit

During testing on Omarchy 4.5.0-3, local-plugin reload messages were not
sufficient to apply edited QML. A full shell restart loaded the current file:

```bash
omarchy restart shell
```

Confirm the plugin is enabled and placed on the bar:

```bash
omarchy plugin enable nivagator.clipboard-mpv
omarchy bar put nivagator.clipboard-mpv --after omarchy.clock
```

### Playback fails

Run the installed helper in a terminal with a media URL copied:

```bash
bash ~/.config/omarchy/plugins/nivagator.clipboard-mpv/clipboard-mpv.sh video
```

This exposes mpv and yt-dlp output. If your plugin manager uses a different
installation directory, run the helper from that directory instead.

For an audio-only test:

```bash
bash ~/.config/omarchy/plugins/nivagator.clipboard-mpv/clipboard-mpv.sh audio
```

### Inspect shell logs

```bash
qs log -p /usr/share/omarchy/shell --tail 100
```

## Disable and removal

Disable the plugin:

```bash
omarchy plugin disable nivagator.clipboard-mpv
omarchy restart shell
```

For complete removal, use your installed Omarchy plugin manager's removal
command or interface. Consult `omarchy plugin --help` for the supported
command in your version.

This plugin has no installer hook, background service, or system-file
modifications. Normal operation does not create persistent plugin state.
Disabling it does not close an already launched mpv player.

## Development

Files:

- `manifest.json`: plugin identity and bar-widget entry point
- `BarWidget.qml`: button, mouse actions, and status polling
- `clipboard-mpv.sh`: clipboard validation and mpv control

Validate from the repository root:

```bash
omarchy plugin validate .
bash -n clipboard-mpv.sh
```

After QML edits, restart the shell if automatic reload does not apply them.

## License

MIT. See LICENSE.

Created by nivagator. Inspired by the author's existing Polybar
clipboard-to-mpv workflow.
