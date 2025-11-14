# Kali Linux VNC with Ngrok

This Docker container provides a Kali Linux environment with VNC access via ngrok.

## Features

- Kali Linux Rolling base
- XFCE4 desktop environment
- TigerVNC server for reliable remote desktop access
- Ngrok tunnel for external access
- Pure VNC implementation without RDP overhead

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
6. Click "Apply" to deploy
7. Check the logs to see the ngrok connection URL printed after deployment

The service will run as a background worker and automatically print the VNC connection details in the logs.

### Run Locally with Docker

1. Build the Docker image:
```bash
docker build -t kali-vnc-ngrok .
```

2. Run the container:
```bash
docker run -d -p 5901:5901 kali-vnc-ngrok
```

3. Check the logs to get the ngrok URL:
```bash
docker logs -f <container_id>
```

The startup script will automatically display the VNC connection details including the ngrok tunnel URL.

4. Connect via VNC using the displayed host and port with the credentials above.

## VNC Configuration

This container uses **TigerVNC** server to provide direct VNC access, which offers:
- Better stability and performance compared to RDP over VNC
- Direct connection without protocol translation overhead
- Native VNC protocol support across all platforms
- Simpler configuration and more reliable connections

The configuration includes:
- TigerVNC server running on display `:1` (port 5901)
- XFCE4 desktop environment via `~/.vnc/xstartup`
- VNC password authentication (`DevilVNC`)
- 1920x1080 resolution with 24-bit color depth
- Ngrok TCP tunnel for secure external access

### Connection Details

After deployment:
1. Check the container logs for the ngrok tunnel URL (format: `hostname:port`)
2. Use any VNC client to connect:
   - **Windows**: TigerVNC Viewer, RealVNC, TightVNC
   - **macOS**: TigerVNC Viewer, RealVNC, or built-in Screen Sharing app
   - **Linux**: Remmina, TigerVNC Viewer, Vinagre, or Krdc
   - **Android**: VNC Viewer (RealVNC)
   - **iOS**: VNC Viewer (RealVNC)
3. Connect to the ngrok host:port from the logs
4. Enter VNC password: `DevilVNC`
5. The XFCE desktop environment will be displayed
6. If prompted for system login, use:
   - **Username**: `root`
   - **Password**: `Devil`

## Notes

- The ngrok authtoken is already configured in `ngrok.yml`
- Port 5901 is exposed for VNC connections
- The container runs as a background worker with all services
- After deployment, the ngrok tunnel URL will be printed in the logs
- The startup script (`start.sh`) automatically displays connection information
- VNC password is set to `DevilVNC` by default

## Render.com Configuration

The `render.yaml` file is pre-configured for easy deployment:
- Deploys as a web service (runs as background worker)
- Uses the free plan
- Auto-deploys on code changes
- Exposes port 5901 for VNC

## Testing the Configuration

To verify the VNC setup is working correctly:

1. **Check Services**: After container starts, verify services are running:
   ```bash
   docker exec <container_id> ps aux | grep -E "Xvnc|Xtigervnc"
   docker exec <container_id> ls -la /tmp/.X11-unix/
   ```

2. **Test VNC Connection**: 
   - Use the ngrok URL from logs (format: `hostname:port`)
   - Connect with any VNC client
   - Enter VNC password: `DevilVNC`
   - Expected behavior: XFCE desktop should load immediately

3. **Verify Session Type**: After connecting, open a terminal in the VNC session:
   ```bash
   echo $XDG_SESSION_TYPE  # Should output: x11
   echo $XDG_CURRENT_DESKTOP  # Should output: XFCE
   ps aux | grep Xvnc  # Should show Xvnc process for display :1
   ```

## Troubleshooting

If you don't see the ngrok URL in the logs immediately:
1. Wait 30-60 seconds for ngrok to establish the tunnel
2. Check the full logs with `docker logs -f <container_id>` or in Render dashboard
3. The URL will appear in format: `Host: X.tcp.ngrok.io:XXXXX`

If you experience connection issues:
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

### Common VNC Client Configuration Tips

- **TigerVNC Viewer**: Enter connection as `hostname:port` (e.g., `8.tcp.ngrok.io:12345`)
- **RealVNC**: Use full address `hostname::port` with double colon (e.g., `8.tcp.ngrok.io::12345`)
- **macOS Screen Sharing**: Use `vnc://hostname:port` format
- **Remmina (Linux)**: Select VNC protocol, enter `hostname:port`
- **Mobile VNC Viewer**: Enter hostname and port separately when prompted
