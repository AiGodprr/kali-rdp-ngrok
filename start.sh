#!/bin/bash

# Start dbus
service dbus start
echo "✓ D-Bus service started"

# Ensure TigerVNC config directory exists (fixes migration error)
echo "Setting up VNC directories..."
mkdir -p /root/.config/tigervnc
mkdir -p /root/.vnc
chown -R root:root /root/.config/tigervnc /root/.vnc
echo "✓ VNC directories prepared"

# Create/update VNC xstartup script for XFCE
cat > /root/.vnc/xstartup << 'EOF'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=XFCE
export XDG_SESSION_DESKTOP=XFCE
exec startxfce4
EOF
chmod 755 /root/.vnc/xstartup
echo "✓ VNC xstartup configured for XFCE"

# Create .xsession for RDP (xrdp) sessions
cat > /root/.xsession << 'EOF'
#!/bin/sh
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=XFCE
export XDG_SESSION_DESKTOP=XFCE
exec startxfce4
EOF
chmod 755 /root/.xsession
echo "✓ xsession configured for RDP"

# Kill any existing VNC server
vncserver -kill :1 2>/dev/null || true

# Start VNC server for root user on display :1
echo "Starting VNC server..."
vncserver :1 -geometry 1920x1080 -depth 24 -localhost no
echo "✓ VNC server started on display :1 (port 5901)"

# Start xrdp service for RDP access
echo "Starting xrdp service..."
service xrdp start
echo "✓ xrdp service started (port 3389)"

# Get ngrok authtoken from environment variable or use default
NGROK_TOKEN="${NGROK_AUTHTOKEN:-35SfwXIN64gkw59BROC10ZONXJB_6SqDctBbRwcTpxsW3moKX}"

# Generate ngrok configuration with v3 syntax
echo "Generating ngrok configuration..."
mkdir -p /root/.ngrok2
cat > /root/.ngrok2/ngrok.yml << EOF
version: "2"
agent:
  authtoken: ${NGROK_TOKEN}
tunnels:
  vnc:
    proto: tcp
    addr: 127.0.0.1:5901
  rdp:
    proto: tcp
    addr: 127.0.0.1:3389
EOF
echo "✓ ngrok configuration created"

# Start ngrok in the background
echo "Starting ngrok tunnels..."
ngrok start --all --config /root/.ngrok2/ngrok.yml --log=stdout > /tmp/ngrok.log 2>&1 &

# Wait for ngrok to establish connection
sleep 5

# Display connection information
echo ""
echo "============================================"
echo "  Kali Linux VNC + RDP is ready!"
echo "============================================"
echo ""
echo "System Login Credentials:"
echo "  Username: root"
echo "  Password: Devil"
echo ""
echo "VNC Password: DevilVNC"
echo ""

# Try to get the tunnel URLs from ngrok API
for i in {1..10}; do
    TUNNELS_JSON=$(curl -s http://localhost:4040/api/tunnels 2>/dev/null)
    if [ ! -z "$TUNNELS_JSON" ]; then
        VNC_URL=$(echo "$TUNNELS_JSON" | grep -o '"name":"vnc"[^}]*"public_url":"[^"]*' | grep -o 'tcp://[^"]*' | head -1)
        RDP_URL=$(echo "$TUNNELS_JSON" | grep -o '"name":"rdp"[^}]*"public_url":"[^"]*' | grep -o 'tcp://[^"]*' | head -1)
        
        if [ ! -z "$VNC_URL" ] && [ ! -z "$RDP_URL" ]; then
            echo "VNC Connection Details:"
            echo "  Host: ${VNC_URL#tcp://}"
            echo "  Use any VNC client with password: DevilVNC"
            echo ""
            echo "RDP Connection Details:"
            echo "  Host: ${RDP_URL#tcp://}"
            echo "  Use any RDP client with credentials: root / Devil"
            echo ""
            echo "Supported Clients:"
            echo "  VNC: TigerVNC, RealVNC, TightVNC, Remmina"
            echo "  RDP: Microsoft Remote Desktop, Remmina, FreeRDP"
            echo ""
            echo "============================================"
            break
        fi
    fi
    sleep 2
done

if [ -z "$VNC_URL" ] || [ -z "$RDP_URL" ]; then
    echo "Note: Ngrok tunnels are starting..."
    echo "Check the logs below for connection details"
    echo "============================================"
fi

# Keep the container running and show logs
tail -f /tmp/ngrok.log
