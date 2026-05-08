# Gamescope Gestures

A lightweight daemon that adds touch gestures to the Legion Go 2 for Steam/Gamescope integration.

## Features

- **Swipe from right edge** → Open Quick Access Menu (QAM)
- **Swipe from left edge** → Open Steam Menu
- Works in both **KDE** and **Gamescope** (Game Mode)
- Auto-starts on boot via systemd
- Zero external dependencies (uses python-evdev + D-Bus)

## How It Works

```
┌─────────────────────────────────────────────────────────────┐
│                      Touchscreen                            │
│  ┌─────┐                                          ┌─────┐   │
│  │     │  ←── Swipe right = Steam Menu            │     │   │
│  │ L   │                                          │  R  │   │
│  │     │               Screen                     │     │   │
│  │     │                                          │     │   │
│  │     │           Swipe left = QAM ──→           │     │   │
│  └─────┘                                          └─────┘   │
└─────────────────────────────────────────────────────────────┘
```

1. The script reads raw touch events from `/dev/input/eventX` (kernel level)
2. Detects edge swipes based on configurable thresholds
3. Sends button events to InputPlumber via D-Bus
4. InputPlumber translates them to Steam Deck controller buttons
5. Steam/Gamescope receives the button press and opens the menu

## Requirements

- **Legion Go 2** with CachyOS Handheld (or similar distro)
- **InputPlumber** (pre-installed on CachyOS Handheld)
- **python-evdev** (`sudo pacman -S python-evdev`)
- **systemd** (for service management)

## Installation

### Quick Install

```bash
# Navigate to the script directory
cd /path/to/LegionBetterSpace/gamescope-gestures

# Make executable
chmod +x gamescope-gestures

# Check system status
sudo ./gamescope-gestures doctor

# Install as system service
sudo ./gamescope-gestures install
```

`install` copies the script to `/usr/local/bin/gamescope-gestures` and
writes the unit to `/etc/systemd/system/gamescope-gestures.service`. After
install the project directory can be deleted - the service runs from the
installed copy.

### Verify Installation

```bash
# Check service status
systemctl status gamescope-gestures

# View logs
journalctl -u gamescope-gestures -f
```

## Usage

### Commands

| Command | Description |
|---------|-------------|
| `run` | Run gesture detection in foreground (requires sudo) |
| `install` | Install as systemd service (requires sudo) |
| `uninstall` | Remove service and optionally the script (requires sudo) |
| `doctor` | Check dependencies and system status, offer fixes |
| `test-qam` | Send QAM button press (test) |
| `test-menu` | Send Steam Menu button press (test) |
| `debug` | Show raw touch events (for troubleshooting) |
| `help` | Show help message |

### Examples

```bash
# Test gestures manually
sudo ./gamescope-gestures run

# Check system health
sudo ./gamescope-gestures doctor

# Install for auto-start
sudo ./gamescope-gestures install

# Test button presses
./gamescope-gestures test-qam
./gamescope-gestures test-menu

# Uninstall
sudo ./gamescope-gestures uninstall
```

## Configuration

The script has configurable parameters at the top of the file:

```python
EDGE_PERCENT = 5       # % from edge to start swipe detection
MIN_SWIPE_PERCENT = 8  # % of screen width for valid swipe
```

- **EDGE_PERCENT**: How close to the edge you need to start the swipe (default: 5%)
- **MIN_SWIPE_PERCENT**: Minimum distance to swipe for it to register (default: 8%)

## Debugging

### Check System Status

```bash
sudo ./gamescope-gestures doctor
```

This will check:
- python-evdev installation
- busctl availability
- InputPlumber service status
- InputPlumber D-Bus connection
- Touchscreen device detection
- gamescope-gestures service status

### View Raw Touch Events

```bash
sudo ./gamescope-gestures debug
```

This shows raw touch coordinates as you touch the screen. Useful for:
- Verifying the touchscreen is detected
- Understanding coordinate ranges
- Debugging gesture detection issues

### View Service Logs

```bash
# Follow logs in real-time
journalctl -u gamescope-gestures -f

# View recent logs
journalctl -u gamescope-gestures -n 50
```

### Common Issues

#### Touchscreen not found

```
[Checking] Touchscreen device... NOT FOUND
```

**Solution**: Run with sudo:
```bash
sudo ./gamescope-gestures doctor
```

#### InputPlumber not running

```
[Checking] InputPlumber service... NOT RUNNING
```

**Solution**:
```bash
sudo systemctl start inputplumber
sudo systemctl enable inputplumber
```

#### Gestures not working in Gamescope

1. Check the service is running:
   ```bash
   systemctl status gamescope-gestures
   ```

2. Check logs for errors:
   ```bash
   journalctl -u gamescope-gestures -n 20
   ```

3. Verify InputPlumber D-Bus is accessible:
   ```bash
   busctl --system tree org.shadowblip.InputPlumber
   ```

## Uninstall

```bash
sudo ./gamescope-gestures uninstall
```

This will:
1. Stop the systemd service
2. Disable the service
3. Remove `/etc/systemd/system/gamescope-gestures.service`
4. Remove `/usr/local/bin/gamescope-gestures`

## Technical Details

### Why kernel-level input?

Reading from `/dev/input/eventX` directly bypasses the Wayland compositor, ensuring gestures work in both KDE and Gamescope without compositor-specific code.

### Why InputPlumber D-Bus?

InputPlumber already handles controller emulation for the Legion Go 2. By sending button events through its D-Bus interface, we leverage the existing infrastructure and ensure compatibility with Steam's controller handling.

### Service Architecture

```
┌──────────────────┐     ┌──────────────────┐     ┌──────────────┐
│   Touchscreen    │────▶│  gamescope-gestures │────▶│ InputPlumber │
│ /dev/input/event │     │    (systemd)     │     │   (D-Bus)    │
└──────────────────┘     └──────────────────┘     └──────┬───────┘
                                                         │
                                                         ▼
                                                  ┌──────────────┐
                                                  │    Steam/    │
                                                  │  Gamescope   │
                                                  └──────────────┘
```

## License

MIT License - Feel free to modify and distribute.

## Related Projects

- [InputPlumber](https://github.com/ShadowBlip/InputPlumber) - Input management for Linux gaming handhelds
- [CachyOS](https://cachyos.org/) - Performance-focused Arch-based distribution
