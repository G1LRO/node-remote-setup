# NodeRemote Setup for AllStarLink 3

Automatically configure your ASL3 node for the NodeRemote mobile app with a single command.

## Quick Install

```bash
wget https://raw.githubusercontent.com/G1LRO/node-remote-setup/refs/heads/main/enable-noderemote.sh && chmod +x enable-noderemote.sh && sudo bash enable-noderemote.sh
```

**Default credentials:** `rln` / `radioless`

## What This Does

- ✅ Configures Asterisk manager interface for NodeRemote access
- ✅ Synchronizes Allmon3 credentials automatically
- ✅ Opens firewall port 5038
- ✅ Enables astdb.txt automatic updates for node database
- ✅ Creates backups of all modified files
- ✅ Restarts services to apply changes

## Requirements

- AllStarLink 3 (ASL3) on Raspberry Pi or compatible system
- SSH access to your node
- NodeRemote app ([iOS](https://apps.apple.com/app/node-remote) / [Android](https://play.google.com/store/apps/details?id=com.dstarcomms.noderemote))

## Usage

### Default Credentials (rln/radioless)
```bash
sudo bash enable-noderemote.sh
```

### Custom Password
```bash
sudo bash enable-noderemote.sh mypassword
```

### Custom Username AND Password
```bash
sudo bash enable-noderemote.sh mypassword myusername
```

## Configure NodeRemote App

After running the script, open the NodeRemote app and add your node:

| Field | Value |
|-------|-------|
| **Host** | Your Raspberry Pi IP address |
| **Port** | 5038 |
| **Username** | rln (or your custom username) |
| **Password** | radioless (or your custom password) |

## Verification

Test your configuration:
```bash
# Check if port is listening
sudo netstat -tulpn | grep 5038

# Verify Asterisk manager
telnet localhost 5038

# Check firewall
sudo firewall-cmd --list-ports
```

## Troubleshooting

### Cannot Connect
```bash
# Check Asterisk is running
sudo systemctl status asterisk

# Verify firewall port is open
sudo firewall-cmd --list-ports | grep 5038

# Check your IP address
hostname -I
```

### ASTDB.TXT Not Found
```bash
# Trigger manual download
sudo systemctl start asl3-update-astdb.service

# Verify symlink exists
ls -la /var/www/html/allmon2/astdb.txt
```

Force close and reopen NodeRemote app after running these commands.

### Allmon3 Stopped Working

The script synchronizes credentials between NodeRemote and Allmon3. Use the same username/password in Allmon3 web interface.

## Remote Access (Internet)

To access from outside your home network:

1. **Port Forward** on your router:
   - External Port: 5038
   - Internal Port: 5038
   - Internal IP: Your Raspberry Pi IP
   - Protocol: TCP

2. **Use your public IP** in NodeRemote app

⚠️ **Security Warning:** Use a strong password when exposing to the internet, or use VPN (recommended).

## What Gets Modified

- `/etc/asterisk/manager.conf` - Asterisk manager configuration
- `/etc/allmon3/allmon3.ini` - Allmon3 credentials (if installed)
- Firewall rules (port 5038/tcp)
- astdb.txt service enabled

**All files are backed up before modification** with timestamps.

## Reverting Changes

Restore from backups:
```bash
# List backups
ls -la /etc/asterisk/manager.conf.backup-*

# Restore (replace timestamp with yours)
sudo cp /etc/asterisk/manager.conf.backup-20240207-160109 /etc/asterisk/manager.conf
sudo systemctl restart asterisk
```

## Documentation

- 📖 [Complete README](README.md) - Full documentation with detailed troubleshooting
- ⚡ [Quick Start Guide](QUICKSTART.md) - One-page reference

## Support

- **AllStarLink Community:** https://community.allstarlink.org/
- **NodeRemote Documentation:** https://dstarcomms.com/node-remote/
- **Issues:** https://github.com/G1LRO/node-remote-setup/issues

## Compatibility

- ✅ AllStarLink 3 (ASL3)
- ✅ Raspberry Pi (all models)
- ✅ x86/x64 Linux systems running ASL3
- ✅ Compatible with Allmon3

## License

- **MIT License**
- **CC-BY-NC-4.0** (Creative Commons Attribution-NonCommercial 4.0)

Free to use and modify for non-commercial purposes. Original copyright notices must be retained.

## Credits

**Author:** GU1LRO  
**NodeRemote App:** [dstarcomms.com](https://dstarcomms.com/node-remote/)  
**AllStarLink:** [allstarlink.org](https://allstarlink.org/)

---

Made with ❤️ for the amateur radio community
