FROM ubuntu:24.04

# Update and install required packages
RUN apt-get update && \
    apt-get install -y \
        ca-certificates \
        curl \
        git \
        nodejs \
        npm \
        tar \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install code-server by downloading the binary
RUN curl -fsSLk https://github.com/coder/code-server/releases/download/v4.23.1/code-server-4.23.1-linux-amd64.tar.gz -o /tmp/code-server.tar.gz && \
    tar -xzf /tmp/code-server.tar.gz -C /tmp && \
    mv /tmp/code-server-4.23.1-linux-amd64 /usr/local/lib/code-server && \
    ln -s /usr/local/lib/code-server/bin/code-server /usr/local/bin/code-server && \
    rm /tmp/code-server.tar.gz

# Copy startup script
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 8080

CMD ["/usr/local/bin/start.sh"]
