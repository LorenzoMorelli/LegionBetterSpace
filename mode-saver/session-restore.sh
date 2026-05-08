#!/bin/bash
# Write the display manager autologin config based on ~/.config/last-session-mode.
#
# Runs at boot via session-restore.service (Before=display-manager.service)
# and at runtime via the steamos-session-select wrapper (which triggers the
# unit through a polkit rule).
#
# zz-steamos-autologin.conf is fully rewritten each time:
#   - gamescope -> only Session= (User= and Relogin=true are inherited from
#                  steam-deckify.conf, so autologin happens)
#   - plasma    -> override User= empty and Relogin=false to force the
#                  display manager to show the password prompt

USER_HOME=$(getent passwd | awk -F: '$3 >= 1000 && $3 < 60000 {print $6; exit}')
STATE_FILE="$USER_HOME/.config/last-session-mode"

if [[ -d /etc/plasmalogin.conf.d ]]; then
    CONF_FILE="/etc/plasmalogin.conf.d/zz-steamos-autologin.conf"
elif [[ -d /etc/sddm.conf.d ]]; then
    CONF_FILE="/etc/sddm.conf.d/zz-steamos-autologin.conf"
else
    exit 0
fi

if [[ -f "$STATE_FILE" ]]; then
    last_session=$(cat "$STATE_FILE")
else
    last_session="gamescope"
fi

case "$last_session" in
    plasma)
        cat > "$CONF_FILE" <<EOF
[Autologin]
User=
Relogin=false
Session=plasma.desktop
EOF
        ;;
    gamescope|*)
        cat > "$CONF_FILE" <<EOF
[Autologin]
Session=gamescope-session.desktop
EOF
        ;;
esac

chmod 644 "$CONF_FILE"
