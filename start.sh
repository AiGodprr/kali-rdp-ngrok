#!/bin/bash

# Start dbus
service dbus start
echo "✓ D-Bus service started"

# Start xrdp
service xrdp start
echo "✓ XRDP service started"

# Start ngrok in the background
echo "Starting ngrok tunnel..."
ngrok start --all --config /root/.ngrok2/ngrok.yml --log=stdout > /tmp/ngrok.log 2>&1 &

# Wait for ngrok to establish connection
sleep 5

# Get the ngrok tunnel URL
echo ""
echo "============================================"
echo "  Kali Linux RDP is ready!"
echo "============================================"
echo ""
echo "Login Credentials:"
echo "  Username: root"
echo "  Password: Devil"
echo ""

# Try to get the tunnel URL from ngrok API
for i in {1..10}; do
    NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | grep -o '"public_url":"[^"]*' | grep -o 'tcp://[^"]*' | head -1)
    if [ ! -z "$NGROK_URL" ]; then
        echo "RDP Connection Details:"
        echo "  Host: ${NGROK_URL#tcp://}"
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
