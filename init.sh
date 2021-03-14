#!/bin/sh

openvpn \
    --config /etc/openvpn/config.ovpn \
    --script-security 2 \
    --up-delay \
    --up /etc/openvpn/start.sh \
    --down /etc/openvpn/stop.sh \
    --auth-user-pass /run/secrets/credentials \
    --remote $REMOTE_SERVER