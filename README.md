# Peerflix Server with OpenVPN

The idea borrowed from https://github.com/haugene/docker-transmission-openvpn/

Transmission replaced with peerflix-server. Only privatevpn supported at the moment.

Peerflix-server starts when VPN connection established and firewall set up with UID/GID=1000.

# Usage with docker-compose
Create .credentials file (first line - username, second line password)

docker-compose.yml:
```
version: '3.7'
services:
    peerflix-server-openvpn:
        cap_add:
            - NET_ADMIN
        devices:
            - /dev/net/tun
        build: https://github.com/sryazanov/peerflix-server-openvpn.git
        ports:
            - 9000:9000
        secrets:
            - credentials
        environment:
            - REMOTE_SERVER="se-kis.pvdata.host 1194 udp"
        volumes:
            - ./var/peerflix/cache/:/tmp/torrent-stream/
            - ./var/peerflix/home/:/home/node/
secrets:
    credentials:
        file: ./.credentials
```