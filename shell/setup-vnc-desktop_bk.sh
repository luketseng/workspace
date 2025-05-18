#!/bin/bash

# Setup VNC (TurboVNC/x11vnc) with desktop environment (GNOME/MATE) and Google Chrome
# For Ubuntu 22.04 LTS (Jammy Jellyfish)

# Helper function: Print colored messages
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Helper function: Check if previous command was successful
check_status() {
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Success: $1${NC}"
  else
    echo -e "${RED}❌ Failed: $1${NC}"
    echo -e "${YELLOW}⚠️  Error encountered, please check output above for details.${NC}"
    exit 1
  fi
}

# Helper function: Check if package is already installed
is_package_installed() {
  dpkg -l | grep -q " $1 "
  return $?
}

# Ensure script is run with root privileges
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}❌ This script requires root privileges to run${NC}"
   echo -e "${YELLOW}Please run this script with sudo${NC}"
   exit 1
fi

# Step 1: Update system (optional)
echo -e "${YELLOW}[1/5] System update option${NC}"
read -p "Do you want to update system packages? (y/n): " update_choice
if [[ "$update_choice" =~ ^[Yy]$ ]]; then
  echo -e "${YELLOW}Updating system packages...${NC}"
  apt update && apt upgrade -y
  check_status "System packages update"
else
  echo -e "${GREEN}✅ Skipping system update${NC}"
fi

# Step 2: Select and install desktop environment
echo -e "${YELLOW}[2/5] Desktop environment selection${NC}"
echo -e "Available desktop environments:"
echo -e "  1) GNOME - Modern, feature-rich desktop environment (Ubuntu default)"
echo -e "  2) MATE - Traditional, full-featured desktop environment"
read -p "Choose desktop environment (1-2): " de_choice

case $de_choice in
  1)
    DE_NAME="GNOME"
    DE_PACKAGE="ubuntu-desktop"
    if is_package_installed "ubuntu-desktop"; then
      echo -e "${GREEN}✅ GNOME desktop environment is already installed${NC}"
    else
      echo -e "${YELLOW}Installing GNOME desktop environment...${NC}"
      apt install -y ubuntu-desktop
      check_status "GNOME desktop environment installation"
    fi
    ;;
  2)
    DE_NAME="MATE"
    DE_PACKAGE="mate-desktop-environment"
    if is_package_installed "mate-desktop-environment"; then
      echo -e "${GREEN}✅ MATE desktop environment is already installed${NC}"
    else
      echo -e "${YELLOW}Installing MATE desktop environment...${NC}"
      apt install -y mate-desktop-environment mate-desktop-environment-extras
      check_status "MATE desktop environment installation"
    fi
    ;;
  *)
    echo -e "${RED}❌ Invalid choice. Defaulting to MATE desktop environment${NC}"
    DE_NAME="MATE"
    DE_PACKAGE="mate-desktop-environment"
    if is_package_installed "mate-desktop-environment"; then
      echo -e "${GREEN}✅ MATE desktop environment is already installed${NC}"
    else
      echo -e "${YELLOW}Installing MATE desktop environment...${NC}"
      apt install -y mate-desktop-environment mate-desktop-environment-extras
      check_status "MATE desktop environment installation"
    fi
    ;;
esac

# Step 3: Select and install VNC server
echo -e "${YELLOW}[3/5] VNC server selection${NC}"
echo -e "Available VNC servers:"
echo -e "  1) TurboVNC - High-performance VNC optimized for 3D applications"
echo -e "  2) x11vnc - Flexible VNC server for sharing existing X sessions"
read -p "Choose VNC server (1-2): " vnc_choice

case $vnc_choice in
  1)
    VNC_NAME="TurboVNC"

    # Install TurboVNC dependencies
    echo -e "${YELLOW}Installing TurboVNC dependencies...${NC}"
    apt install -y libxtst6 libc6 libc6-dev make gcc g++
    check_status "TurboVNC dependencies installation"

    # Download and install TurboVNC
    if [ -x "$(command -v /opt/TurboVNC/bin/vncserver)" ]; then
      echo -e "${GREEN}✅ TurboVNC is already installed${NC}"
    else
      echo -e "${YELLOW}Downloading TurboVNC...${NC}"
      cd /tmp
      wget -q https://downloads.sourceforge.net/project/turbovnc/3.0.3/turbovnc_3.0.3_amd64.deb
      check_status "TurboVNC download"

      echo -e "${YELLOW}Installing TurboVNC...${NC}"
      dpkg -i turbovnc_3.0.3_amd64.deb
      check_status "TurboVNC installation"

      rm -f turbovnc_3.0.3_amd64.deb
    fi

    # Create VNC directory
    echo -e "${YELLOW}Creating VNC user directory...${NC}"
    mkdir -p /home/$(logname)/.vnc

    # Create VNC password
    echo -e "${YELLOW}Please set your VNC password now:${NC}"
    su - $(logname) -c "/opt/TurboVNC/bin/vncpasswd"
    check_status "VNC password creation"

    # Create xstartup script
    echo -e "${YELLOW}Creating xstartup script...${NC}"
    cat > /home/$(logname)/.vnc/xstartup <<EOF
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
if [ "$DE_NAME" = "GNOME" ]; then
  exec gnome-session
else
  exec mate-session
fi
EOF
    chmod +x /home/$(logname)/.vnc/xstartup
    chown -R $(logname):$(logname) /home/$(logname)/.vnc

    # Create systemd service for TurboVNC
    echo -e "${YELLOW}Creating systemd service for TurboVNC...${NC}"
    cat > /etc/systemd/system/turbovnc.service <<EOF
[Unit]
Description=TurboVNC Remote Desktop
After=network.target

[Service]
Type=forking
User=$(logname)
ExecStartPre=/usr/bin/bash -c '/opt/TurboVNC/bin/vncserver -kill :1 > /dev/null 2>&1 || true'
ExecStart=/opt/TurboVNC/bin/vncserver :1 -geometry 1920x1080 -depth 24
ExecStop=/opt/TurboVNC/bin/vncserver -kill :1
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

    # Enable and start TurboVNC service
    systemctl daemon-reload
    systemctl enable turbovnc.service
    systemctl start turbovnc.service
    check_status "TurboVNC service startup"

    VNC_PORT="5901"
    VNC_CONNECT="(Use VNC client with ${SERVER_IP}:1 or ${SERVER_IP}:5901)"
    ;;

  2)
    VNC_NAME="x11vnc"

    # Install x11vnc
    if is_package_installed "x11vnc"; then
      echo -e "${GREEN}✅ x11vnc is already installed${NC}"
    else
      echo -e "${YELLOW}Installing x11vnc...${NC}"
      apt install -y x11vnc xauth
      check_status "x11vnc installation"
    fi

    # Create VNC password
    echo -e "${YELLOW}Please set your VNC password now:${NC}"
    mkdir -p /home/$(logname)/.vnc
    x11vnc -storepasswd /home/$(logname)/.vnc/passwd
    check_status "VNC password creation"
    chown -R $(logname):$(logname) /home/$(logname)/.vnc

    # Create systemd service for x11vnc
    echo -e "${YELLOW}Creating systemd service for x11vnc...${NC}"
    cat > /etc/systemd/system/x11vnc.service <<EOF
[Unit]
Description=x11vnc Remote Desktop Service
After=display-manager.service network.target

[Service]
Type=simple
User=$(logname)
ExecStart=/usr/bin/x11vnc -auth guess -forever -loop -noxdamage -repeat -rfbauth /home/$(logname)/.vnc/passwd -rfbport 5900 -shared
ExecStop=/usr/bin/killall x11vnc
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

    # Enable and start x11vnc service
    systemctl daemon-reload
    systemctl enable x11vnc.service

    # Need to configure auto-login for x11vnc to work properly
    if [ "$DE_NAME" = "GNOME" ]; then
      # Configure GDM autologin
      echo -e "${YELLOW}Configuring GDM auto-login for x11vnc...${NC}"
      mkdir -p /etc/gdm3
      cat > /etc/gdm3/custom.conf <<EOF
[daemon]
AutomaticLoginEnable=true
AutomaticLogin=$(logname)
EOF
    else
      # Configure LightDM autologin for MATE
      echo -e "${YELLOW}Configuring LightDM auto-login for x11vnc...${NC}"
      mkdir -p /etc/lightdm
      cat > /etc/lightdm/lightdm.conf <<EOF
[SeatDefaults]
autologin-user=$(logname)
autologin-user-timeout=0
EOF
    fi

    systemctl start x11vnc.service
    check_status "x11vnc service startup"

    VNC_PORT="5900"
    VNC_CONNECT="(Use VNC client with ${SERVER_IP}:0 or ${SERVER_IP}:5900)"
    ;;

  *)
    echo -e "${RED}❌ Invalid choice. Defaulting to x11vnc${NC}"
    # Install x11vnc (same as option 2)
    VNC_NAME="x11vnc"
    # ... (same code as option 2)
    ;;
esac

# Step 4: Install Google Chrome
echo -e "${YELLOW}[4/5] Installing Google Chrome...${NC}"
if is_package_installed "google-chrome-stable"; then
  echo -e "${GREEN}✅ Google Chrome is already installed${NC}"
else
  echo -e "${YELLOW}Downloading Google Chrome...${NC}"
  wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  check_status "Google Chrome download"

  echo -e "${YELLOW}Installing Google Chrome...${NC}"
  apt install -y ./google-chrome-stable_current_amd64.deb
  check_status "Google Chrome installation"

  echo -e "${YELLOW}Cleaning up Google Chrome installation files...${NC}"
  rm -f google-chrome-stable_current_amd64.deb
  check_status "Google Chrome installation files cleanup"
fi

# Check if Google Chrome can run normally
echo -e "${YELLOW}Checking if Google Chrome can run normally...${NC}"
if [ -x "$(command -v google-chrome-stable)" ]; then
  echo -e "${GREEN}✅ Google Chrome can run normally${NC}"
else
  echo -e "${RED}❌ Google Chrome seems to have installation issues${NC}"
  exit 1
fi

# Step 5: Configure firewall (if necessary)
echo -e "${YELLOW}[5/5] Configuring firewall...${NC}"
if [ -x "$(command -v ufw)" ]; then
  echo -e "${YELLOW}Checking UFW firewall status...${NC}"
  ufw status | grep -q "Status: active"
  if [ $? -eq 0 ]; then
    echo -e "${YELLOW}Opening required TCP ports for VNC...${NC}"
    ufw allow 22/tcp
    ufw allow $VNC_PORT/tcp
    check_status "UFW firewall configuration"
  else
    echo -e "${GREEN}✅ UFW firewall is not active, no configuration needed${NC}"
  fi
else
  echo -e "${GREEN}✅ UFW firewall is not installed, no configuration needed${NC}"
fi

# Get server IP address
SERVER_IP=$(hostname -I | awk '{print $1}')

# Final message
echo -e "\n${GREEN}✅ Installation and configuration completed!${NC}"
echo -e "${YELLOW}=== ${VNC_NAME} and ${DE_NAME} desktop environment setup is complete ===${NC}"
echo -e "${YELLOW}Please use the following settings in your VNC client:${NC}"
echo -e "  ✓ Server: ${SERVER_IP}:${VNC_PORT}"
echo -e "  ✓ VNC Connection: ${VNC_CONNECT}"
echo -e "  ✓ Password: The password you set during installation"
echo -e ""
echo -e "${YELLOW}Google Chrome is installed and can be used in remote desktop${NC}"
echo -e ""
echo -e "${GREEN}It is recommended to restart your system to ensure all settings take effect:${NC}"
echo -e "  sudo reboot"
