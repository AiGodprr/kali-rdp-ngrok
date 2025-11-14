FROM fedora:43

# Update and install packages (SSL workaround for build environment)
RUN dnf install -y --setopt=sslverify=false ca-certificates && \
    update-ca-trust && \
    dnf update -y --setopt=sslverify=false && \
    dnf install -y --setopt=sslverify=false \
        @workstation-product-environment \
        tigervnc-server \
        xrdp dbus-x11 sudo curl unzip gnupg2 \
        mesa-dri-drivers mesa-libGL && \
    dnf clean all && \
    echo "root:Devil" | chpasswd

# Create VNC directory and set up VNC password
RUN mkdir -p /root/.vnc && \
    echo "DevilVNC" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# Create VNC xstartup script for GNOME with software rendering
RUN echo '#!/bin/sh' > /root/.vnc/xstartup && \
    echo 'unset SESSION_MANAGER' >> /root/.vnc/xstartup && \
    echo 'unset DBUS_SESSION_BUS_ADDRESS' >> /root/.vnc/xstartup && \
    echo 'export XDG_SESSION_TYPE=x11' >> /root/.vnc/xstartup && \
    echo 'export XDG_CURRENT_DESKTOP=GNOME' >> /root/.vnc/xstartup && \
    echo 'export XDG_SESSION_DESKTOP=gnome' >> /root/.vnc/xstartup && \
    echo 'export GNOME_SHELL_SESSION_MODE=classic' >> /root/.vnc/xstartup && \
    echo 'export LIBGL_ALWAYS_SOFTWARE=1' >> /root/.vnc/xstartup && \
    echo 'export GALLIUM_DRIVER=llvmpipe' >> /root/.vnc/xstartup && \
    echo 'dbus-launch --exit-with-session gnome-session' >> /root/.vnc/xstartup && \
    chmod 755 /root/.vnc/xstartup

# Install ngrok - Note: This step requires internet access
# If build fails here, ngrok will be installed at container runtime via start.sh
RUN curl -fsSL https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz -o /tmp/ngrok.tgz && \
    tar -xzf /tmp/ngrok.tgz -C /usr/local/bin && \
    chmod +x /usr/local/bin/ngrok && \
    rm /tmp/ngrok.tgz || \
    (echo "Warning: ngrok installation failed during build, will install at runtime" && true)

# Copy startup script
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 5901 3389

CMD ["/usr/local/bin/start.sh"]
