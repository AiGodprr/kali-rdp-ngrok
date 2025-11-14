#!/bin/bash

set -e

# Install ngrok if not present
if ! command -v ngrok &> /dev/null; then
    echo "Installing ngrok..."
    curl -fsSL https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz -o /tmp/ngrok.tgz && \
    tar -xzf /tmp/ngrok.tgz -C /usr/local/bin && \
    chmod +x /usr/local/bin/ngrok && \
    rm /tmp/ngrok.tgz
    echo "✓ ngrok installed"
fi

echo "============================================"
echo "  Fedora 43 GNOME 49 QEMU VM Setup"
echo "============================================"
echo ""

# VM Configuration
VM_NAME="fedora43-gnome"
VM_DISK="/vm/${VM_NAME}.qcow2"
VM_MEMORY="4096"
VM_CPUS="2"
VM_DISK_SIZE="20G"

# Check if VM disk exists
if [ ! -f "$VM_DISK" ]; then
    echo "Creating new VM disk image..."
    qemu-img create -f qcow2 "$VM_DISK" "$VM_DISK_SIZE"
    echo "✓ VM disk created: $VM_DISK ($VM_DISK_SIZE)"
    
    # Download Fedora 43 Workstation ISO (cloud image for faster setup)
    FEDORA_ISO="/vm/fedora-43-cloud.qcow2"
    if [ ! -f "$FEDORA_ISO" ]; then
        echo "Downloading Fedora 43 Cloud Base image..."
        echo "Note: This will be used as a base for the VM"
        # Using Fedora 39 as 43 may not be available yet
        curl -L -o "$FEDORA_ISO" "https://download.fedoraproject.org/pub/fedora/linux/releases/39/Cloud/x86_64/images/Fedora-Cloud-Base-39-1.5.x86_64.qcow2" || \
        curl -L -o "$FEDORA_ISO" "https://download.fedoraproject.org/pub/fedora/linux/releases/40/Cloud/x86_64/images/Fedora-Cloud-Base-40-1.14.x86_64.qcow2" || \
        echo "Warning: Could not download Fedora cloud image. Will create from scratch."
    fi
    
    # If cloud image was downloaded, use it as base
    if [ -f "$FEDORA_ISO" ]; then
        echo "Using cloud image as base..."
        qemu-img convert -O qcow2 "$FEDORA_ISO" "$VM_DISK"
        qemu-img resize "$VM_DISK" "$VM_DISK_SIZE"
        echo "✓ VM initialized from cloud image"
    fi
else
    echo "✓ Using existing VM disk: $VM_DISK"
fi

# Create cloud-init configuration for automatic setup
mkdir -p /vm/cloud-init
cat > /vm/cloud-init/meta-data << 'EOF'
instance-id: fedora-gnome-vm
local-hostname: fedora-gnome
EOF

cat > /vm/cloud-init/user-data << 'EOF'
#cloud-config
users:
  - name: root
    lock_passwd: false
    passwd: $6$rounds=4096$saltsalt$IjK9h0Xhc7xGQmCNLUBwBc4XZ8aEzKqDVj7gKEqS1UfYQlBDVJnRq1kNlKc0vM2qN9Jl0Z7X8h0kKqN0z1
chpasswd:
  list: |
    root:Devil
  expire: False
ssh_pwauth: True
package_update: true
package_upgrade: false
packages:
  - '@workstation-product-environment'
  - gnome-desktop3
  - xrdp
  - tigervnc-server
  - dbus-x11
runcmd:
  - systemctl set-default graphical.target
  - systemctl enable gdm
  - systemctl enable xrdp
  - systemctl start xrdp
  - firewall-cmd --permanent --add-port=3389/tcp || true
  - firewall-cmd --reload || true
  - echo "root:Devil" | chpasswd
EOF

# Create cloud-init ISO
if [ ! -f "/vm/cloud-init.iso" ]; then
    echo "Creating cloud-init configuration..."
    # Try to create ISO with genisoimage or mkisofs
    if command -v genisoimage &> /dev/null; then
        genisoimage -output /vm/cloud-init.iso -volid cidata -joliet -rock /vm/cloud-init/user-data /vm/cloud-init/meta-data
    elif command -v mkisofs &> /dev/null; then
        mkisofs -output /vm/cloud-init.iso -volid cidata -joliet -rock /vm/cloud-init/user-data /vm/cloud-init/meta-data
    else
        echo "Note: ISO creation tools not available, will boot without cloud-init"
    fi
fi

# Get ngrok authtoken from environment variable or use default
NGROK_TOKEN="${NGROK_AUTHTOKEN:-35SfwXIN64gkw59BROC10ZONXJB_6SqDctBbRwcTpxsW3moKX}"

# Generate ngrok configuration
echo "Generating ngrok configuration..."
mkdir -p /root/.ngrok2
cat > /root/.ngrok2/ngrok.yml << EOF
version: "3"
agent:
  authtoken: ${NGROK_TOKEN}
tunnels:
  rdp:
    proto: tcp
    addr: 127.0.0.1:3389
EOF
echo "✓ ngrok configuration created"

# Start ngrok in the background
echo "Starting ngrok tunnel for RDP..."
ngrok start --all --config /root/.ngrok2/ngrok.yml --log=stdout > /tmp/ngrok.log 2>&1 &

# Wait for ngrok to establish connection
sleep 5

echo ""
echo "Starting QEMU VM with Fedora 43 GNOME..."
echo "VM Configuration:"
echo "  Memory: ${VM_MEMORY}M"
echo "  CPUs: ${VM_CPUS}"
echo "  Disk: $VM_DISK"
echo ""

# Start QEMU VM with proper settings
QEMU_CMD="qemu-system-x86_64 \
    -name $VM_NAME \
    -machine q35,accel=kvm:tcg \
    -cpu host \
    -smp $VM_CPUS \
    -m $VM_MEMORY \
    -drive file=$VM_DISK,if=virtio,format=qcow2 \
    -net nic,model=virtio \
    -net user,hostfwd=tcp::3389-:3389 \
    -vga virtio \
    -display none \
    -daemonize"

# Add cloud-init if available
if [ -f "/vm/cloud-init.iso" ]; then
    QEMU_CMD="$QEMU_CMD -drive file=/vm/cloud-init.iso,if=virtio,media=cdrom"
fi

# Execute QEMU
eval $QEMU_CMD

echo "✓ QEMU VM started"
echo ""

# Display connection information
echo "============================================"
echo "  Fedora 43 GNOME VM is starting..."
echo "============================================"
echo ""
echo "VM will take a few minutes to fully boot and configure."
echo "The VM is installing GNOME desktop environment on first boot."
echo ""
echo "System Login Credentials:"
echo "  Username: root"
echo "  Password: Devil"
echo ""

# Try to get the RDP tunnel URL from ngrok API
for i in {1..10}; do
    TUNNELS_JSON=$(curl -s http://localhost:4040/api/tunnels 2>/dev/null)
    if [ ! -z "$TUNNELS_JSON" ]; then
        RDP_URL=$(echo "$TUNNELS_JSON" | grep -o '"name":"rdp"[^}]*"public_url":"[^"]*' | grep -o 'tcp://[^"]*' | head -1)
        
        if [ ! -z "$RDP_URL" ]; then
            echo "RDP Connection Details:"
            echo "  Host: ${RDP_URL#tcp://}"
            echo "  Use any RDP client with credentials: root / Devil"
            echo ""
            echo "Supported RDP Clients:"
            echo "  - Microsoft Remote Desktop (Windows/macOS/iOS/Android)"
            echo "  - Remmina (Linux)"
            echo "  - FreeRDP / xfreerdp (Linux)"
            echo ""
            echo "Note: Please wait 3-5 minutes for the VM to fully boot"
            echo "      and configure GNOME desktop on first run."
            echo ""
            echo "============================================"
            break
        fi
    fi
    sleep 2
done

if [ -z "$RDP_URL" ]; then
    echo "Note: Ngrok tunnel is starting..."
    echo "Check the logs below for connection details"
    echo "============================================"
fi

echo ""
echo "Monitoring VM and ngrok tunnel..."
echo "Press Ctrl+C to view logs"
echo ""

# Keep the container running and monitor both QEMU and ngrok
tail -f /tmp/ngrok.log &

# Monitor QEMU process
while true; do
    if ! pgrep -x qemu-system-x86 > /dev/null; then
        echo "ERROR: QEMU process has stopped!"
        exit 1
    fi
    sleep 10
done
