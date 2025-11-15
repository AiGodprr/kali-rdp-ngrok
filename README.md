# Ubuntu Code-Server

This Docker container runs code-server (VS Code in the browser) on Ubuntu 24.04.

## Features

- **Code-Server** - VS Code running in your browser
- **Ubuntu 24.04** - Latest LTS Ubuntu base
- **Git and Node.js** - Pre-installed development tools
- **Lightweight** - No desktop environment, just the essentials
- **Simple setup** - Direct port exposure, no tunnels needed

## Credentials

- **Code-Server Access**:
  - Password: `Devil` (can be customized via `CODE_SERVER_PASSWORD` environment variable)

## Usage

### Deploy on Render.com (Recommended)

1. Fork this repository to your GitHub account
2. Go to [Render.com](https://render.com) and sign in
3. Click "New +" and select "Blueprint"
4. Connect your GitHub repository
5. Render will automatically detect the `render.yaml` file
6. (Optional) Add environment variable:
   - `CODE_SERVER_PASSWORD` - Custom password for code-server (optional, defaults to "Devil")
7. Click "Apply" to deploy
8. Access code-server via the URL provided by Render

The service will start code-server on port 8080.

### Run Locally with Docker

1. Build the Docker image:
```bash
docker build -t ubuntu-code-server .
```

2. Run the container:
```bash
docker run -d -p 8080:8080 ubuntu-code-server
```

Or with custom password:
```bash
docker run -d -p 8080:8080 \
  -e CODE_SERVER_PASSWORD=your_password_here \
  ubuntu-code-server
```

3. Access code-server:
   - Open http://localhost:8080 in your browser
   - Enter the password (default: `Devil`)

4. Check logs if needed:
```bash
docker logs -f <container_id>
```

## Connection Configuration

This container runs code-server on Ubuntu 24.04:

### Code-Server Access
- **code-server** - VS Code running in the browser on port 8080
- Password authentication (default: "Devil")
- Full VS Code experience with extensions support
- Git and Node.js pre-installed

### Connection Details

After deployment:
1. Access code-server via the exposed port 8080
2. **Code-Server Connection:**
   - Open the service URL in any web browser
   - Enter the password (default: `Devil`)
   - You'll have access to a full VS Code environment in your browser
   - Pre-installed tools: Git, Node.js, npm

## Notes

- The code-server password can be customized via the `CODE_SERVER_PASSWORD` environment variable
- Port 8080 is used for code-server
- The startup script (`start.sh`) automatically displays code-server access information
- Lightweight setup - no desktop environment, no VMs
- Fast startup - ready in seconds
- Direct port exposure - no tunnels or proxies needed

## Render.com Configuration

The `render.yaml` file is pre-configured for easy deployment:
- Deploys as a web service
- Uses the free plan
- Auto-deploys on code changes
- Exposes port 8080 (code-server)
- Supports custom password via environment variable

## Testing the Configuration

To verify the setup is working correctly:

1. **Check code-server**: After container starts, verify code-server is running:
   ```bash
   docker exec <container_id> ps aux | grep code-server
   docker logs <container_id>
   ```

2. **Test Code-Server Access**:
   - Open http://localhost:8080 in your browser
   - Enter password: Devil (or your custom password)
   - Expected behavior: VS Code interface should load in the browser

3. **Verify Ubuntu environment**: In the code-server terminal:
   ```bash
   cat /etc/os-release      # Should show Ubuntu version
   node --version           # Should show Node.js version
   git --version            # Should show Git version
   ```

## Code-Server Configuration

This setup runs **code-server** directly on Ubuntu 24.04:

- **VS Code in Browser**: Full Visual Studio Code experience accessible via web browser
- **Ubuntu 24.04 Base**: Clean, minimal Ubuntu LTS installation
- **Pre-installed Tools**: Git and Node.js ready to use
- **Extension Support**: Install VS Code extensions as needed
- **Direct Access**: Simple port exposure, no complex setup

**Features**:
- Lightweight - no desktop environment overhead
- Fast startup - ready in seconds
- Full VS Code functionality
- Terminal access to Ubuntu system
- File system access and editing

**Why Code-Server**:
- Provides a familiar VS Code interface
- No desktop environment needed
- Minimal resource usage
- Access from any device with a browser
- Perfect for development and coding tasks

## Troubleshooting

If you can't access code-server:
1. Check the container is running:
   ```bash
   docker ps
   ```
2. Check the logs for any errors:
   ```bash
   docker logs -f <container_id>
   ```
3. Verify code-server is running:
   ```bash
   docker exec <container_id> ps aux | grep code-server
   ```
4. Ensure port 8080 is properly mapped when running locally

If code-server fails to start:
1. Check available disk space in the container
2. Review container logs for error messages
3. Ensure the Dockerfile built successfully

### Browser Access Tips

- Use a modern web browser (Chrome, Firefox, Safari, Edge)
- Ensure JavaScript is enabled
- Clear browser cache if you experience issues
- Try accessing from incognito/private mode if you have login issues

### Performance Tips

- Code-server runs efficiently on minimal resources
- Works well on Render.com free tier
- Fast startup - typically ready in 5-10 seconds
- Lightweight compared to full desktop environments
