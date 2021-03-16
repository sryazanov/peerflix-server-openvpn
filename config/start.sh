#! /bin/sh

# Get the port
tun_ip=$(ip address show dev tun0 | grep 'inet\b' | awk '{print $2}' | cut -d/ -f1)
pvpn_get_port_url="https://xu515.pvdatanet.com/v3/mac/port?ip%5B%5D=$tun_ip"
pvpn_response=$(curl -s -f "$pvpn_get_port_url")
pvpn_curl_exit_code=$?

if [[ -z "$pvpn_response" ]]; then
    echo "PrivateVPN port forward API returned a bad response"
fi

# Check for curl error (curl will fail on HTTP errors with -f flag)
if [[ ${pvpn_curl_exit_code} -ne 0 ]]; then
    echo "curl encountered an error looking up forwarded port: $pvpn_curl_exit_code"
    exit
fi

# Check for errors in curl response
error=$(echo "$pvpn_response" | grep -o "\"Not supported\"")
if [[ ! -z "$error" ]]; then
    echo "PrivateVPN API returned an error: $error - not all PrivateVPN servers support port forwarding. Try 'SE Stockholm'."
    exit
fi

# Get new port, check if empty
new_port=$(echo "$pvpn_response" | grep -oe 'Port [0-9]*' | awk '{print $2}' | cut -d/ -f1)
if [[ -z "$new_port" ]]; then
    echo "Could not find new port from PrivateVPN API"
    exit
fi
echo "Got new port $new_port from PrivateVPN API"

/etc/openvpn/up.sh "$@"

mkdir -p /tmp/torrent-stream
chown node:node -R /tmp/torrent-stream /home/node

# Killswitch
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -o tun+ -j ACCEPT
iptables -A INPUT -s ${trusted_ip}/32 -p udp --dport ${trusted_port} -j ACCEPT
iptables -A OUTPUT -d ${trusted_ip}/32 -p udp --sport ${trusted_port} -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i tun+ -p tcp --dport ${new_port} -j ACCEPT
iptables -A INPUT -i eth+ -p tcp --dport 9000 -j ACCEPT

BITTORRENT_PORT=$new_port su node -c "/usr/local/bin/forever start /usr/local/bin/peerflix-server"
echo Listening on http://localhost:9000