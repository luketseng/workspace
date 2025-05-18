#!/bin/bash
# Installs selected desktop environment

set -e

case "$DE_NAME" in
  GNOME)    DESKTOP_PKG="ubuntu-desktop" ;;
  MATE)     DESKTOP_PKG="ubuntu-mate-desktop" ;;
  CINNAMON) DESKTOP_PKG="cinnamon-desktop-environment" ;;
  *)        echo "❌ Unknown desktop"; exit 1 ;;
esac

echo "📦 Installing desktop: $DESKTOP_PKG"
apt update
apt install -y "$DESKTOP_PKG" wget curl gnupg
