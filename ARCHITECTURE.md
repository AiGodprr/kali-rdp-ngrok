# Fedora GNOME VNC Architecture

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     Docker Container                            │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                     Fedora 43                            │  │
│  │                                                          │  │
│  │  ┌─────────────────────────────────────────────────┐    │  │
│  │  │        GNOME 49 Desktop Environment             │    │  │
│  │  │  - gnome-session (Session Manager)              │    │  │
│  │  │  - gnome-shell (Shell)                          │    │  │
│  │  │  - mutter (Window Manager)                      │    │  │
│  │  │  - Nautilus (File Manager)                      │    │  │
│  │  │  - GNOME Terminal                               │    │  │
│  │  │  - All GNOME core applications                  │    │  │
│  │  │  - All Fedora Workstation applications          │    │  │
│  │  └─────────────────────────────────────────────────┘    │  │
│  │                          ↕                               │  │
│  │  ┌─────────────────────────────────────────────────┐    │  │
│  │  │     TigerVNC X Server (Xtigervnc)               │    │  │
│  │  │     Display :1 → Port 5901                      │    │  │
│  │  │     Resolution: 1920x1080 @ 24-bit              │    │  │
│  │  └─────────────────────────────────────────────────┘    │  │
│  │                          ↕                               │  │
│  │  ┌─────────────────────────────────────────────────┐    │  │
│  │  │        D-Bus Session Bus                        │    │  │
│  │  │        (Inter-process communication)            │    │  │
│  │  └─────────────────────────────────────────────────┘    │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              Ngrok TCP Tunnel                           │  │
│  │         localhost:5901 → tcp://ngrok.io:XXXXX          │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              ↕
                    Internet (Ngrok Cloud)
                              ↕
┌─────────────────────────────────────────────────────────────────┐
│                       VNC Clients                               │
│  • TigerVNC Viewer (Windows/Mac/Linux)                         │
│  • RealVNC (Windows/Mac/Linux/iOS/Android)                     │
│  • Remmina (Linux)                                             │
│  • macOS Screen Sharing                                        │
│  • VNC Viewer (Mobile)                                         │
└─────────────────────────────────────────────────────────────────┘
```

## Component Details

### 1. Fedora 43 Base
- **Image**: `fedora:43`
- **Description**: Official Fedora 43 release
- **Includes**: Full Fedora Workstation environment via `@workstation-product-environment`
- **User**: root (password: Devil)

### 2. GNOME 49 Desktop Environment
Complete installation via `@workstation-product-environment` includes:

#### Full Fedora GNOME Desktop:
- Complete GNOME 49 desktop environment with Fedora theming
- `gnome-session` - Session and startup manager
- `gnome-shell` - GNOME Shell interface
- `mutter` - Window manager with compositing
- `Nautilus` - File manager
- `GNOME Terminal` - Terminal emulator
- `GNOME Settings` - Settings manager
- `GNOME Software` - Application installer
- `GNOME Calendar` - Calendar application
- `GNOME Files` - File browser
- Fedora themes, icons, and wallpapers
- All GNOME core applications
- Properly configured application grid with Fedora applications

### 3. TigerVNC Server
- **Package**: `tigervnc-standalone-server`
- **Display**: `:1` (port 5901)
- **Protocol**: RFB (Remote Framebuffer Protocol)
- **Resolution**: 1920x1080 pixels
- **Color Depth**: 24-bit (16.7 million colors)
- **Authentication**: VNC password (DevilVNC)
- **Network**: Accessible from all interfaces (for ngrok)

### 4. X Window System
- **Package**: `xserver-xorg-core`
- **Server**: Xtigervnc (TigerVNC's X server implementation)
- **Session Type**: X11
- **Display Manager**: None (direct VNC startup)

### 5. D-Bus
- **Package**: `dbus-x11`
- **Purpose**: Inter-process communication for XFCE
- **Session Bus**: Started before VNC server
- **Required For**: XFCE settings, notifications, and many desktop features

### 6. Ngrok Tunnel
- **Type**: TCP tunnel
- **Local Endpoint**: localhost:5901
- **Remote Endpoint**: tcp://ngrok.io:XXXXX (dynamic)
- **Authentication**: Ngrok authtoken
- **Purpose**: Expose VNC server to internet

## Startup Sequence

```
1. Container starts
   ↓
2. start.sh executes
   ↓
3. D-Bus service starts
   ├─ Creates session bus
   └─ Required for XFCE IPC
   ↓
4. VNC server starts
   ├─ Reads /root/.vnc/passwd (password: DevilVNC)
   ├─ Executes /root/.vnc/xstartup
   │  ├─ Sets environment variables:
   │  │  - XDG_SESSION_TYPE=x11
   │  │  - XDG_CURRENT_DESKTOP=GNOME
   │  │  - XDG_SESSION_DESKTOP=gnome
   │  └─ Executes: gnome-session
   ├─ Launches Xtigervnc on display :1
   ├─ Starts GNOME session
   │  ├─ gnome-session starts
   │  ├─ gnome-shell starts
   │  ├─ mutter (window manager) starts
   │  ├─ Nautilus daemon starts
   │  └─ All GNOME services start
   └─ Listens on port 5901
   ↓
5. Ngrok starts
   ├─ Reads /root/.ngrok2/ngrok.yml
   ├─ Creates TCP tunnel to port 5901
   ├─ Gets public URL from ngrok.io
   └─ Writes tunnel info to API (localhost:4040)
   ↓
6. Display connection info
   ├─ Queries ngrok API
   ├─ Prints VNC connection details
   └─ Shows credentials
   ↓
7. Container runs continuously
   └─ Tails ngrok log
```

## Process Tree (when running)

```
init (PID 1)
├─ start.sh
│  ├─ dbus-daemon (D-Bus session bus)
│  ├─ Xtigervnc :1 (VNC X server)
│  │  └─ gnome-session (GNOME session manager)
│  │     ├─ gnome-shell (GNOME shell)
│  │     ├─ mutter (window manager)
│  │     ├─ Nautilus --daemon (file manager)
│  │     ├─ gnome-settings-daemon
│  │     └─ other GNOME services
│  └─ ngrok (TCP tunnel)
└─ tail -f /tmp/ngrok.log
```

## Network Flow

```
User's VNC Client
      ↓ (RFB Protocol over TCP)
Ngrok Cloud (tcp://X.ngrok.io:XXXXX)
      ↓ (TCP tunnel)
Docker Container Port 5901
      ↓
TigerVNC Server (display :1)
      ↓
GNOME 49 Desktop Session
      ↓
Fedora 43 System
```

## Authentication Layers

1. **Ngrok**: Public URL only known to authorized users
2. **VNC Password**: "DevilVNC" - required for VNC connection
3. **System Login**: root/Devil - optional, for terminal access within session

## Why This Is a FULL Desktop Environment

### This is NOT:
- ❌ A minimal X server with just xterm
- ❌ A basic window manager like TWM
- ❌ A headless system with only CLI
- ❌ A lightweight desktop like LXDE or LXQt or XFCE
- ❌ Generic GNOME without Fedora integration

### This IS:
- ✅ Complete Fedora 43 system with full Workstation environment
- ✅ Full Fedora-themed GNOME 49 desktop via `@workstation-product-environment`
- ✅ All GNOME core components with Fedora customization
- ✅ All GNOME applications and utilities
- ✅ Graphical file manager, terminal, and applications
- ✅ Complete application grid with system tray
- ✅ Complete application grid with categorized Fedora applications
- ✅ Settings manager for customization
- ✅ Power management, notifications, and more
- ✅ Fedora themes, icons, and wallpapers
- ✅ Same experience as installing Fedora 43 Workstation from official ISO

## Comparison with Previous Setup

| Aspect | Previous (Ubuntu 24.04) | Current (Fedora 43) |
|--------|-------------------------|---------------------|
| Base OS | Ubuntu 24.04 LTS | Fedora 43 |
| Desktop | GNOME 46 | GNOME 49 |
| Protocol | VNC + RDP | VNC + RDP |
| Port | 5901 (VNC), 3389 (RDP) | 5901 (VNC), 3389 (RDP) |
| Package Manager | apt/dpkg | dnf/rpm |
| Desktop Session | gnome-session | gnome-session |
| Theming | Ubuntu | Fedora |

## Verification Commands

After container starts, verify the full desktop is running:

```bash
# Check VNC server process
docker exec <container> ps aux | grep Xtigervnc

# Check GNOME processes
docker exec <container> ps aux | grep gnome-session
docker exec <container> ps aux | grep gnome-shell
docker exec <container> ps aux | grep mutter

# Check D-Bus
docker exec <container> ps aux | grep dbus-daemon

# Verify environment variables
docker exec <container> bash -c 'source /root/.vnc/xstartup && echo $XDG_CURRENT_DESKTOP'

# Check VNC log for GNOME startup
docker exec <container> cat /root/.vnc/*.log | grep -i gnome
```

## Conclusion

This implementation provides a **complete, full-featured Fedora 43 GNOME 49 desktop environment** accessible via both VNC and RDP. It includes:

- Full Fedora Workstation environment via `@workstation-product-environment`
- Complete GNOME 49 desktop with Fedora theming
- All GNOME desktop components with Fedora customization
- All GNOME utility applications
- All standard Fedora Workstation applications
- Full graphical interface with proper theming
- Complete desktop experience with application grid
- Fedora wallpapers, icons, and customization

Users connecting via VNC or RDP will have the exact same experience as if they were running Fedora 43 Workstation with GNOME 49 from the official ISO on a physical machine.
