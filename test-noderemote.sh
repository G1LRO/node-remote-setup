#!/bin/bash
# NodeRemote Configuration Test Script
# Verifies that NodeRemote is properly configured

echo "================================================"
echo "NodeRemote Configuration Verification"
echo "================================================"
echo ""

PASS=0
FAIL=0

# Test 1: Manager.conf exists and configured
echo -n "1. Checking manager.conf configuration... "
if [ -f "/etc/asterisk/manager.conf" ]; then
    if grep -q "enabled = yes" /etc/asterisk/manager.conf && \
       grep -q "bindaddr = 0.0.0.0" /etc/asterisk/manager.conf && \
       grep -E "^\[.*\]$" /etc/asterisk/manager.conf | grep -v "^\[general\]$" > /dev/null; then
        echo "PASS"
        ((PASS++))
    else
        echo "FAIL - File exists but not properly configured"
        ((FAIL++))
    fi
else
    echo "FAIL - File not found"
    ((FAIL++))
fi

# Test 2: Port 5038 listening
echo -n "2. Checking if port 5038 is listening... "
if netstat -tulpn 2>/dev/null | grep -q ":5038" || ss -tulpn 2>/dev/null | grep -q ":5038"; then
    echo "PASS"
    ((PASS++))
else
    echo "FAIL - Port not listening"
    ((FAIL++))
fi

# Test 3: Firewall configured
echo -n "3. Checking firewall configuration... "
if command -v firewall-cmd >/dev/null 2>&1; then
    if firewall-cmd --list-ports 2>/dev/null | grep -q "5038/tcp"; then
        echo "PASS"
        ((PASS++))
    else
        echo "FAIL - Port not open in firewall"
        ((FAIL++))
    fi
else
    echo "SKIP - firewall-cmd not available"
fi

# Test 4: astdb.txt symlink exists
echo -n "4. Checking astdb.txt symlink... "
if [ -L "/var/www/html/allmon2/astdb.txt" ]; then
    echo "PASS"
    ((PASS++))
else
    echo "FAIL - Symlink not found"
    ((FAIL++))
fi

# Test 5: astdb.txt source file exists
echo -n "5. Checking astdb.txt source file... "
if [ -f "/var/lib/asterisk/astdb.txt" ]; then
    echo "PASS"
    ((PASS++))
else
    echo "FAIL - Source file not found"
    ((FAIL++))
fi

# Test 6: astdb service enabled
echo -n "6. Checking astdb update service... "
if systemctl is-enabled asl3-update-astdb.timer >/dev/null 2>&1; then
    echo "PASS"
    ((PASS++))
else
    echo "FAIL - Service not enabled"
    ((FAIL++))
fi

# Test 7: Asterisk running
echo -n "7. Checking Asterisk service... "
if systemctl is-active --quiet asterisk; then
    echo "PASS"
    ((PASS++))
else
    echo "FAIL - Asterisk not running"
    ((FAIL++))
fi

# Test 8: Manager interface accessible
echo -n "8. Testing manager interface connection... "
if timeout 3 bash -c "echo 'quit' | nc localhost 5038" 2>/dev/null | grep -q "Asterisk Call Manager"; then
    echo "PASS"
    ((PASS++))
else
    echo "FAIL - Cannot connect to manager interface"
    ((FAIL++))
fi

# Test 9: Allmon3.ini configured (if exists)
echo -n "9. Checking allmon3.ini configuration... "
if [ -f "/etc/allmon3/allmon3.ini" ]; then
    if grep -q "^user=" /etc/allmon3/allmon3.ini && grep -q "^pass=" /etc/allmon3/allmon3.ini; then
        echo "PASS"
        ((PASS++))
    else
        echo "FAIL - Missing user/pass configuration"
        ((FAIL++))
    fi
else
    echo "SKIP - allmon3.ini not found"
fi

echo ""
echo "================================================"
echo "Test Results: $PASS passed, $FAIL failed"
echo "================================================"
echo ""

if [ $FAIL -eq 0 ]; then
    echo "All tests passed! NodeRemote is properly configured."
    echo ""
    echo "Your NodeRemote app settings should be:"
    echo "  IP Address: $(hostname -I | cut -d' ' -f1)"
    echo "  Port: 5038"
    echo "  Username: [check /etc/asterisk/manager.conf for configured username]"
    echo "  Password: [check /etc/asterisk/manager.conf]"
    echo ""
    exit 0
else
    echo "Some tests failed. Review the errors above."
    echo ""
    echo "Common fixes:"
    echo "  - Run: sudo bash enable-noderemote.sh"
    echo "  - Check: systemctl status asterisk"
    echo "  - Verify: sudo cat /etc/asterisk/manager.conf"
    echo ""
    exit 1
fi
