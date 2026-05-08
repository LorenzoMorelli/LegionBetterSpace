# Controller RGB

A simple command-line tool to control the RGB LEDs on the Legion Go 2 joystick rings.

## Features

- **Set custom colors** via RGB values or hex codes
- **Built-in presets** for common colors
- **Multiple effects**: monocolor, breathe, chroma, rainbow
- **Adjustable brightness** and speed
- **Automatic persistence** across reboots via udev rules
- **Easy uninstall** with cleanup

## How It Works

```
┌─────────────────┐     ┌──────────────────────────────────────┐
│   controller-rgb    │────▶│  /sys/class/leds/go:rgb:joystick_rings │
│    (script)     │     │         (kernel sysfs interface)      │
└─────────────────┘     └──────────────────────────────────────┘
        │
        ▼
┌─────────────────┐     ┌──────────────────────────────────────┐
│  udev rule      │────▶│  Restores settings on boot/resume    │
│  (persistence)  │     │  /etc/udev/rules.d/99-controller-rgb.rules│
└─────────────────┘     └──────────────────────────────────────┘
```

The script writes directly to the kernel's sysfs interface for LED control. Settings are saved to `~/.config/controller-rgb.conf` and restored automatically via a udev rule.

## Requirements

- **Legion Go 2** with kernel support for `go:rgb:joystick_rings` LED
- **Python 3** (pre-installed on most Linux systems)
- **sudo** access (for udev rule installation)

## Installation

```bash
# Navigate to the script directory
cd /path/to/LegionBetterSpace/controller-rgb

# Install (auto-elevates to sudo)
./controller-rgb install
```

`install` copies the script to `/usr/local/bin/controller-rgb` and writes
the persistence udev rule to `/etc/udev/rules.d/99-controller-rgb.rules`.
After install the project directory can be deleted - the `controller-rgb`
command works from any terminal, no sudo required for daily use.

## Usage

### Commands

| Command | Description |
|---------|-------------|
| `color <r> <g> <b>` | Set RGB color (0-255 each) |
| `hex <#RRGGBB>` | Set color from hex code |
| `preset <name>` | Use a built-in color preset |
| `effect <name>` | Set LED effect |
| `brightness <0-100>` | Set brightness level |
| `speed <0-100>` | Set effect animation speed |
| `on` | Turn LEDs on (40% brightness) |
| `off` | Turn LEDs off |
| `status` | Show current LED settings |
| `install` | Install to `/usr/local/bin` and enable persistence (auto-elevates) |
| `uninstall` | Remove the installed copy, udev rule, and optionally the config (auto-elevates) |

### Color Presets

| Preset | RGB Value |
|--------|-----------|
| `red` | 255, 0, 0 |
| `green` | 0, 255, 0 |
| `blue` | 0, 0, 255 |
| `white` | 255, 255, 255 |
| `orange` | 255, 85, 0 |
| `purple` | 128, 0, 255 |
| `cyan` | 0, 255, 255 |
| `pink` | 255, 0, 128 |
| `yellow` | 255, 255, 0 |

### Effects

| Effect | Description |
|--------|-------------|
| `monocolor` | Static single color |
| `breathe` | Pulsing/breathing effect |
| `chroma` | Color cycling |
| `rainbow` | Rainbow wave effect |

### Examples

After `install`, run from anywhere (no sudo, no `./` prefix):

```bash
controller-rgb preset purple        # Set a preset color
controller-rgb color 255 128 0      # Set custom RGB color
controller-rgb hex "#FF8000"        # Set color via hex code
controller-rgb effect rainbow       # Set rainbow effect
controller-rgb brightness 50        # Adjust brightness
controller-rgb speed 75             # Adjust effect speed
controller-rgb off                  # Turn off LEDs
controller-rgb status               # Check current status
```

## Persistence

When you change any setting, the script saves all current settings to
`~/.config/controller-rgb.conf`. The udev rule installed by `install`
watches for the LED device to appear (on boot or resume from suspend) and
automatically runs `controller-rgb apply-saved` to restore your settings.

**Config file location**: `~/.config/controller-rgb.conf`
**Udev rule location**: `/etc/udev/rules.d/99-controller-rgb.rules`

## Uninstall

```bash
controller-rgb uninstall
```

This will:
1. Remove `/usr/local/bin/controller-rgb`
2. Remove the udev rule
3. Re-enable Kameleon KDE module if it was disabled
4. Optionally remove the config file

## Troubleshooting

### LED device not found

```
Error: LED device not found at /sys/class/leds/go:rgb:joystick_rings
```

**Possible causes**:
- Kernel doesn't support the Legion Go 2 LEDs
- Device path is different on your system

**Check available LEDs**:
```bash
ls /sys/class/leds/
```

### Permission denied

The script writes to `/sys/class/leds/` which typically requires root permissions. However, on most systems with proper udev rules, the `input` group has access.

**Solutions**:
1. Run with sudo: `sudo ./controller-rgb preset red`
2. Add user to input group: `sudo usermod -aG input $USER` (requires logout)

### Settings not persisting

1. Check if udev rule exists:
   ```bash
   cat /etc/udev/rules.d/99-controller-rgb.rules
   ```

2. Check if config file exists:
   ```bash
   cat ~/.config/controller-rgb.conf
   ```

3. Manually trigger udev:
   ```bash
   sudo udevadm control --reload-rules
   sudo udevadm trigger
   ```

## Technical Details

### Sysfs Interface

The Legion Go 2 exposes LED control via:
- `/sys/class/leds/go:rgb:joystick_rings/`

Available attributes:
| Attribute | Description |
|-----------|-------------|
| `brightness` | 0-100 |
| `multi_intensity` | RGB values (space-separated) |
| `effect` | monocolor, breathe, chroma, rainbow |
| `speed` | Effect animation speed |
| `mode` | dynamic, custom |

### Why No Steam Integration?

Steam only supports LED control for specific controllers (DualSense, DualShock 4). The Legion Go 2 emulates a Steam Deck controller via InputPlumber, which doesn't have RGB LEDs. This script provides direct control as an alternative.

## License

MIT License - Feel free to modify and distribute.
