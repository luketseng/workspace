#!/bin/bash
# start_vnc.sh - Start or stop TurboVNC session with custom xstartup

VNC_BIN="/opt/TurboVNC/bin/vncserver"
DISPLAY_NUM=":1"
RESOLUTION="1920x1080"
DEPTH="24"
XSTARTUP="$HOME/.vnc/xstartup"

# Generate custom xstartup for Cinnamon if not exist
function generate_xstartup() {
    echo "🛠  Generating $XSTARTUP for Cinnamon..."
    mkdir -p ~/.vnc

    cat > "$XSTARTUP" <<'EOF'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export XKL_XMODMAP_DISABLE=1
xrdb $HOME/.Xresources
exec cinnamon-session
EOF

    chmod +x "$XSTARTUP"
}

function start_vnc() {
    echo "🔧 Starting TurboVNC on display $DISPLAY_NUM..."
    generate_xstartup
    $VNC_BIN $DISPLAY_NUM -geometry $RESOLUTION -depth $DEPTH -xstartup "$XSTARTUP"
}

function stop_vnc() {
    echo "🛑 Stopping TurboVNC on display $DISPLAY_NUM..."
    $VNC_BIN -kill $DISPLAY_NUM
}

case "$1" in
    start)
        start_vnc
        ;;
    stop)
        stop_vnc
        ;;
    restart)
        stop_vnc
        sleep 1
        start_vnc
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 1
        ;;
esac

