FROM kalilinux/kali-rolling

RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y \
        xfce4 xfce4-goodies xserver-xorg-core \
        tigervnc-standalone-server tigervnc-common \
        xrdp dbus-x11 sudo curl unzip && \
    echo "root:Devil" | chpasswd

# Create VNC directory and set up VNC password
RUN mkdir -p /root/.vnc && \
    echo "DevilVNC" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# Create VNC xstartup script for XFCE
RUN echo '#!/bin/sh' > /root/.vnc/xstartup && \
    echo 'unset SESSION_MANAGER' >> /root/.vnc/xstartup && \
    echo 'unset DBUS_SESSION_BUS_ADDRESS' >> /root/.vnc/xstartup && \
    echo 'export XDG_SESSION_TYPE=x11' >> /root/.vnc/xstartup && \
    echo 'export XDG_CURRENT_DESKTOP=XFCE' >> /root/.vnc/xstartup && \
    echo 'export XDG_SESSION_DESKTOP=XFCE' >> /root/.vnc/xstartup && \
    echo 'exec startxfce4' >> /root/.vnc/xstartup && \
    chmod 755 /root/.vnc/xstartup

# Install ngrok
RUN curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | gpg --dearmor -o /usr/share/keyrings/ngrok.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/ngrok.gpg] https://ngrok-agent.s3.amazonaws.com buster main" | tee /etc/apt/sources.list.d/ngrok.list && \
    apt update && apt install -y ngrok

# Copy startup script
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 5901 3389

CMD ["/usr/local/bin/start.sh"]
