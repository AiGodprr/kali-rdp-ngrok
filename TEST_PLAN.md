# Test Plan for Full Kali XFCE Desktop

This document outlines the testing plan for verifying the full Kali XFCE desktop implementation.

## Overview

The container has been updated to install the full Kali XFCE desktop experience using:
- `kali-desktop-xfce` - Complete XFCE desktop with Kali theming
- `kali-linux-default` - Full default toolset

## Pre-Build Verification

- [x] Dockerfile syntax is valid
- [x] Package names are correct (`kali-desktop-xfce`, `kali-linux-default`)
- [x] VNC xstartup configuration ends with `exec startxfce4`
- [x] RDP xsession configuration ends with `exec startxfce4`
- [x] XDG environment variables properly set
- [x] No leftover commands that only start terminal

## Build Phase Testing

### Test 1: Docker Build
```bash
cd /home/runner/work/kali-rdp-ngrok/kali-rdp-ngrok
docker build -t kali-vnc-rdp-ngrok:full-desktop .
```

**Expected Results:**
- Build completes successfully
- Image size is approximately 3-4 GB
- All packages install without errors
- No missing dependencies

### Test 2: Container Startup
```bash
docker run -d -p 5901:5901 -p 3389:3389 --name kali-test kali-vnc-rdp-ngrok:full-desktop
docker logs -f kali-test
```

**Expected Results:**
- Container starts successfully
- D-Bus service starts
- VNC server starts on port 5901
- xrdp service starts on port 3389
- ngrok tunnels establish
- Connection info displayed in logs

## Runtime Phase Testing

### Test 3: Service Verification
```bash
# Check VNC server
docker exec kali-test ps aux | grep Xtigervnc

# Check XFCE processes
docker exec kali-test ps aux | grep xfce4-session
docker exec kali-test ps aux | grep xfwm4
docker exec kali-test ps aux | grep xfce4-panel

# Check RDP service
docker exec kali-test service xrdp status

# Check D-Bus
docker exec kali-test ps aux | grep dbus-daemon
```

**Expected Results:**
- VNC server (Xtigervnc) is running on display :1
- Multiple XFCE processes are running (session, window manager, panel, etc.)
- xrdp service is active and running
- D-Bus session bus is running

### Test 4: VNC Connection Test

Using a VNC client (TigerVNC, RealVNC, etc.):

1. Connect to the ngrok VNC URL from logs
2. Enter VNC password: `DevilVNC`
3. Observe the desktop environment

**Expected Results:**
- Full XFCE desktop loads immediately (no black screen)
- Desktop shows:
  - ✅ Proper Kali wallpaper/background
  - ✅ XFCE panel at bottom with:
    - Application menu button
    - Desktop switcher
    - System tray icons
    - Clock
  - ✅ Desktop icons (if any)
  - ✅ Proper window decorations and theming

4. Click on Application Menu
   - ✅ Full menu structure with categories
   - ✅ Kali tools organized by category (Information Gathering, Vulnerability Analysis, etc.)
   - ✅ Standard applications (File Manager, Terminal, etc.)

5. Test Applications:
   - Open Terminal (should open xfce4-terminal)
   - Open File Manager (should open Thunar)
   - Browse to Applications > Kali Linux Tools
   - Verify multiple tool categories exist

### Test 5: RDP Connection Test

Using an RDP client (Microsoft Remote Desktop, Remmina, etc.):

1. Connect to the ngrok RDP URL from logs
2. Enter credentials: `root` / `Devil`
3. Observe the desktop environment

**Expected Results:**
- Same full XFCE desktop as VNC
- All desktop features work properly
- Can open applications and tools
- Window management works correctly

### Test 6: Desktop Features Test

Once connected (via VNC or RDP):

1. **Environment Variables**:
```bash
# Open terminal and run:
echo $XDG_CURRENT_DESKTOP  # Should output: XFCE
echo $XDG_SESSION_TYPE     # Should output: x11
echo $XDG_SESSION_DESKTOP  # Should output: XFCE
```

2. **Kali Tools Test**:
   - Click Applications > Kali Linux Tools
   - Verify categories exist:
     - Information Gathering
     - Vulnerability Analysis
     - Web Application Analysis
     - Database Assessment
     - Password Attacks
     - Wireless Attacks
     - Reverse Engineering
     - Exploitation Tools
     - Sniffing & Spoofing
     - Post Exploitation
     - Forensics
     - Reporting Tools
     - Social Engineering Tools
   - Try launching a tool (e.g., nmap, metasploit)

3. **Desktop Customization**:
   - Right-click on desktop → verify context menu works
   - Click Applications → Settings
   - Verify XFCE settings manager opens
   - Check available settings panels

4. **File Manager**:
   - Open File Manager (Thunar)
   - Navigate to /usr/share/applications
   - Verify many Kali tool .desktop files exist
   - Verify Kali icons and theming

### Test 7: Comparison with Previous Setup

Compare the experience with what was there before:

| Aspect | Before (Minimal) | After (Full Desktop) |
|--------|------------------|---------------------|
| Background | Black/plain | Kali wallpaper |
| Panel | Basic/empty | Full XFCE panel with icons |
| Application Menu | Minimal | Complete Kali tool categories |
| Tools Available | Very few | All kali-linux-default tools |
| Theming | Generic XFCE | Kali-branded |
| Desktop Icons | None/minimal | Proper icons if configured |
| Ready to Use | No, manual setup needed | Yes, fully configured |

## Performance Testing

### Test 8: Resource Usage
```bash
# Check memory usage
docker stats kali-test --no-stream

# Check image size
docker images | grep kali-vnc-rdp-ngrok
```

**Expected Results:**
- Image size: ~3-4 GB (larger than minimal)
- Runtime memory: ~1-2 GB with desktop running
- CPU usage: Low when idle
- Startup time: Under 30-60 seconds

### Test 9: Session Stability
- Keep VNC/RDP session open for 10+ minutes
- Open multiple applications
- Switch between windows
- Resize windows

**Expected Results:**
- Session remains stable
- No crashes or freezes
- Applications work normally
- No unusual errors in logs

## Regression Testing

### Test 10: Ngrok Functionality
- Verify ngrok tunnels still work
- Check both VNC and RDP tunnels are created
- Verify connection info is properly displayed in logs
- Test connecting from external network

**Expected Results:**
- Both tunnels establish successfully
- URLs are displayed in correct format
- External connections work
- No changes to ngrok behavior

### Test 11: Credentials
- VNC password still works: `DevilVNC`
- RDP credentials still work: `root` / `Devil`
- System login still works: `root` / `Devil`

**Expected Results:**
- All authentication works as before
- No credential changes

## Documentation Testing

### Test 12: README Accuracy
- Follow the README instructions
- Verify all commands work
- Check that documentation matches actual behavior

**Expected Results:**
- README accurately describes the full desktop
- Image size information is correct
- Connection instructions work

## Success Criteria

The implementation is considered successful if:

1. ✅ Docker image builds successfully
2. ✅ Container starts without errors
3. ✅ Both VNC and RDP connections work
4. ✅ Full Kali XFCE desktop is visible (not minimal/black screen)
5. ✅ Application menu shows complete Kali tool categories
6. ✅ Kali theming and wallpaper are present
7. ✅ Standard Kali tools are available and launchable
8. ✅ Desktop is stable and responsive
9. ✅ Ngrok tunnels work as before
10. ✅ Performance is acceptable (startup <60s, responsive UI)

## Known Limitations

- Image size is larger (~3-4 GB)
- First build takes longer
- Memory usage is higher than minimal setup
- Not suitable for very resource-constrained environments

## Rollback Plan

If the full desktop causes issues:
1. Revert Dockerfile to use `xfce4 xfce4-goodies xserver-xorg-core`
2. Rebuild image
3. Document specific issues encountered
4. Consider intermediate solution with fewer tools

## Notes for Testers

- The desktop experience should match the official Kali Linux ISO with XFCE
- This is NOT a minimal setup - it's meant to be feature-complete
- The goal is to provide an authentic Kali Linux desktop experience via remote access
- Any missing tools or broken menus indicate a problem that needs investigation
