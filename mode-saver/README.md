# Mode Saver for CachyOS-Handheld

This utility allows CachyOS-Handheld to remember the last used mode (Game Mode or Desktop Mode) and automatically restart in the same mode.

## Problem Solved

By default, CachyOS-Handheld always restarts in Game Mode, even if the last session was in Desktop Mode. This can be annoying if you prefer to work in Desktop Mode.

## How It Works

1. **`steamos-session-select` wrapper**: Intercepts every session change, saves the target to `~/.config/last-session-mode`, triggers `session-restore.service` to update the autologin config, then logs out.
2. **systemd service**: Both at boot and on every session switch, rewrites the display manager autologin override (`zz-steamos-autologin.conf`) according to the saved state — gamescope keeps autologin, plasma forces a password prompt.
3. **polkit rule**: Allows users in the `wheel` group to start `session-restore.service` without a password prompt, so session switches stay seamless.
4. **Modified desktop file**: The "Return to Gaming Mode" button now goes through the wrapper instead of just logging out.
5. **Mask `cachyos-gamescope-autologin.service`**: The `cachyos-handheld` package ships a user systemd unit that, on every plasma logout, reverts the autologin override back to gamescope. mode-saver masks it on install (equivalent to `steamos-session-select persistent`) and unmasks it on uninstall.

### Login behaviour

| Action | Result |
|---|---|
| Boot, last session = gamescope | Display manager autologin → Steam (PIN handled by Steam) |
| Boot, last session = plasma | Display manager shows password prompt → KDE password → Plasma |
| Switch plasma → gamescope | Brief login screen, then autologin → Steam |
| Switch gamescope → plasma | Brief login screen, then password prompt |

Steam's own PIN/Family-View passcode is independent and must be enabled inside Steam → Settings → Family.

## Installation

```bash
cd mode-saver
./mode-saver install      # auto-elevates to sudo
```

## Uninstallation

```bash
cd mode-saver
./mode-saver uninstall    # auto-elevates to sudo
```

## Status check

```bash
./mode-saver doctor
```

The runtime helpers (bash scripts and config files) stay separate in the
project; the Python `mode-saver` is just the installer with the same
`install`/`uninstall`/`doctor` interface as the other LegionBetterSpace
tools.

## Installed Files

- `/usr/local/bin/steamos-session-select` - Wrapper (takes PATH priority over the original in `/usr/bin/`, which is left untouched so package updates don't break it)
- `/usr/local/bin/session-restore.sh` - Restore script (writes the DM autologin override)
- `/usr/local/bin/return-to-gamemode.sh` - Wrapper for the "Return to Gaming Mode" desktop entry
- `/etc/systemd/system/session-restore.service` - systemd service
- `/etc/polkit-1/rules.d/90-mode-saver.rules` - Polkit rule allowing the `wheel` group to start the service without a password
- `/usr/share/applications/steamos-gamemode.desktop` - Modified desktop file (original backed up to `/usr/local/share/mode-saver/`)
- `~/Desktop/steamos-gamemode.desktop` - Desktop shortcut for the current user (if `~/Desktop` exists)

## Compatibility

Tested on CachyOS-Handheld with deckify and the **plasmalogin** display manager. The restore script auto-detects the autologin config file, so it should also work on systems using **SDDM** (`/etc/sddm.conf.d/zz-steamos-autologin.conf`), but this path is currently untested.

The "Return to Gaming Mode" helper uses `qdbus6` and therefore requires KDE Plasma 6.

## License

MIT
