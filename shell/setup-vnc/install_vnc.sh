#!/bin/bash
# Installs VNC server and configures xstartup

set -e

USERNAME="${SUDO_USER:-$USER}"
USER_HOME=$(eval echo "~$USERNAME")

if [[ "$VNC_NAME" == "TurboVNC" ]]; then
  echo "⬇️ Installing TurboVNC..."
  VNC_URL="https://downloads.sourceforge.net/project/turbovnc/3.0.3/turbovnc_3.0.3_amd64.deb"
  wget -q "$VNC_URL" -O /tmp/turbovnc.deb
  apt install -y /tmp/turbovnc.deb
  VNC_BIN="/opt/TurboVNC/bin/vncserver"
else
  echo "⬇️ Installing TigerVNC..."
  apt install -y tigervnc-standalone-server tigervnc-common
  VNC_BIN="/usr/bin/vncserver"
fi

echo "🔐 Setting VNC password"
runuser -l "$USERNAME" -c "mkdir -p ~/.vnc && echo \"$VNC_PASS\" | vncpasswd -f > ~/.vnc/passwd && chmod 600 ~/.vnc/passwd"

XSTARTUP="$USER_HOME/.vnc/xstartup"
echo "📝 Writing $XSTARTUP"
cat <<EOF > "$XSTARTUP"
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export XKL_XMODMAP_DISABLE=1

case "$DE_NAME" in
  GNOME)    exec gnome-session ;;
  MATE)     exec mate-session ;;
  CINNAMON) exec cinnamon-session ;;
esac
EOF

chown "$USERNAME:$USERNAME" "$XSTARTUP"
chmod +x "$XSTARTUP"
