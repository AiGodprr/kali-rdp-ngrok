# VNC Implementation Verification Guide

This document describes how to verify that the Fedora 43 GNOME 49 desktop is running correctly via VNC.

## What's Implemented

### 1. Docker Image Configuration
- **Base Image**: `fedora:43` - Official Fedora 43 release
- **Desktop Environment**: `@workstation-product-environment` - Full Fedora GNOME desktop
- **VNC Server**: `tigervnc-server` - TigerVNC for remote access
- **RDP Server**: `xrdp` - RDP server for remote desktop protocol access
- **System Packages**: `dbus-x11`, `sudo`, `curl`, `unzip`, `gnupg2`

### 2. VNC Configuration
The Dockerfile creates:
- VNC password file at `/root/.vnc/passwd` with password: `DevilVNC`
- VNC xstartup script at `/root/.vnc/xstartup` that:
  - Unsets conflicting environment variables
  - Sets GNOME-specific environment variables
  - Launches `gnome-session` to start the full GNOME 49 desktop

### 3. Startup Process
The `start.sh` script:
1. Starts D-Bus service (required for XFCE)
2. Launches VNC server on display `:1` (port 5901)
   - Geometry: 1920x1080
   - Color depth: 24-bit
   - Accessible from network (not localhost-only for ngrok)
3. Starts ngrok tunnel to port 5901
4. Displays connection information

## Verification Steps

### Step 1: Build the Docker Image
```bash
cd /home/runner/work/kali-rdp-ngrok/kali-rdp-ngrok
docker build -t fedora-gnome-vnc-ngrok .
```

**Expected Output:**
- Successful download of Fedora 43 base image
- Installation of GNOME packages
- Installation of TigerVNC server
- VNC password file created
- VNC xstartup script created

### Step 2: Run the Container
```bash
docker run -d -p 5901:5901 --name fedora-vnc-test fedora-gnome-vnc-ngrok
```

### Step 3: Check Container Logs
```bash
docker logs -f fedora-vnc-test
```

**Expected Output:**
```
✓ D-Bus service started
Starting VNC server...
✓ VNC server started on display :1 (port 5901)
Starting ngrok tunnel...

============================================
  Fedora 43 GNOME VNC + RDP is ready!
============================================

System Login Credentials:
  Username: root
  Password: Devil

VNC Password: DevilVNC

VNC Connection Details:
  Host: <ngrok-host>:<port>

Use any VNC client to connect:
  - Windows: TigerVNC, RealVNC, TightVNC
  - macOS: TigerVNC, RealVNC, or built-in Screen Sharing
  - Linux: Remmina, TigerVNC, Vinagre
  - Android: VNC Viewer
  - iOS: VNC Viewer

============================================
```

### Step 4: Verify VNC Server is Running
```bash
docker exec kali-vnc-test ps aux | grep -E "Xvnc|Xtigervnc"
```

**Expected Output:**
```
root         XXX  X.X  X.X XXXXXX XXXXX ?        S    HH:MM   0:XX Xtigervnc :1 -geometry 1920x1080 -depth 24 -localhost no
```

### Step 5: Check VNC Files
```bash
docker exec kali-vnc-test ls -la /root/.vnc/
```

**Expected Output:**
```
drwxr-xr-x 2 root root 4096 <date> .
drwx------ 1 root root 4096 <date> ..
-rw------- 1 root root    8 <date> passwd
-rwxr-xr-x 1 root root  XXX <date> xstartup
-rw-r--r-- 1 root root XXXX <date> <hostname>:1.log
-rw-r--r-- 1 root root    5 <date> <hostname>:1.pid
```

### Step 6: Verify GNOME Process
```bash
docker exec fedora-vnc-test ps aux | grep gnome
```

**Expected Output:** Multiple GNOME processes including:
- `gnome-session`
- `gnome-shell`
- `mutter` (window manager)
- `Nautilus` (file manager)

### Step 7: Check VNC Log
```bash
docker exec fedora-vnc-test cat /root/.vnc/*.log | tail -50
```

**Expected Output:**
- VNC server started successfully
- X server initialized
- GNOME session started
- No critical errors

### Step 8: Test VNC Connection

#### Local Test (if Docker is on your machine):
```bash
# Install a VNC client if not already installed
# On Ubuntu/Debian: sudo apt install tigervnc-viewer
# On macOS: brew install tiger-vnc
# On Windows: Download TigerVNC from tigervnc.org

vncviewer localhost:5901
# Enter password: DevilVNC
```

#### Remote Test (via ngrok):
1. Get the ngrok URL from container logs
2. Open your VNC client
3. Connect to: `<ngrok-host>:<port>`
4. Enter VNC password: `DevilVNC`
5. You should see the GNOME 49 desktop with:
   - Top bar with activities button
   - Activities overview
   - Application grid
   - File manager icon
   - Terminal icon
   - Full Fedora desktop environment

### Step 9: Verify GNOME Desktop Features

Once connected via VNC:

1. **Desktop Environment Check:**
   - Verify GNOME top bar is visible at the top
   - Verify desktop background is loaded
   - Verify activities overview is accessible

2. **Open Terminal:**
   - Click on terminal icon or use application grid
   - Run: `echo $XDG_CURRENT_DESKTOP`
   - Expected: `GNOME`
   - Run: `echo $XDG_SESSION_TYPE`
   - Expected: `x11`

3. **Test Applications:**
   - Open File Manager (Nautilus)
   - Open Activities overview
   - Browse available Fedora applications

4. **Test Window Management:**
   - Move windows
   - Resize windows
   - Minimize/maximize windows

## Troubleshooting

### Issue: VNC server fails to start
**Check:**
```bash
docker exec kali-vnc-test cat /root/.vnc/*.log
```
Look for error messages about missing dependencies or configuration issues.

### Issue: Black screen in VNC client
**Possible causes:**
- GNOME failed to start
- Check if `gnome-session` is installed
- Verify xstartup script permissions

**Check:**
```bash
docker exec fedora-vnc-test cat /root/.vnc/xstartup
docker exec fedora-vnc-test ls -l /root/.vnc/xstartup
docker exec fedora-vnc-test which gnome-session
```

### Issue: Can't connect via VNC
**Check:**
1. VNC server is running on port 5901
2. Container port is exposed: `docker ps`
3. VNC password is correct: `DevilVNC`
4. Firewall is not blocking connections

## Technical Details

### VNC Display Mapping
- Display `:0` = Port 5900
- Display `:1` = Port 5901 (what we're using)
- Display `:2` = Port 5902

### GNOME Components Installed
- `gnome-session`: Session manager
- `gnome-shell`: GNOME Shell interface
- `mutter`: Window manager
- `Nautilus`: File manager
- Plus many other utilities from GNOME suite

### VNC Server Parameters
- `-geometry 1920x1080`: Sets screen resolution
- `-depth 24`: 24-bit color depth (16.7M colors)
- `-localhost no`: Allows network connections (required for ngrok)

## Verification Checklist

- [ ] Docker image builds successfully
- [ ] Container starts without errors
- [ ] D-Bus service starts
- [ ] VNC server starts on port 5901
- [ ] Ngrok tunnel establishes
- [ ] Connection details are printed
- [ ] VNC client can connect using ngrok URL
- [ ] VNC password authentication works
- [ ] GNOME desktop is visible and functional
- [ ] Can open applications
- [ ] Can interact with desktop (mouse, keyboard)
- [ ] No critical errors in logs

## Confirmation of Full Fedora GNOME Desktop

The implementation includes:
- ✅ **Full Fedora 43**: Using official `fedora:43` base image
- ✅ **Complete GNOME 49 Desktop**: Via `@workstation-product-environment` with Fedora theming
- ✅ **All GNOME Components**: Session manager, shell, window manager, file manager, etc.
- ✅ **Proper VNC Setup**: TigerVNC with correct xstartup configuration
- ✅ **Proper RDP Setup**: xrdp with correct xsession configuration
- ✅ **Full Desktop Experience**: Complete graphical environment with application grid
- ✅ **Fedora Applications**: All default Fedora Workstation applications pre-installed
- ✅ **Fedora Theming**: Official Fedora themes, icons, and wallpapers included

This is **NOT** a minimal setup - it's the full Fedora 43 GNOME 49 desktop environment as provided by the official Fedora Workstation ISO, accessible via both VNC and RDP.
