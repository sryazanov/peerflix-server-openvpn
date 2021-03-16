FROM node:alpine
RUN apk add --no-cache tini openvpn ffmpeg curl && \
  npm install -g forever peerflix-server && \
  sed -i 's/BITTORRENT_PORT = 6881/BITTORRENT_PORT = process.env.BITTORRENT_PORT || 6881/g' /usr/local/lib/node_modules/peerflix-server/server/engine.js

ADD ./config/ /etc/openvpn/
ADD ./init.sh /root/init.sh

EXPOSE 9000
ENTRYPOINT [ "/sbin/tini", "--", "/root/init.sh" ]