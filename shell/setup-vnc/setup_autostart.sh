#!/bin/bash
# Sets up autostart in .bash_profile

set -e

USERNAME="${SUDO_USER:-$USER}"
USER_HOME=$(eval echo "~$USERNAME")
BASH_PROFILE="$USER_HOME/.bash_profile"

VNC_BIN=$(command -v vncserver)
ARGS="-geometry ${RESOLUTION} -depth ${COLOR_DEPTH}"

echo "🛠 Setting autostart in $BASH_PROFILE"
touch "$BASH_PROFILE"
grep -q "$VNC_BIN" "$BASH_PROFILE" || echo "[[ -z \$DISPLAY && \$(pgrep Xvnc) == "" ]] && $VNC_BIN $ARGS" >> "$BASH_PROFILE"
chown "$USERNAME:$USERNAME" "$BASH_PROFILE"
