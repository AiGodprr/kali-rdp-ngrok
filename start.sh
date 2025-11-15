#!/bin/bash

set -e

echo "============================================"
echo "  Ubuntu Code-Server Setup"
echo "============================================"
echo ""

# Get code-server password from environment variable or use default
CODE_SERVER_PASSWORD="${CODE_SERVER_PASSWORD:-Devil}"

# Create config directory
mkdir -p /root/.config/code-server

# Generate code-server configuration with custom password
cat > /root/.config/code-server/config.yaml << EOF
bind-addr: 0.0.0.0:8080
auth: password
password: ${CODE_SERVER_PASSWORD}
cert: false
EOF

# Display connection information
echo "Starting code-server..."
echo "Configuration:"
echo "  Port: 8080"
echo "  Password: ${CODE_SERVER_PASSWORD}"
echo ""

echo "✓ code-server starting..."
echo ""

# Display connection information
echo "============================================"
echo "  Ubuntu Code-Server is ready!"
echo "============================================"
echo ""
echo "Access Credentials:"
echo "  Port: 8080"
echo "  Password: ${CODE_SERVER_PASSWORD}"
echo ""
echo "You can access code-server at http://localhost:8080"
echo "or via the exposed port on your deployment platform."
echo ""
echo "============================================"
echo ""

# Start code-server (foreground - this keeps the container running)
exec code-server --disable-telemetry
