FROM ubuntu:latest

# Install necessary packages
RUN apt-get update && \
    apt-get install -y wireguard sudo python3 python3-pip python3-venv iproute2 iptables curl git && \
    rm -rf /var/lib/apt/lists/*  # Clean up to reduce image size

# Create directories for WireGuard config and keys
RUN mkdir -p /etc/wireguard/keys

# Generate private and public keys and create wg0.conf
RUN bash -c 'wg genkey | tee /etc/wireguard/keys/privatekey | wg pubkey > /etc/wireguard/keys/publickey' && \
    echo "[Interface]" > /etc/wireguard/wg0.conf && \
    echo "Address = 10.0.0.1/24" >> /etc/wireguard/wg0.conf && \
    echo "SaveConfig = true" >> /etc/wireguard/wg0.conf && \
    echo "PostUp = sysctl -w net.ipv4.ip_forward=1" >> /etc/wireguard/wg0.conf && \
    echo "PostUp = iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE" >> /etc/wireguard/wg0.conf && \
    echo "PostDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE" >> /etc/wireguard/wg0.conf && \
    echo "ListenPort = 51820" >> /etc/wireguard/wg0.conf && \
    echo "PrivateKey = $(cat /etc/wireguard/keys/privatekey)" >> /etc/wireguard/wg0.conf

# Enable IP forwarding for routing traffic
RUN echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

# Clone WireGuard dashboard
RUN git clone https://github.com/khantmgmg/wireguard-dashboard.git /home/ubuntu/wgdashboard

# Install requirements and set permissions
RUN cd /home/ubuntu/wgdashboard/src && \
    pip3 install --break-system-packages -r requirements.txt && \
    chmod u+x wgd.sh && \
    ./wgd.sh install && \
    chmod -R 755 /etc/wireguard

# Expose the WireGuard and dashboard ports
EXPOSE 51820/udp
EXPOSE 10086/tcp

# Start WireGuard and the WireGuard dashboard on container start
CMD bash -c "wg-quick up wg0 && cd /home/ubuntu/wgdashboard/src && ./wgd.sh start && tail -f /dev/null"
