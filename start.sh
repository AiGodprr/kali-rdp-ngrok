#!/bin/bash

# Start dbus
service dbus start
echo "✓ D-Bus service started"

# Start VNC server for root user on display :1
echo "Starting VNC server..."
vncserver :1 -geometry 1920x1080 -depth 24 -localhost no
echo "✓ VNC server started on display :1 (port 5901)"

# Start ngrok in the background
echo "Starting ngrok tunnel..."
ngrok start --all --config /root/.ngrok2/ngrok.yml --log=stdout > /tmp/ngrok.log 2>&1 &

# Wait for ngrok to establish connection
sleep 5

# Get the ngrok tunnel URL
echo ""
echo "============================================"
echo "  Kali Linux VNC is ready!"
echo "============================================"
echo ""
echo "System Login Credentials:"
echo "  Username: root"
echo "  Password: Devil"
echo ""
echo "VNC Password: DevilVNC"
echo ""

# Try to get the tunnel URL from ngrok API
for i in {1..10}; do
    NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | grep -o '"public_url":"[^"]*' | grep -o 'tcp://[^"]*' | head -1)
    if [ ! -z "$NGROK_URL" ]; then
        echo "VNC Connection Details:"
        echo "  Host: ${NGROK_URL#tcp://}"
        echo ""
        echo "Use any VNC client to connect:"
        echo "  - Windows: TigerVNC, RealVNC, TightVNC"
        echo "  - macOS: TigerVNC, RealVNC, or built-in Screen Sharing"
        echo "  - Linux: Remmina, TigerVNC, Vinagre"
        echo "  - Android: VNC Viewer"
        echo "  - iOS: VNC Viewer"
        echo ""
        echo "============================================"
        break
    fi
    sleep 2
done

if [ -z "$NGROK_URL" ]; then
    echo "Note: Ngrok tunnel is starting..."
    echo "Check the logs for connection details"
    echo "============================================"
fi

# Keep the container running and show logs
tail -f /tmp/ngrok.log
