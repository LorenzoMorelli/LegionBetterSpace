# brightness-bridge

Make the native Steam brightness slider actually change brightness on the
Legion Go 2 in Game Mode, even when HDR PQ is active.

Workaround for
[ValveSoftware/gamescope#1987](https://github.com/ValveSoftware/gamescope/issues/1987).

## How it works

A small user-space daemon watches the kernel backlight file
(`/sys/class/backlight/amdgpu_bl1/actual_brightness`) via `poll(POLLPRI)` -
`sysfs_notify` wakes us on every slider movement, so there is no polling
loop and the daemon stays at 0% CPU when idle.

When the value changes, the daemon mirrors it (as 5-500 nits, encoded as a
32-bit float) into the X11 atom `GAMESCOPE_SDR_ON_HDR_CONTENT_BRIGHTNESS`
that gamescope reads in HDR PQ mode. The daemon runs as a user systemd
service tied to `gamescope-session.target` and is therefore active only in
Game Mode.

## Install / uninstall

```bash
./brightness-bridge install     # enable the user service
./brightness-bridge doctor      # check system state
./brightness-bridge uninstall   # remove
```

`install` copies the script to `~/.local/bin/brightness-bridge` and writes
the service unit to `~/.config/systemd/user/brightness-bridge.service`.
After install the project directory can be deleted - the service runs from
the installed copy. No root required.

## Future steps

- Read the nits range from the EDID HDR static metadata instead of the
  hardcoded 5-500.
- Drop the workaround once gamescope#1987 is fixed upstream.

## Credits

Approach and Lego2 brightness/HDR-PQ logic inspired by
[jorgemmsilva/decky-plugin-fix-lego2-brightness-cachyos](https://github.com/jorgemmsilva/decky-plugin-fix-lego2-brightness-cachyos),
which provides the same fix as a separate slider in the Decky QAM. This
tool drives the existing native slider instead.
