# VNC Desktop Setup for Ubuntu 22.04 (Raspberry Pi / VM)

This project sets up a lightweight desktop environment with VNC access on Ubuntu 22.04 using either **TurboVNC** or **TigerVNC**, plus **Google Chrome**.

## 🧩 Components

- `main_setup.sh` – Main script with interactive options
- `install_desktop.sh` – Install GNOME / MATE / Cinnamon
- `install_vnc.sh` – Install TurboVNC or TigerVNC and set password
- `install_chrome.sh` – Install Google Chrome
- `setup_autostart.sh` – Start VNC on user login via `.bash_profile`

## 📦 Installation

```bash
# Unpack the archive (once provided)
tar -xzvf setup-vnc.tar.gz
cd setup-vnc

# Make scripts executable
chmod +x *.sh

# Run main setup script as sudo
sudo ./main_setup.sh
```

## 🖥️ Usage

- Select your desktop and VNC server
- Set resolution (default: 1920x1080) and color depth (default: 24)
- Input a VNC password (max 8 characters)
- After reboot, log in via SSH or TTY, and VNC will auto-start

## 🛠 VNC Viewer

Connect to `your-host-ip:5901` using a VNC client like RealVNC or TightVNC.

## ❤️ Credits

Created with help from ChatGPT. Enjoy!
