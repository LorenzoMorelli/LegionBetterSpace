#!/bin/bash
# Switch to gamescope. Single source of truth: delegate to the wrapper so
# state file, autologin config and logout stay in sync.
exec /usr/local/bin/steamos-session-select gamescope
