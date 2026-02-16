![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![License: CC BY-NC 4.0](https://img.shields.io/badge/License-CC%20BY--NC%204.0-lightgrey.svg)
![Platform](https://img.shields.io/badge/platform-Raspberry%20Pi-red.svg)
![ASL3](https://img.shields.io/badge/ASL-3.0-blue.svg)
![Shell Script](https://img.shields.io/badge/shell-bash-green.svg)


# NodeRemote Setup for AllStarLink 3 (ASL3)

## Quick Start Guide for Enabling NodeRemote on Your ASL3 Raspberry Pi Node

This guide will help you set up the NodeRemote mobile app to control your AllStarLink 3 node from your smartphone or tablet.

## What is NodeRemote?

NodeRemote is a mobile application (iOS and Android) that allows you to:
- Connect and disconnect from other nodes remotely
- Monitor active connections in real-time
- View node information and status
- Control your node from anywhere with internet access

## Prerequisites

Before you begin, ensure you have:
- ✓ Raspberry Pi running AllStarLink 3 (ASL3)
- ✓ SSH access to your Raspberry Pi
- ✓ Your node is configured and working
- ✓ Internet connection on your Raspberry Pi
- ✓ NodeRemote app installed on your mobile device

### Get the NodeRemote App

- **iOS**: Search "Node Remote" in Apple App Store
- **Android**: Search "Node Remote" in Google Play Store

## Installation Steps

### Step 1: Download the Configuration Script

SSH into your Raspberry Pi and download the script:

```bash
cd ~
wget https://raw.githubusercontent.com/G1LRO/node-remote-setup/refs/heads/main/enable-noderemote.sh
chmod +x enable-noderemote.sh
```

### Step 2: Run the Configuration Script

Run the script with sudo (default credentials: username=rln, password=radioless):

```bash
sudo bash enable-noderemote.sh
```

**Or with custom credentials:**

```bash
# Custom password only (username defaults to 'rln'):
sudo bash enable-noderemote.sh mypassword

# Custom password AND username:
sudo bash enable-noderemote.sh mypassword myusername
```

### Step 3: Wait for Completion

The script will:
- ✓ Backup your existing configuration files
- ✓ Configure Asterisk manager interface
- ✓ Update Allmon3 credentials (if installed)
- ✓ Open firewall port 5038
- ✓ Enable astdb.txt automatic updates
- ✓ Restart Asterisk service

You'll see output like this:

```
================================================
NodeRemote Configuration Complete!
================================================

Configuration Summary:
  Manager Port:     5038
  Manager Username: rln
  Manager Password: radioless
  Bind Address:     0.0.0.0 (all interfaces)
  Firewall:         Port 5038 open
  astdb.txt:        Enabled and accessible
  Allmon3:          Credentials synchronized
```

### Step 4: Find Your Raspberry Pi IP Address

Note the IP address shown in the output, or find it with:

```bash
hostname -I
```

Example output: `192.168.1.100`

## Configure NodeRemote App

### Step 1: Open NodeRemote App

Launch the NodeRemote app on your mobile device.

### Step 2: Add Your Node

1. Tap the **+** (Add Node) button
2. Enter the following information:

   | Field | Value |
   |-------|-------|
   | **Node Name** | Your choice (e.g., "Home Node" or your callsign) |
   | **Host/IP Address** | Your Raspberry Pi IP (e.g., 192.168.1.100) |
   | **Port** | 5038 |
   | **Username** | rln (or your custom username) |
   | **Password** | radioless (or your custom password) |

3. Tap **Save** or **Connect**

### Step 3: Test Connection

- The app should connect and show your node status
- You should see your node number and any active connections
- The astdb.txt database will load (may take a few moments on first connection)

## Verification

### Check if Everything is Working

Run the included test script:

```bash
sudo bash test-noderemote.sh
```

You should see all tests pass:

```
================================================
NodeRemote Configuration Verification
================================================

1. Checking manager.conf configuration... PASS
2. Checking if port 5038 is listening... PASS
3. Checking firewall configuration... PASS
4. Checking astdb.txt symlink... PASS
5. Checking astdb.txt source file... PASS
6. Checking astdb update service... PASS
7. Checking Asterisk service... PASS
8. Testing manager interface connection... PASS
9. Checking allmon3.ini configuration... PASS

================================================
Test Results: 9 passed, 0 failed
================================================
```

### Manual Verification

You can also manually verify the configuration:

```bash
# Check manager interface is listening:
sudo netstat -tulpn | grep 5038

# Check Asterisk status:
sudo systemctl status asterisk

# View manager configuration:
sudo cat /etc/asterisk/manager.conf

# Test manager interface locally:
telnet localhost 5038
```

## Troubleshooting

### App Shows "Cannot Connect to Node"

**Check 1: Verify IP Address**
```bash
hostname -I
```
Make sure you're using the correct IP in the app.

**Check 2: Verify Port is Listening**
```bash
sudo netstat -tulpn | grep 5038
```
Should show asterisk listening on port 5038.

**Check 3: Verify Firewall**
```bash
sudo firewall-cmd --list-ports
```
Should show `5038/tcp` in the list.

**Check 4: Test Local Connection**
```bash
telnet localhost 5038
```
Should show "Asterisk Call Manager" message.

**Check 5: Verify Credentials**
```bash
sudo grep -A 3 "^\[rln\]" /etc/asterisk/manager.conf
```
Verify the username and password match what you entered in the app.

### App Shows "ASTDB.TXT Not Found"

This usually resolves automatically after a few minutes. If it persists:

```bash
# Check if service is running:
sudo systemctl status asl3-update-astdb.timer

# Manually trigger download:
sudo systemctl start asl3-update-astdb.service

# Check if file exists:
ls -la /var/www/html/allmon2/astdb.txt
```

Force close and reopen the NodeRemote app after running these commands.

### Connection Works But Can't Control Node

**Check Asterisk is Running:**
```bash
sudo systemctl status asterisk
```

**Check Asterisk Logs:**
```bash
sudo asterisk -rx "core show version"
journalctl -u asterisk -f
```

**Verify Manager Permissions:**
```bash
sudo cat /etc/asterisk/manager.conf
```
Ensure the user has both `read` and `write` permissions.

### Allmon3 Stopped Working After Setup

The script updates Allmon3 credentials to match NodeRemote. If Allmon3 isn't working:

```bash
# Check allmon3.ini:
sudo cat /etc/allmon3/allmon3.ini

# Restart allmon3:
sudo systemctl restart allmon3
```

### Need to Change Password

Run the script again with your new password:

```bash
sudo bash enable-noderemote.sh newpassword rln
```

This will update both Asterisk manager and Allmon3 configurations.

## Remote Access (Internet Access)

To access your node from outside your home network:

### Option 1: Port Forwarding (Direct Access)

1. **Log into your router's admin interface**
2. **Set up port forwarding:**
   - External Port: 5038 (or choose another for security)
   - Internal Port: 5038
   - Internal IP: Your Raspberry Pi's IP address
   - Protocol: TCP

3. **Find your public IP address:**
   - Visit https://whatismyip.com

4. **In NodeRemote app, use:**
   - Host: Your public IP address
   - Port: 5038 (or your chosen external port)
   - Username: rln
   - Password: radioless

**⚠️ SECURITY WARNING:** This exposes your node to the internet. Use a strong password!

### Option 2: VPN (Recommended for Security)

Set up a VPN server on your home network (like WireGuard or OpenVPN) and connect to your VPN before using NodeRemote. This is much more secure than direct port forwarding.

## Security Best Practices

### Change Default Password

The default password `radioless` is fine for home use, but if you're exposing your node to the internet:

```bash
# Use a strong password with mixed case, numbers, and symbols:
sudo bash enable-noderemote.sh "MyStr0ng!P@ssw0rd" rln
```

### Restrict Access by IP (Advanced)

If you want to limit which IP addresses can connect:

1. Edit `/etc/asterisk/manager.conf`
2. Add under the `[rln]` section:
   ```
   deny = 0.0.0.0/0.0.0.0
   permit = 192.168.1.0/255.255.255.0
   ```
3. Restart Asterisk: `sudo systemctl restart asterisk`

### Use VPN for Remote Access

Instead of exposing port 5038 to the internet, set up a VPN and connect to your home network first. This is much more secure.

## What the Script Configures

The `enable-noderemote.sh` script automatically configures:

### 1. Asterisk Manager Interface
- File: `/etc/asterisk/manager.conf`
- Port: 5038
- Bind Address: 0.0.0.0 (all interfaces)
- User and password as specified

### 2. Allmon3 Configuration (if installed)
- File: `/etc/allmon3/allmon3.ini`
- Updates credentials to match manager.conf
- Ensures Allmon3 continues working

### 3. Firewall
- Opens port 5038/tcp
- Uses firewall-cmd (ASL3 standard)

### 4. astdb.txt Service
- Enables automatic node database downloads
- Creates symlink at `/var/www/html/allmon2/astdb.txt`
- Required for NodeRemote's node search feature

### 5. Backups
All modified files are backed up with timestamps:
- `/etc/asterisk/manager.conf.backup-YYYYMMDD-HHMMSS`
- `/etc/allmon3/allmon3.ini.backup-YYYYMMDD-HHMMSS`

## Uninstalling / Reverting

To revert to your previous configuration:

```bash
# Find your backup files:
ls -la /etc/asterisk/manager.conf.backup-*
ls -la /etc/allmon3/allmon3.ini.backup-*

# Restore from backup (replace date/time with your backup):
sudo cp /etc/asterisk/manager.conf.backup-20240207-160109 /etc/asterisk/manager.conf
sudo cp /etc/allmon3/allmon3.ini.backup-20240207-160109 /etc/allmon3/allmon3.ini

# Restart Asterisk:
sudo systemctl restart asterisk
```

To close the firewall port:

```bash
sudo firewall-cmd --permanent --remove-port=5038/tcp
sudo firewall-cmd --reload
```

## Advanced Usage

### Custom Manager Username

If you want to use a different username (e.g., "admin"):

```bash
sudo bash enable-noderemote.sh radioless admin
```

### Multiple Users

You can add multiple manager users by manually editing `/etc/asterisk/manager.conf`:

```ini
[rln]
secret = radioless
read = all
write = all

[admin]
secret = differentpassword
read = all
write = all
```

Then restart Asterisk:
```bash
sudo systemctl restart asterisk
```

### Check Connected Clients

To see who's connected to your manager interface:

```bash
sudo asterisk -rx "manager show connected"
```

## Getting Help

### Useful Commands

```bash
# Check Asterisk status:
sudo systemctl status asterisk

# View Asterisk logs:
journalctl -u asterisk -f

# Test manager interface:
telnet localhost 5038

# View current manager users:
sudo asterisk -rx "manager show users"

# Check connected manager sessions:
sudo asterisk -rx "manager show connected"

# Check firewall status:
sudo firewall-cmd --list-all
```

### Log Files

Check these log files if you're having issues:

- Asterisk: `journalctl -u asterisk`
- Allmon3: `journalctl -u allmon3`
- System: `journalctl -xe`

### Support Resources

- **AllStarLink Community:** https://community.allstarlink.org/
- **NodeRemote Documentation:** https://dstarcomms.com/node-remote/
- **ASL3 Documentation:** https://docs.allstarlink.org/

## Frequently Asked Questions

### Q: Will this affect my existing Allmon3 installation?

A: The script updates Allmon3 to use the same credentials as NodeRemote. Your Allmon3 will continue working with the new credentials.

### Q: Can I use NodeRemote and Allmon3 at the same time?

A: Yes! Both can connect simultaneously using the same credentials.

### Q: Do I need to run this script again after updating ASL3?

A: Generally no, but if an ASL3 update resets your manager.conf, you may need to run it again.

### Q: Can I access my node from the internet?

A: Yes, but you'll need to set up port forwarding on your router and use a strong password. VPN access is recommended for better security.

### Q: Will this work on other platforms besides Raspberry Pi?

A: Yes, this script works on any Linux system running ASL3, including x86/x64 computers.

### Q: Does this require a static IP address?

A: Not required for local network access. For internet access, you'll need either a static IP or dynamic DNS service.

### Q: What if I forget my password?

A: Simply run the script again with a new password. Or check the current password with:
```bash
sudo grep "^secret" /etc/asterisk/manager.conf
```

## License

This script is licensed under:
- MIT License
- Creative Commons Attribution-NonCommercial 4.0 International (CC-BY-NC-4.0)

Free to use and modify for non-commercial purposes. Original copyright notices must be retained.

## Credits

**Script Author:** GU1LRO
**NodeRemote App:** dstarcomms.com
**AllStarLink:** AllStarLink.org

---

**Last Updated:** February 2026
**Script Version:** 1.0
**Compatible with:** AllStarLink 3 (ASL3) on Raspberry Pi and compatible platforms
