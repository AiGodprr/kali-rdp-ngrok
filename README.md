# Ubuntu 24.04 GNOME VNC + RDP with Ngrok

This Docker container provides an Ubuntu 24.04 environment with full GNOME desktop and both VNC and RDP access via ngrok.

## Features

- Ubuntu 24.04 LTS base
- **Full GNOME desktop environment** with complete Ubuntu desktop experience
- TigerVNC server for VNC remote desktop access
- xrdp server for RDP remote desktop access
- Dual ngrok TCP tunnels for external access (both VNC and RDP)
- Single shared GNOME desktop session accessible via both protocols
- Complete Ubuntu desktop suite with all standard applications

## Credentials

- **System Login**:
  - Username: `root`
  - Password: `Devil`
- **VNC Password**: `DevilVNC`

## Usage

### Deploy on Render.com (Recommended)

1. Fork this repository to your GitHub account
2. Go to [Render.com](https://render.com) and sign in
3. Click "New +" and select "Blueprint"
4. Connect your GitHub repository
5. Render will automatically detect the `render.yaml` file
6. (Optional) Add environment variable `NGROK_AUTHTOKEN` with your ngrok authtoken if you want to use a custom token
7. Click "Apply" to deploy
8. Check the logs to see both ngrok connection URLs (VNC and RDP) printed after deployment

The service will run as a background worker and automatically print both VNC and RDP connection details in the logs.

### Run Locally with Docker

1. Build the Docker image:
```bash
docker build -t ubuntu-gnome-vnc-rdp-ngrok .
```

2. Run the container:
```bash
docker run -d -p 5901:5901 -p 3389:3389 ubuntu-gnome-vnc-rdp-ngrok
```

Or with custom ngrok authtoken:
```bash
docker run -d -p 5901:5901 -p 3389:3389 -e NGROK_AUTHTOKEN=your_token_here ubuntu-gnome-vnc-rdp-ngrok
```

3. Check the logs to get the ngrok URLs:
```bash
docker logs -f <container_id>
```

The startup script will automatically display both VNC and RDP connection details including the ngrok tunnel URLs.

4. Connect via VNC or RDP using the displayed host and port with the credentials above.

## Connection Configuration

This container provides two ways to access the same Ubuntu GNOME desktop:

### VNC Access
- **TigerVNC** server running on display `:1` (port 5901)
- Full GNOME desktop environment via `~/.vnc/xstartup`
- VNC password authentication (`DevilVNC`)
- 1920x1080 resolution with 24-bit color depth
- Ngrok TCP tunnel for secure external access

### RDP Access
- **xrdp** server running on port 3389
- Same GNOME desktop environment via `~/.xsession`
- System credentials authentication (root / Devil)
- Full desktop experience with protocol-native features
- Separate ngrok TCP tunnel for secure external access

Both protocols connect to the same container and share the same environment, providing flexibility in how you connect.

### Connection Details

After deployment:
1. Check the container logs for both ngrok tunnel URLs (VNC and RDP)
2. **For VNC connection:**
   - Use any VNC client:
     - **Windows**: TigerVNC Viewer, RealVNC, TightVNC
     - **macOS**: TigerVNC Viewer, RealVNC, or built-in Screen Sharing app
     - **Linux**: Remmina, TigerVNC Viewer, Vinagre, or Krdc
     - **Android**: VNC Viewer (RealVNC)
     - **iOS**: VNC Viewer (RealVNC)
   - Connect to the VNC ngrok host:port from the logs
   - Enter VNC password: `DevilVNC`
   - The GNOME desktop environment will be displayed

3. **For RDP connection:**
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
   - The GNOME desktop environment will be displayed

## Notes

- The ngrok authtoken can be customized via the `NGROK_AUTHTOKEN` environment variable
- If `NGROK_AUTHTOKEN` is not set, a default token is used (pre-configured)
- Ports 5901 (VNC) and 3389 (RDP) are exposed
- The container runs as a background worker with all services
- After deployment, both ngrok tunnel URLs will be printed in the logs
- The startup script (`start.sh`) automatically displays connection information for both protocols
- VNC password is set to `DevilVNC` by default
- RDP uses system credentials: root / Devil
- Both VNC and RDP connect to the same GNOME desktop session in the container

## Render.com Configuration

The `render.yaml` file is pre-configured for easy deployment:
- Deploys as a web service (runs as background worker)
- Uses the free plan
- Auto-deploys on code changes
- Exposes ports 5901 (VNC) and 3389 (RDP)
- Supports custom ngrok authtoken via environment variable

## Testing the Configuration

To verify the setup is working correctly:

1. **Check Services**: After container starts, verify services are running:
   ```bash
   docker exec <container_id> ps aux | grep -E "Xvnc|Xtigervnc|xrdp"
   docker exec <container_id> ls -la /tmp/.X11-unix/
   docker exec <container_id> service xrdp status
   ```

2. **Test VNC Connection**: 
   - Use the VNC ngrok URL from logs (format: `hostname:port`)
   - Connect with any VNC client
   - Enter VNC password: `DevilVNC`
   - Expected behavior: GNOME desktop should load immediately

3. **Test RDP Connection**:
   - Use the RDP ngrok URL from logs (format: `hostname:port`)
   - Connect with any RDP client
   - Enter credentials: root / Devil
   - Expected behavior: GNOME desktop should load immediately

4. **Verify Session Type**: After connecting (via VNC or RDP), open a terminal:
   ```bash
   echo $XDG_SESSION_TYPE  # Should output: x11
   echo $XDG_CURRENT_DESKTOP  # Should output: GNOME
   ps aux | grep Xvnc  # Should show Xvnc process for display :1
   ps aux | grep xrdp  # Should show xrdp processes
   ```

## Image Size & Variants

This image includes the **full Ubuntu GNOME desktop** (`ubuntu-desktop`) to provide a complete Ubuntu desktop experience. This means:

- **Complete Desktop Environment**: Full GNOME 46 desktop with Ubuntu theming, top bar, activities, and all graphical components
- **Standard Ubuntu Applications**: All default Ubuntu applications including Firefox, LibreOffice, and system utilities
- **Rich Application Grid**: Full application grid with categorized Ubuntu applications
- **Desktop Experience**: Same as running Ubuntu 24.04 LTS from the official ISO with GNOME

**Image Size Considerations**:
- The full desktop installation results in a larger Docker image (~3-4 GB) compared to minimal installations
- First-time build and pull will take longer due to the comprehensive package installation
- Startup time is slightly increased but still reasonable (typically under 30 seconds)
- Container runtime memory usage is higher due to the full desktop components

**Why Full GNOME Desktop**:
- Provides the authentic Ubuntu 24.04 GNOME experience
- No missing applications or features
- Proper Ubuntu theming and desktop appearance
- Ready-to-use environment without additional configuration

This setup provides the complete, pure GNOME experience on Ubuntu 24.04 LTS as requested - no XFCE, no minimal setups, just the full GNOME desktop environment.

## Troubleshooting

If you don't see the ngrok URLs in the logs immediately:
1. Wait 30-60 seconds for ngrok to establish both tunnels
2. Check the full logs with `docker logs -f <container_id>` or in Render dashboard
3. The URLs will appear in format: `Host: X.tcp.ngrok.io:XXXXX`

If you experience VNC connection issues:
1. Verify VNC server is running:
   ```bash
   docker exec <container_id> ps aux | grep Xvnc
   docker exec <container_id> ls -la /root/.vnc/
   ```
2. Check VNC logs:
   ```bash
   docker exec <container_id> cat /root/.vnc/*.log
   ```
3. Ensure the VNC password file exists:
   ```bash
   docker exec <container_id> ls -l /root/.vnc/passwd
   ```
4. Test local VNC connection (if running Docker locally):
   ```bash
   # From host machine
   vncviewer localhost:5901
   ```

If you experience RDP connection issues:
1. Verify xrdp service is running:
   ```bash
   docker exec <container_id> service xrdp status
   docker exec <container_id> ps aux | grep xrdp
   ```
2. Check xrdp logs:
   ```bash
   docker exec <container_id> cat /var/log/xrdp.log
   docker exec <container_id> cat /var/log/xrdp-sesman.log
   ```
3. Test local RDP connection (if running Docker locally):
   ```bash
   # From Windows/macOS/Linux with RDP client
   # Connect to localhost:3389
   ```

### Common Client Configuration Tips

**VNC Clients:**
- **TigerVNC Viewer**: Enter connection as `hostname:port` (e.g., `8.tcp.ngrok.io:12345`)
- **RealVNC**: Use full address `hostname::port` with double colon (e.g., `8.tcp.ngrok.io::12345`)
- **macOS Screen Sharing**: Use `vnc://hostname:port` format
- **Remmina (Linux)**: Select VNC protocol, enter `hostname:port`
- **Mobile VNC Viewer**: Enter hostname and port separately when prompted

**RDP Clients:**
- **Microsoft Remote Desktop (Windows)**: Enter `hostname:port` directly in Computer field
- **Microsoft Remote Desktop (macOS/iOS)**: Add PC, enter `hostname:port`
- **Remmina (Linux)**: Select RDP protocol, enter `hostname:port`
- **FreeRDP/xfreerdp**: Use command like `xfreerdp /v:hostname:port /u:root /p:Devil`
