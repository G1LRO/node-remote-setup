# Using the NodeRemote App with Your RLNZ2

## What is NodeRemote?

NodeRemote is a mobile app (iOS and Android) that allows you to control your AllStarLink node directly from your smartphone or tablet. With NodeRemote, you can:

- Connect and disconnect from other nodes
- Monitor active connections
- View node information
- Control node functions remotely
- Access your node from anywhere on the internet

## Prerequisites

- Your RLNZ2 must be connected to your WiFi network
- The NodeRemote app installed on your iOS or Android device
- Your RLNZ2's IP address (shown on the built-in display)

## Getting the NodeRemote App

### iOS (iPhone/iPad)
Search for "Node Remote" in the Apple App Store

### Android
Search for "Node Remote" in the Google Play Store

## Initial Configuration

Your RLNZ2 comes pre-configured for NodeRemote with the following default settings:

- **Port:** 5038
- **Username:** rln (configurable)
- **Password:** radioless

**IMPORTANT:** You can change both the username and password through the RLNZ2 web configuration interface for better security.

## Setting Up NodeRemote App

### Step 1: Find Your RLNZ2's IP Address

The IP address is displayed on the built-in screen:
```
IP: 192.168.1.xxx
```

Alternatively, you can find it through your router's connected devices list.

### Step 2: Add Your Node in NodeRemote

1. Open the NodeRemote app
2. Tap the **+** (Add Node) button
3. Enter the following information:

   - **Node Name:** Your choice (e.g., "My RLNZ2" or your callsign)
   - **Host/IP Address:** The IP address from your RLNZ2 display
   - **Port:** 5038
   - **Username:** rln
   - **Password:** radioless (or your custom password if changed)

4. Tap **Save** or **Connect**

### Step 3: Connect to Your Node

- The app should connect and show your node status
- You should see your node number and current connections
- The astdb.txt database should load (may take a few moments on first connection)

## Using NodeRemote

### Main Features

**Connect to Another Node:**
1. Tap the "Connect" button
2. Search for or enter a node number
3. Select connect type (permanent/temporary)
4. Tap to connect

**Disconnect:**
1. View your active connections
2. Tap on the connection you want to disconnect
3. Confirm disconnection

**Monitor Status:**
- Active connections shown in real-time
- Transmit/receive status indicators
- Node information display

## Troubleshooting

### "Cannot Connect to Node"

1. Verify your RLNZ2 IP address hasn't changed
2. Ensure your phone/tablet is on the same network as your RLNZ2
3. Check that port 5038 is the correct port
4. Verify username is "rln"
5. Confirm password is correct

### "ASTDB.TXT Not Found" Error

This usually resolves itself after a few minutes. If it persists:

1. Force close the NodeRemote app completely
2. Reopen the app
3. If still showing error after 5 minutes, contact support

### Connection Drops Frequently

- Ensure strong WiFi signal to your RLNZ2
- Check your router isn't blocking the connection
- Try rebooting your RLNZ2

## Security Recommendations

### For Home Use
The default password "radioless" is acceptable for home networks.

### For Public Networks or Internet Access
If you plan to access your RLNZ2 over the internet:

1. Change the default password via the web configuration interface
2. Use a strong password with mixed case, numbers, and symbols
3. Consider setting up a VPN for remote access
4. Check your router's firewall settings

## Remote Access (Over the Internet)

To access your node from outside your home network:

1. Configure port forwarding on your router:
   - External Port: 5038 (or choose another)
   - Internal Port: 5038
   - Internal IP: Your RLNZ2's IP address
   - Protocol: TCP

2. Find your public IP address (whatismyip.com)

3. In NodeRemote, use:
   - Host: Your public IP address
   - Port: 5038 (or your chosen external port)

**Security Note:** Port forwarding exposes your node to the internet. Use a strong password and understand the risks.

## Changing Your NodeRemote Password

### Via Web Interface (Recommended)

1. Connect to your RLNZ2's web configuration page
2. Navigate to the NodeRemote section
3. Enter a new password
4. Click "Save" and restart services
5. Update the password in your NodeRemote app

### Via SSH/Terminal

If you have SSH access to your RLNZ2:

```bash
# With default username (rln):
sudo bash /home/rln/rlnz2/enable-noderemote.sh your_new_password

# With custom username:
sudo bash /home/rln/rlnz2/enable-noderemote.sh your_new_password custom_username
```

## Advanced Configuration

For advanced users who want to customize NodeRemote settings:

The configuration file is located at:
```
/etc/asterisk/manager.conf
```

After making any changes to this file, restart Asterisk:
```bash
sudo systemctl restart asterisk
```

## Support

For issues specific to the NodeRemote app, visit:
https://dstarcomms.com/node-remote/

For RLNZ2-specific NodeRemote configuration questions:
Contact: www.g1lro.uk

## Additional Resources

- NodeRemote App Documentation: https://dstarcomms.com/node-remote/
- AllStarLink Community: https://allstarlink.org/
- RLNZ2 Support: www.g1lro.uk

---

**Tips for Best Experience:**

- Keep your RLNZ2 firmware up to date
- Use a WiFi connection with good signal strength
- Keep the NodeRemote app updated to the latest version
- Consider setting up a static IP address for your RLNZ2 to avoid connection issues
