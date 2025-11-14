FROM kalilinux/kali-rolling

RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y \
        xfce4 xfce4-goodies xrdp dbus-x11 sudo curl unzip && \
    echo "root:Devil" | chpasswd && \
    adduser xrdp ssl-cert

# Configure XRDP to prevent blue screen
RUN echo "#!/bin/sh" > /root/.xsession && \
    echo "# XFCE Session Configuration" >> /root/.xsession && \
    echo "export XDG_SESSION_TYPE=x11" >> /root/.xsession && \
    echo "export XDG_CURRENT_DESKTOP=XFCE" >> /root/.xsession && \
    echo "exec startxfce4" >> /root/.xsession && \
    chmod +x /root/.xsession && \
    echo "#!/bin/sh" > /etc/xrdp/startwm.sh && \
    echo "# XRDP Session Startup Script" >> /etc/xrdp/startwm.sh && \
    echo "# Unset conflicting environment variables" >> /etc/xrdp/startwm.sh && \
    echo "unset DBUS_SESSION_BUS_ADDRESS" >> /etc/xrdp/startwm.sh && \
    echo "unset XDG_RUNTIME_DIR" >> /etc/xrdp/startwm.sh && \
    echo "" >> /etc/xrdp/startwm.sh && \
    echo "# Set locale" >> /etc/xrdp/startwm.sh && \
    echo "if [ -r /etc/default/locale ]; then" >> /etc/xrdp/startwm.sh && \
    echo "  . /etc/default/locale" >> /etc/xrdp/startwm.sh && \
    echo "  export LANG LANGUAGE" >> /etc/xrdp/startwm.sh && \
    echo "fi" >> /etc/xrdp/startwm.sh && \
    echo "" >> /etc/xrdp/startwm.sh && \
    echo "# Set XDG environment variables for XFCE" >> /etc/xrdp/startwm.sh && \
    echo "export XDG_SESSION_TYPE=x11" >> /etc/xrdp/startwm.sh && \
    echo "export XDG_CURRENT_DESKTOP=XFCE" >> /etc/xrdp/startwm.sh && \
    echo "export XDG_SESSION_DESKTOP=XFCE" >> /etc/xrdp/startwm.sh && \
    echo "" >> /etc/xrdp/startwm.sh && \
    echo "# Start XFCE session" >> /etc/xrdp/startwm.sh && \
    echo "if [ -r /root/.xsession ]; then" >> /etc/xrdp/startwm.sh && \
    echo "  . /root/.xsession" >> /etc/xrdp/startwm.sh && \
    echo "else" >> /etc/xrdp/startwm.sh && \
    echo "  exec startxfce4" >> /etc/xrdp/startwm.sh && \
    echo "fi" >> /etc/xrdp/startwm.sh && \
    chmod +x /etc/xrdp/startwm.sh

# Configure XRDP sesman.ini for proper session management
RUN sed -i 's/^param=Xvnc/param=Xorg/' /etc/xrdp/sesman.ini || true && \
    sed -i 's/^param=-bs/param=-listen tcp/' /etc/xrdp/sesman.ini || true && \
    sed -i '/\[Xorg\]/a param=-listen tcp' /etc/xrdp/sesman.ini || true && \
    echo "" >> /etc/xrdp/sesman.ini && \
    echo "[SessionVariables]" >> /etc/xrdp/sesman.ini && \
    echo "PULSE_SCRIPT=/etc/xrdp/pulse/default.pa" >> /etc/xrdp/sesman.ini && \
    echo "XDG_SESSION_TYPE=x11" >> /etc/xrdp/sesman.ini && \
    echo "XDG_CURRENT_DESKTOP=XFCE" >> /etc/xrdp/sesman.ini

# Install ngrok
RUN curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | gpg --dearmor -o /usr/share/keyrings/ngrok.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/ngrok.gpg] https://ngrok-agent.s3.amazonaws.com buster main" | tee /etc/apt/sources.list.d/ngrok.list && \
    apt update && apt install -y ngrok

# Copy ngrok config and startup script
COPY ngrok.yml /root/.ngrok2/ngrok.yml
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 3389

CMD ["/usr/local/bin/start.sh"]
