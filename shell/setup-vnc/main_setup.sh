#!/bin/bash

# Main Setup Script - VNC + Desktop + Chrome
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔧 VNC Desktop Setup: Ubuntu"

# Select desktop environment
echo "👉 Select desktop environment:"
select DE_NAME in "GNOME" "MATE" "CINNAMON"; do
  [[ -n "$DE_NAME" ]] && break
done

# Select VNC server
echo "👉 Select VNC server:"
select VNC_NAME in "TurboVNC" "TigerVNC"; do
  [[ -n "$VNC_NAME" ]] && break
done

# Prompt for VNC password
echo -n "🔐 Enter a VNC password (8 chars max): "
read -s VNC_PASS
echo ""
echo -n "🔐 Confirm VNC password: "
read -s VNC_PASS_CONFIRM
echo ""
if [[ "$VNC_PASS" != "$VNC_PASS_CONFIRM" ]]; then
  echo "❌ Passwords do not match."
  exit 1
fi

# Prompt for resolution
read -p "🖥️ Enter screen resolution [default: 1920x1080]: " RESOLUTION
RESOLUTION=${RESOLUTION:-1920x1080}
read -p "🖍️ Enter color depth [default: 24]: " COLOR_DEPTH
COLOR_DEPTH=${COLOR_DEPTH:-24}

export DE_NAME VNC_NAME VNC_PASS RESOLUTION COLOR_DEPTH

# Run install modules
bash "$SCRIPT_DIR/install_desktop.sh"
bash "$SCRIPT_DIR/install_vnc.sh"
bash "$SCRIPT_DIR/install_chrome.sh"
bash "$SCRIPT_DIR/setup_autostart.sh"

echo "✅ All done! Reboot and login as your user. VNC will start automatically."
