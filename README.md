# Kali Linux RDP with Ngrok

This Docker container provides a Kali Linux environment with RDP access via ngrok.

## Features

- Kali Linux Rolling base
- XFCE4 desktop environment
- XRDP server with Xvnc (TigerVNC) backend for reliable containerized RDP access
- Ngrok tunnel for external access
- Robust configuration to prevent blue screen and connection issues

## Credentials

- Username: `root`
- Password: `Devil`

## Usage

### Deploy on Render.com (Recommended)

1. Fork this repository to your GitHub account
2. Go to [Render.com](https://render.com) and sign in
3. Click "New +" and select "Blueprint"
4. Connect your GitHub repository
5. Render will automatically detect the `render.yaml` file
6. Click "Apply" to deploy
7. Check the logs to see the ngrok connection URL printed after deployment

The service will run as a background worker and automatically print the RDP connection details in the logs.

### Run Locally with Docker

1. Build the Docker image:
```bash
docker build -t kali-rdp-ngrok .
```

2. Run the container:
```bash
docker run -d -p 3389:3389 kali-rdp-ngrok
```

3. Check the logs to get the ngrok URL:
```bash
docker logs -f <container_id>
```

The startup script will automatically display the RDP connection details including the ngrok tunnel URL.

4. Connect via RDP using the displayed host and port with the credentials above.

## XRDP Backend Configuration

This container now uses **Xvnc (TigerVNC)** as the XRDP backend instead of Xorg, which provides:
- Better stability in containerized/headless environments
- More reliable session handling without systemd
- Reduced "blue screen" and blank desktop issues

The configuration includes:
- **sesman-Xvnc** session type as default in `/etc/xrdp/xrdp.ini`
- Proper Xvnc parameters in `/etc/xrdp/sesman.ini` (localhost-only, no TCP listening)
- Robust `/etc/xrdp/startwm.sh` with correct XDG environment variables
- User `.xsession` configuration for XFCE4 desktop environment
- All services start via `/etc/init.d/xrdp` (no systemd required)

### Connection Details

After deployment:
1. Check the container logs for the ngrok tunnel URL
2. Use any RDP client to connect (example: Microsoft Remote Desktop, Remmina)
3. Connect to the provided host:port from the logs
4. Login with:
   - **Username**: `root`
   - **Password**: `Devil`
5. The XFCE desktop environment will start automatically

## Notes

- The ngrok authtoken is already configured in `ngrok.yml`
- Port 3389 is exposed for RDP connections
- The container runs as a background worker with all services
- After deployment, the ngrok tunnel URL will be printed in the logs
- The startup script (`start.sh`) automatically displays connection information

## Render.com Configuration

The `render.yaml` file is pre-configured for easy deployment:
- Deploys as a web service (runs as background worker)
- Uses the free plan
- Auto-deploys on code changes
- Exposes port 3389 for RDP

## Testing the Configuration

To verify the XRDP setup is working correctly:

1. **Check Services**: After container starts, verify services are running:
   ```bash
   docker exec <container_id> service xrdp status
   docker exec <container_id> ps aux | grep -E "xrdp|Xvnc"
   ```

2. **Test RDP Connection**: 
   - Use the ngrok URL from logs (format: `hostname:port`)
   - Connect with RDP client using credentials: `root` / `Devil`
   - Expected behavior: XFCE desktop should load without blue screen

3. **Verify Session Type**: After connecting, check the session is using Xvnc:
   ```bash
   # Inside the RDP session, open terminal
   echo $XDG_SESSION_TYPE  # Should output: x11
   echo $XDG_CURRENT_DESKTOP  # Should output: XFCE
   ps aux | grep Xvnc  # Should show Xvnc process for your session
   ```

## Troubleshooting

If you don't see the ngrok URL in the logs immediately:
1. Wait 30-60 seconds for ngrok to establish the tunnel
2. Check the full logs with `docker logs -f <container_id>` or in Render dashboard
3. The URL will appear in format: `Host: X.tcp.ngrok.io:XXXXX`

If you experience connection issues:
1. Verify XRDP is running: `docker exec <container_id> service xrdp status`
2. Check XRDP logs: `docker exec <container_id> cat /var/log/xrdp.log`
3. Check sesman logs: `docker exec <container_id> cat /var/log/xrdp-sesman.log`
4. Ensure the Xvnc backend is properly configured in `/etc/xrdp/sesman.ini`
