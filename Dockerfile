FROM ubuntu:24.04

RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y \
        ubuntu-desktop \
        tigervnc-standalone-server tigervnc-common \
        xrdp dbus-x11 sudo curl unzip gnupg && \
    echo "root:Devil" | chpasswd

# Create VNC directory and set up VNC password
RUN mkdir -p /root/.vnc && \
    echo "DevilVNC" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# Create VNC xstartup script for GNOME
RUN echo '#!/bin/sh' > /root/.vnc/xstartup && \
    echo 'unset SESSION_MANAGER' >> /root/.vnc/xstartup && \
    echo 'unset DBUS_SESSION_BUS_ADDRESS' >> /root/.vnc/xstartup && \
    echo 'export XDG_SESSION_TYPE=x11' >> /root/.vnc/xstartup && \
    echo 'export XDG_CURRENT_DESKTOP=GNOME' >> /root/.vnc/xstartup && \
    echo 'export XDG_SESSION_DESKTOP=ubuntu' >> /root/.vnc/xstartup && \
    echo 'export GNOME_SHELL_SESSION_MODE=ubuntu' >> /root/.vnc/xstartup && \
    echo 'exec gnome-session' >> /root/.vnc/xstartup && \
    chmod 755 /root/.vnc/xstartup

# Install ngrok - Note: This step requires internet access
# If build fails here, ngrok will be installed at container runtime via start.sh
RUN curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | gpg --dearmor -o /usr/share/keyrings/ngrok.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/ngrok.gpg] https://ngrok-agent.s3.amazonaws.com buster main" | tee /etc/apt/sources.list.d/ngrok.list && \
    apt update && apt install -y ngrok || \
    (echo "Warning: ngrok installation failed during build, will install at runtime" && true)

# Copy startup script
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 5901 3389

CMD ["/usr/local/bin/start.sh"]
