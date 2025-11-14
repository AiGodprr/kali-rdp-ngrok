# Fedora 43 GNOME 49 QEMU VM with RDP via Ngrok

This Docker container runs a QEMU virtual machine with Fedora 43 and full GNOME 49 desktop environment, accessible via RDP through ngrok.

## Features

- **QEMU Virtual Machine** running Fedora 43
- **Full GNOME 49 desktop environment** with complete Fedora Workstation experience
- xrdp server for RDP remote desktop access
- ngrok TCP tunnel for secure external access
- Complete Fedora desktop suite with all standard applications
- Hardware virtualization support (KVM when available)

## Credentials

- **System Login** (RDP):
  - Username: `root`
  - Password: `Devil`

## Usage

### Deploy on Render.com (Recommended)

1. Fork this repository to your GitHub account
2. Go to [Render.com](https://render.com) and sign in
3. Click "New +" and select "Blueprint"
4. Connect your GitHub repository
5. Render will automatically detect the `render.yaml` file
6. (Optional) Add environment variable `NGROK_AUTHTOKEN` with your ngrok authtoken if you want to use a custom token
7. Click "Apply" to deploy
8. Check the logs to see the ngrok RDP connection URL printed after deployment

The service will run as a background worker, start the QEMU VM, and automatically print RDP connection details in the logs.

**Note**: The VM will take 3-5 minutes to fully boot and configure GNOME desktop on first run.

### Run Locally with Docker

1. Build the Docker image:
```bash
docker build -t fedora-gnome-qemu-rdp-ngrok .
```

2. Run the container with privileged mode (required for QEMU/KVM):
```bash
docker run -d --privileged -p 3389:3389 fedora-gnome-qemu-rdp-ngrok
```

Or with custom ngrok authtoken:
```bash
docker run -d --privileged -p 3389:3389 -e NGROK_AUTHTOKEN=your_token_here fedora-gnome-qemu-rdp-ngrok
```

3. Check the logs to get the ngrok URL:
```bash
docker logs -f <container_id>
```

The startup script will automatically display RDP connection details including the ngrok tunnel URL.

4. Connect via RDP using the displayed host and port with the credentials above.

**Important**: The `--privileged` flag is required to enable KVM acceleration for better VM performance.

## Connection Configuration

This container runs a QEMU virtual machine with Fedora 43 GNOME desktop:

### RDP Access
- **xrdp** server running inside the QEMU VM on port 3389
- Full GNOME 49 desktop environment
- System credentials authentication (root / Devil)
- Full Fedora Workstation desktop experience
- Ngrok TCP tunnel for secure external access

The QEMU VM provides a complete Fedora 43 installation with GNOME 49, offering the most authentic Fedora desktop experience.

### Connection Details

After deployment:
1. Check the container logs for the ngrok RDP tunnel URL
2. Wait 3-5 minutes for the QEMU VM to fully boot (first boot takes longer)
3. **RDP Connection:**
   - Use any RDP client:
     - **Windows**: Microsoft Remote Desktop (built-in)
     - **macOS**: Microsoft Remote Desktop (from App Store)
     - **Linux**: Remmina, FreeRDP, xfreerdp
     - **Android**: Microsoft Remote Desktop
     - **iOS**: Microsoft Remote Desktop
   - Connect to the RDP ngrok host:port from the logs
   - Enter credentials:
     - **Username**: `root`
     - **Password**: `Devil`
   - The Fedora 43 GNOME 49 desktop environment will be displayed

## Notes

- The ngrok authtoken can be customized via the `NGROK_AUTHTOKEN` environment variable
- If `NGROK_AUTHTOKEN` is not set, a default token is used (pre-configured)
- Port 3389 (RDP) is exposed from the QEMU VM
- The container runs as a background worker with QEMU VM
- After deployment, the ngrok tunnel URL will be printed in the logs
- The startup script (`start.sh`) automatically displays RDP connection information
- RDP uses system credentials: root / Devil
- The VM runs Fedora 43 with full GNOME 49 Workstation environment
- First boot takes 3-5 minutes as the VM installs and configures GNOME desktop
- KVM acceleration is used when available for better performance

## Render.com Configuration

The `render.yaml` file is pre-configured for easy deployment:
- Deploys as a web service (runs as background worker)
- Uses the free plan
- Auto-deploys on code changes
- Exposes port 3389 (RDP)
- Supports custom ngrok authtoken via environment variable
- Runs in privileged mode for QEMU/KVM support

## Testing the Configuration

To verify the setup is working correctly:

1. **Check QEMU VM**: After container starts, verify QEMU is running:
   ```bash
   docker exec <container_id> ps aux | grep qemu
   docker logs <container_id>
   ```

2. **Test RDP Connection**:
   - Wait 3-5 minutes for the VM to fully boot
   - Use the RDP ngrok URL from logs (format: `hostname:port`)
   - Connect with any RDP client
   - Enter credentials: root / Devil
   - Expected behavior: Fedora 43 GNOME 49 desktop should load

3. **Verify QEMU VM**: After connecting via RDP, open a terminal in the VM:
   ```bash
   cat /etc/fedora-release  # Should show Fedora version
   echo $XDG_CURRENT_DESKTOP  # Should output: GNOME
   gnome-shell --version  # Should show GNOME version
   ```

## QEMU VM Configuration

This setup uses **QEMU virtualization** to run a complete Fedora 43 installation with GNOME 49 desktop:

- **True Virtual Machine**: Complete Fedora 43 OS running in QEMU
- **Full GNOME 49 Desktop**: Authentic Fedora Workstation experience with GNOME 49.1
- **Hardware Virtualization**: Uses KVM acceleration when available for optimal performance
- **Cloud-Init Setup**: Automatic configuration on first boot
- **RDP Access**: xrdp server configured inside the VM for remote access

**VM Specifications**:
- Memory: 4GB RAM (configurable)
- CPUs: 2 cores (configurable)
- Disk: 20GB virtual disk
- Display: VirtIO GPU with software rendering

**Why QEMU VM**:
- Provides the most authentic Fedora 43 experience
- Complete OS isolation and full system access
- Proper hardware emulation
- Supports all Fedora features and applications
- Can be customized and configured like a real Fedora installation

**Performance Notes**:
- First boot takes 3-5 minutes for initial setup and GNOME installation
- Subsequent boots are faster (typically 1-2 minutes)
- KVM acceleration significantly improves performance when available
- Runs efficiently on cloud platforms like Render.com

## Troubleshooting

If you don't see the ngrok URL in the logs immediately:
1. Wait 30-60 seconds for ngrok to establish the tunnel
2. Check the full logs with `docker logs -f <container_id>` or in Render dashboard
3. The URL will appear in format: `Host: X.tcp.ngrok.io:XXXXX`

If the VM takes too long to boot:
1. First boot takes 3-5 minutes for initial setup
2. Check QEMU is running:
   ```bash
   docker exec <container_id> ps aux | grep qemu
   ```
3. Monitor the container logs for progress updates
4. Subsequent boots will be faster (1-2 minutes)

If you experience RDP connection issues:
1. Verify the QEMU VM is running:
   ```bash
   docker exec <container_id> ps aux | grep qemu-system
   ```
2. Check if the VM has fully booted (wait at least 5 minutes on first boot)
3. Try connecting again after a few minutes
4. If running locally, test connection to localhost:3389

If QEMU fails to start:
1. Ensure the container is running with `--privileged` flag
2. Check available disk space in the container
3. Review container logs for QEMU error messages
4. Verify the cloud image downloaded successfully

### Common RDP Client Configuration Tips

**RDP Clients:**
- **Microsoft Remote Desktop (Windows)**: Enter `hostname:port` directly in Computer field
- **Microsoft Remote Desktop (macOS/iOS)**: Add PC, enter `hostname:port`
- **Remmina (Linux)**: Select RDP protocol, enter `hostname:port`
- **FreeRDP/xfreerdp**: Use command like `xfreerdp /v:hostname:port /u:root /p:Devil`

### Performance Tips

- Ensure KVM is available for hardware acceleration
- Increase VM memory if experiencing slowness (edit `VM_MEMORY` in start.sh)
- Allow adequate time for first boot GNOME installation
- Render.com free tier provides sufficient resources for smooth operation
