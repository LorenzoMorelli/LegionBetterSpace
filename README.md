# LegionBetterSpace

A Linux replacement for Lenovo Legion Space - a collection of tools to enhance the Legion Go experience on Linux.

```
    __               _             ____       __  __           _____
   / /   ___  ____ _(_)___  ____  / __ )___  / /_/ /____  ____/ ___/____  ____ _________
  / /   / _ \/ __ `/ / __ \/ __ \/ __  / _ \/ __/ __/ _ \/ ___/\__ \/ __ \/ __ `/ ___/ _ \
 / /___/  __/ /_/ / / /_/ / / / / /_/ /  __/ /_/ /_/  __/ /   ___/ / /_/ / /_/ / /__/  __/
/_____/\___/\__, /_/\____/_/ /_/_____/\___/\__/\__/\___/_/   /____/ .___/\__,_/\___/\___/
           /____/                                                /_/
```

## About

Legion Space is Lenovo's Windows-only companion app for the Legion Go series. **LegionBetterSpace** aims to provide similar (and better!) functionality for Linux users through a modular toolbox approach.

Each tool is **standalone**, **lightweight**, and designed to work seamlessly with existing Linux gaming infrastructure like Steam, Gamescope, and InputPlumber.

## Supported Devices

| Device | Status |
|--------|--------|
| Legion Go 2 | Supported |
| Legion Go (Original) | Not tested |

## Tools

### [controller-rgb](./controller-rgb/)

Control the RGB LEDs on the joystick rings.

**Features**:
- Custom colors (RGB/Hex)
- Built-in presets (red, green, blue, cyan, purple, etc.)
- Effects (monocolor, breathe, chroma, rainbow)
- Brightness and speed control
- Automatic persistence across reboots

**Quick Start**:
```bash
./controller-rgb/controller-rgb install   # one-time setup (auto-sudo)
controller-rgb preset cyan                # then use from anywhere
controller-rgb effect rainbow
controller-rgb brightness 50
```

[Full Documentation →](./controller-rgb/README.md)

---

### [gamescope-gestures](./gamescope-gestures/)

Add touch gestures for Steam/Gamescope integration.

**Features**:
- Swipe from right edge → Open QAM (Quick Access Menu)
- Swipe from left edge → Open Steam Menu
- Works in both KDE and Gamescope
- Runs as a system service

**Quick Start**:
```bash
./gamescope-gestures/gamescope-gestures doctor    # Check system (auto-sudo)
./gamescope-gestures/gamescope-gestures install   # Install service (auto-sudo)
```

[Full Documentation →](./gamescope-gestures/README.md)

---

### [brightness-bridge](./brightness-bridge/)

Make the native Steam brightness slider actually change brightness when
HDR PQ is active in Game Mode.

**Features**:
- Bridges sysfs backlight writes → `GAMESCOPE_SDR_ON_HDR_CONTENT_BRIGHTNESS`
- Zero-CPU when idle (`poll(POLLPRI)` on the backlight, kernel-driven)
- User systemd service tied to `gamescope-session.target`
- Workaround for [gamescope#1987](https://github.com/ValveSoftware/gamescope/issues/1987)

**Quick Start**:
```bash
./brightness-bridge/brightness-bridge doctor    # Check system
./brightness-bridge/brightness-bridge install   # Install user service
```

[Full Documentation →](./brightness-bridge/README.md)

---

## Miscellaneous

### [mode-saver](./mode-saver/)

Remember your last session mode (Game Mode or Desktop Mode) across reboots.

**Problem Solved**: By default, CachyOS-Handheld always restarts in Game Mode, even if your last session was in Desktop Mode.

**How it works**:
- Wrapper for `steamos-session-select` saves the current mode
- systemd service restores the mode at boot
- Works with the "Return to Gaming Mode" button

**Quick Start**:
```bash
cd /path/to/LegionBetterSpace/mode-saver
./mode-saver install   # auto-elevates to sudo
```

[Full Documentation →](./mode-saver/README.md)

---

## Installation

### One-liner (clone, install, cleanup)

```bash
T=$(mktemp -d) && git clone https://github.com/yourusername/LegionBetterSpace "$T" && "$T/lbs"; rm -rf "$T"
```

Clones into a temp directory, runs the interactive installer, removes the
temp directory when you exit. Each tool's runtime is copied to standard
system/user paths during install, so the cloned project isn't needed at
runtime.

> Note: to **uninstall** mode-saver later you'll need the project again
> (re-run the one-liner and pick `Uninstall mode-saver`). The other tools
> self-uninstall via their own `uninstall` subcommand from where they were
> installed (`<tool> uninstall` from any terminal).

### Clone for development or repeated use

```bash
git clone https://github.com/yourusername/LegionBetterSpace ~/Projects/LegionBetterSpace
cd ~/Projects/LegionBetterSpace
./lbs
```

### Interactive installer (`./lbs`)

```bash
./lbs
```

Menu-driven: pick services to install/uninstall, run `doctor` on all of
them, or quit. The menu loops until you exit and auto-elevates to sudo
only for the tools that need it.

### Install individual tools

Each tool also ships its own `install`/`uninstall`/`doctor` command,
identical interface across all four:

```bash
./brightness-bridge/brightness-bridge install      # → ~/.local/bin (no sudo)
./controller-rgb/controller-rgb install            # → /usr/local/bin (auto-sudo)
./gamescope-gestures/gamescope-gestures install    # → /usr/local/bin (auto-sudo)
./mode-saver/mode-saver install                    # → /usr/local/bin + /etc (auto-sudo)
```

To uninstall any tool, run its `uninstall` subcommand from the same path.

## Requirements

| Tool | Dependencies |
|------|--------------|
| controller-rgb | bash, sudo (for persistence) |
| gamescope-gestures | python3, python-evdev, InputPlumber |
| brightness-bridge | python3 (stdlib only), xorg-xprop |
| mode-saver | bash, python3 (installer), sudo, SDDM/plasmalogin (CachyOS-Handheld) |

### CachyOS Handheld

If you're using CachyOS Handheld, all dependencies are pre-installed. Just download and run!

### Other Distros

```bash
# Arch/CachyOS
sudo pacman -S python-evdev

# Fedora
sudo dnf install python3-evdev

# Ubuntu/Debian
sudo apt install python3-evdev
```


## Contributing

Contributions are welcome! If you have a Legion Go and want to help:

1. Test existing tools and report issues
2. Add support for Legion Go (original)
3. Create new tools for missing functionality
4. Improve documentation

## License

MIT License - Feel free to modify and distribute.
