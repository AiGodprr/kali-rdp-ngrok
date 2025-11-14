# Kali Linux RDP with Ngrok

This Docker container provides a Kali Linux environment with RDP access via ngrok.

## Features

- Kali Linux Rolling base
- XFCE4 desktop environment
- XRDP server for remote desktop access
- Ngrok tunnel for external access
- Pre-configured to prevent blue screen issues

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

## Blue Screen Fix

The blue screen issue in RDP has been resolved by:
- Configuring proper XRDP startwm.sh script
- Setting up .xsession for XFCE4
- Unsetting conflicting DBUS environment variables
- Properly starting the XFCE4 session manager

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

## Troubleshooting

If you don't see the ngrok URL in the logs immediately:
1. Wait 30-60 seconds for ngrok to establish the tunnel
2. Check the full logs with `docker logs -f <container_id>` or in Render dashboard
3. The URL will appear in format: `Host: X.tcp.ngrok.io:XXXXX`
