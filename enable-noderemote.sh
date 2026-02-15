#!/bin/bash
# Enable NodeRemote app support for AllStarLink 3
# This script configures manager.conf and sets up astdb.txt access
# Run as: sudo bash enable-noderemote.sh [password] [username]
# If no password provided, will use default 'radioless'
# If no username provided, will use default 'rln'

# SPDX-FileCopyrightText: 2025 G1LRO
# SPDX-License-Identifier: MIT
# SPDX-License-Identifier: CC-BY-NC-4.0
#
# This work is licensed under the Creative Commons Attribution-NonCommercial 4.0
# International License. To view a copy of this license, visit
# http://creativecommons.org/licenses/by-nc/4.0/ or send a letter to Creative
# Commons, PO Box 1866, Mountain View, CA 94042, USA.
#
# This software is free to use and modify for noncommercial purposes. The original
# copyright notices (including those of G1LRO) must be
# retained in all copies or substantial portions of the software.

set -e

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Error: This script must be run as root (use sudo)"
    exit 1
fi

# Get password from argument or use default
MANAGER_PASSWORD="${1:-radioless}"

# Get username from second argument or use default
MANAGER_USERNAME="${2:-rln}"

MANAGER_CONF="/etc/asterisk/manager.conf"
MANAGER_BACKUP="/etc/asterisk/manager.conf.backup-$(date +%Y%m%d-%H%M%S)"

echo "================================================"
echo "NodeRemote Configuration Script for ASL3"
echo "================================================"
echo ""

# Step 1: Backup existing manager.conf
if [ -f "$MANAGER_CONF" ]; then
    echo "[+] Backing up existing manager.conf to:"
    echo "    $MANAGER_BACKUP"
    cp "$MANAGER_CONF" "$MANAGER_BACKUP"
else
    echo "[!] Warning: $MANAGER_CONF not found, creating new file"
fi

# Step 2: Create/update manager.conf
echo "[+] Configuring manager.conf for NodeRemote access..."
cat > "$MANAGER_CONF" << EOFMANAGER
;
; Asterisk Call Management support
; Configured for NodeRemote app access
;

[general]
displaysystemname = yes
enabled = yes
webenabled = yes
port = 5038

;httptimeout = 60

; Allow external access - NodeRemote requires this
bindaddr = 0.0.0.0

;displayconnects = yes

; Add a Unix epoch timestamp to events
;timestampevents = yes

[$MANAGER_USERNAME]
secret = $MANAGER_PASSWORD
read = all,system,call,log,verbose,command,agent,user,config
write = all,system,call,log,verbose,command,agent,user,config
EOFMANAGER

echo "[+] Manager username set to: $MANAGER_USERNAME"
echo "[+] Manager password set to: $MANAGER_PASSWORD"
echo ""

# Step 2.5: Update allmon3.ini with matching credentials
echo "[+] Updating allmon3.ini with matching credentials..."

ALLMON_CONF="/etc/allmon3/allmon3.ini"

if [ -f "$ALLMON_CONF" ]; then
    # Backup allmon3.ini
    ALLMON_BACKUP="/etc/allmon3/allmon3.ini.backup-$(date +%Y%m%d-%H%M%S)"
    cp "$ALLMON_CONF" "$ALLMON_BACKUP"
    echo "[+] Backed up allmon3.ini to: $ALLMON_BACKUP"
    
    # Find the node number from the existing configuration
    NODE_NUMBER=$(grep -E "^\[[0-9]+\]" "$ALLMON_CONF" | head -1 | tr -d '[]')
    
    if [ -n "$NODE_NUMBER" ]; then
        # Update the user and pass lines under the node section
        # Use sed to update lines after the node section
        sed -i "/^\[$NODE_NUMBER\]/,/^\[/ {
            s/^user=.*/user=$MANAGER_USERNAME/
            s/^pass=.*/pass=$MANAGER_PASSWORD/
        }" "$ALLMON_CONF"
        
        echo "[+] Updated allmon3.ini node [$NODE_NUMBER]:"
        echo "    user=$MANAGER_USERNAME"
        echo "    pass=$MANAGER_PASSWORD"
    else
        echo "[!] Warning: Could not find node number in allmon3.ini"
        echo "    You may need to manually update /etc/allmon3/allmon3.ini"
    fi
else
    echo "[!] Warning: $ALLMON_CONF not found"
    echo "    Allmon3 may not be installed or configured"
fi
echo ""

# Step 3: Configure ASL3 firewall to allow port 5038
echo "[+] Checking ASL3 firewall configuration..."

# Try to add firewall rule using firewall-cmd if available
if command -v firewall-cmd >/dev/null 2>&1; then
    echo "[+] Adding firewall rule for port 5038..."
    
    # Check if rule already exists
    if firewall-cmd --list-ports 2>/dev/null | grep -q "5038/tcp"; then
        echo "    Port 5038 already open in firewall"
    else
        # Add permanent rule
        firewall-cmd --permanent --add-port=5038/tcp 2>/dev/null || true
        firewall-cmd --reload 2>/dev/null || true
        echo "    Port 5038 opened in firewall"
    fi
else
    echo "[!] firewall-cmd not found, skipping firewall configuration"
    echo "    You may need to manually open port 5038 in ASL3 web interface"
fi

echo ""

# Step 4: Enable and configure astdb.txt service
echo "[+] Configuring astdb.txt service..."

# Enable the service and timer
systemctl enable asl3-update-astdb.service 2>/dev/null || echo "[!] Warning: Could not enable asl3-update-astdb.service"
systemctl enable asl3-update-astdb.timer 2>/dev/null || echo "[!] Warning: Could not enable asl3-update-astdb.timer"
systemctl start asl3-update-astdb.timer 2>/dev/null || echo "[!] Warning: Could not start asl3-update-astdb.timer"

echo "[+] astdb.txt automatic updates enabled"
echo ""

# Step 5: Create symlink for astdb.txt
echo "[+] Setting up astdb.txt web access..."

# Create directory if it doesn't exist
if [ ! -d "/var/www/html/allmon2" ]; then
    mkdir -p /var/www/html/allmon2
    echo "[+] Created directory: /var/www/html/allmon2"
fi

# Remove existing symlink if present
if [ -L "/var/www/html/allmon2/astdb.txt" ]; then
    rm /var/www/html/allmon2/astdb.txt
    echo "[+] Removed existing astdb.txt symlink"
fi

# Create symlink
ln -s /var/lib/asterisk/astdb.txt /var/www/html/allmon2/astdb.txt
echo "[+] Created symlink: /var/www/html/allmon2/astdb.txt -> /var/lib/asterisk/astdb.txt"
echo ""

# Step 6: Trigger immediate astdb.txt download if file doesn't exist
if [ ! -f "/var/lib/asterisk/astdb.txt" ]; then
    echo "[+] Triggering initial astdb.txt download..."
    systemctl start asl3-update-astdb.service 2>/dev/null || echo "[!] Warning: Could not trigger initial download"
    sleep 2
    
    if [ -f "/var/lib/asterisk/astdb.txt" ]; then
        echo "    astdb.txt downloaded successfully"
    else
        echo "[!] Warning: astdb.txt not yet available, it may take a few minutes"
    fi
fi

echo ""

# Step 7: Restart Asterisk to apply changes
echo "[+] Restarting Asterisk service..."
systemctl restart asterisk

# Wait for Asterisk to restart
sleep 3

if systemctl is-active --quiet asterisk; then
    echo "    Asterisk restarted successfully"
else
    echo "[!] Warning: Asterisk may not have restarted correctly"
    echo "    Check with: systemctl status asterisk"
fi

echo ""
echo "================================================"
echo "G1LRO NodeRemote Configuration Complete!"
echo "================================================"
echo ""
echo "Configuration Summary:"
echo "  Manager Port:     5038"
echo "  Manager Username: $MANAGER_USERNAME"
echo "  Manager Password: $MANAGER_PASSWORD"
echo "  Bind Address:     0.0.0.0 (all interfaces)"
echo "  Firewall:         Port 5038 open"
echo "  astdb.txt:        Enabled and accessible"
echo "  Allmon3:          Credentials synchronized"
echo ""
echo "NodeRemote App Setup:"
echo "  1. Open NodeRemote app on your device"
echo "  2. Add new node with following details:"
echo "     - Node IP: [Your Raspberry Pi IP address]"
echo "     - Port: 5038"
echo "     - Username: $MANAGER_USERNAME"
echo "     - Password: $MANAGER_PASSWORD"
echo ""
echo "Troubleshooting:"
echo "  - Find your IP: hostname -I"
echo "  - Test manager port: telnet localhost 5038"
echo "  - Check Asterisk: systemctl status asterisk"
echo "  - View logs: journalctl -u asterisk -f"
echo "  - Check firewall: firewall-cmd --list-ports"
echo "  - Verify astdb.txt: ls -la /var/www/html/allmon2/astdb.txt"
echo ""
echo "Security Note:"
echo "  This configuration allows external access to your node."
echo "  Ensure you use a strong password and consider firewall"
echo "  restrictions if deploying on a public network."
echo ""
echo "Backup saved to: $MANAGER_BACKUP"
echo "================================================"
