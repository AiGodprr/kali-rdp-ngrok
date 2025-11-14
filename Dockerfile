FROM kalilinux/kali-rolling

RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y \
        xfce4 xfce4-goodies xrdp xorgxrdp xserver-xorg-core \
        tigervnc-standalone-server dbus-x11 sudo curl unzip && \
    echo "root:Devil" | chpasswd && \
    adduser xrdp ssl-cert

# Copy XRDP configuration files
COPY config/xrdp/sesman.ini /etc/xrdp/sesman.ini
COPY config/xrdp/xrdp.ini /etc/xrdp/xrdp.ini
COPY config/xrdp/startwm.sh /etc/xrdp/startwm.sh
COPY config/xrdp/root.xsession /root/.xsession

# Set proper permissions for XRDP configuration files
RUN chmod 644 /etc/xrdp/sesman.ini /etc/xrdp/xrdp.ini && \
    chmod 755 /etc/xrdp/startwm.sh /root/.xsession

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
