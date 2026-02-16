# NodeRemote Quick Install for ASL3

## One-Line Installation

Copy and paste this command into your ASL3 Raspberry Pi terminal:

```bash
wget https://raw.githubusercontent.com/G1LRO/node-remote-setup/refs/heads/main/enable-noderemote.sh && chmod +x enable-noderemote.sh && sudo bash enable-noderemote.sh
```

**Default credentials:** Username: `rln` | Password: `radioless`

---

## Configure NodeRemote App

After running the script, configure your NodeRemote app with:

| Setting | Value |
|---------|-------|
| **Host** | Your Raspberry Pi IP address (shown in script output) |
| **Port** | 5038 |
| **Username** | rln |
| **Password** | radioless |

---

## Custom Credentials

To use custom credentials instead of defaults:

```bash
# Custom password only (username stays 'rln'):
wget https://raw.githubusercontent.com/G1LRO/node-remote-setup/refs/heads/main/enable-noderemote.sh && chmod +x enable-noderemote.sh && sudo bash enable-noderemote.sh mypassword

# Custom password AND username:
wget https://raw.githubusercontent.com/G1LRO/node-remote-setup/refs/heads/main/enable-noderemote.sh && chmod +x enable-noderemote.sh && sudo bash enable-noderemote.sh mypassword myusername
```

---

## What It Does

✓ Configures Asterisk manager interface
✓ Updates Allmon3 credentials (if installed)
✓ Opens firewall port 5038
✓ Enables astdb.txt automatic updates
✓ Creates automatic backups
✓ Restarts services

---

**Full Documentation:** See [README.md](README.md) for complete guide with troubleshooting.

**Script Source:** https://github.com/G1LRO/node-remote-setup

**License:** MIT / CC-BY-NC-4.0 (Non-commercial use)
