#!/bin/bash

# wakeonlan -i 192.168.10.255 3C:7C:3F:20:22:DB # Home
# wakeonlan -i 192.168.10.255 00:E0:4C:94:AB:0D # USB HUB
# wakeonlan -i 192.168.10.255 74:56:3C:40:DE:33 # Home_borrow_MB
# wakeonlan -i 192.168.10.255 FC:34:97:A2:F4:9C
# wakeonlan -i 192.168.10.255 00:26:18:14:9B:1B

# Set broadcast address
BROADCAST_IP="192.168.10.255"

# Configure the MAC address of each device
DEVICE1_MAC="24:4B:FE:58:EA:B1" # Home
DEVICE2_MAC="00:E0:4C:94:AB:0D" # USB HUB
DEVICE3_MAC="" # TBD

case "$1" in
  1)
    echo "Waking up Home..."
    wakeonlan -i "$BROADCAST_IP" "$DEVICE1_MAC"
    ;;
  2)
    echo "Waking up USB HUB..."
    wakeonlan -i "$BROADCAST_IP" "$DEVICE2_MAC"
    ;;
  3)
    echo "Waking up TBD device..."
    wakeonlan -i "$BROADCAST_IP" "$DEVICE3_MAC"
    ;;
  *)
    echo "Usage: $0 {1|2|3}"
    echo "  1 - Home"
    echo "  2 - USB HUB"
    echo "  3 - TBD"
    exit 1
    ;;
esac

