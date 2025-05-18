#!/bin/bash
# Installs Google Chrome

set -e

echo "🌐 Installing Google Chrome..."
wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb
apt install -y /tmp/chrome.deb || apt -f install -y
rm -f /tmp/chrome.deb
