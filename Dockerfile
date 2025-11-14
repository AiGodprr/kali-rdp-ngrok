FROM fedora:43

# Update and install QEMU and required packages
RUN dnf install -y --setopt=sslverify=false ca-certificates && \
    update-ca-trust && \
    dnf update -y --setopt=sslverify=false && \
    dnf install -y --setopt=sslverify=false \
        qemu-kvm qemu-img qemu-system-x86 \
        curl unzip gnupg2 \
        python3 expect \
        && \
    dnf clean all

# Install ngrok - Note: This step requires internet access
# If build fails here, ngrok will be installed at container runtime via start.sh
RUN curl -fsSL https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz -o /tmp/ngrok.tgz && \
    tar -xzf /tmp/ngrok.tgz -C /usr/local/bin && \
    chmod +x /usr/local/bin/ngrok && \
    rm /tmp/ngrok.tgz || \
    (echo "Warning: ngrok installation failed during build, will install at runtime" && true)

# Create directory for VM files
RUN mkdir -p /vm

# Copy startup script
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 3389

CMD ["/usr/local/bin/start.sh"]
