# docker-qbittorrent-filebot

Example configuration to run this container (`docker-compose.yml` style).

```yaml
services:
  qbittorrent:
    container_name: qbittorrent
    environment:
      - S6_SERVICES_GRACETIME=0
      - PUID=${UID}
      - PGID=${GID}
      - TZ=Europe/Rome
      - UMASK_SET=002
      - WEBUI_PORT=9090
      - JAVA_OPTS=-Xmx4g
      - >-
        FILEBOT_OPTS=-Dapplication.deployment=docker
        -Dapplication.cache=/filebot/cache
        -Dapplication.dir=/filebot
        -Djava.io.tmpdir=/tmp/filebot
        -Djava.library.path=/usr/lib/x86_64-linux-gnu
        -Djna.library.path=/usr/lib/x86_64-linux-gnu
        -Dnet.filebot.archive.extractor=ShellExecutables
        -Dnet.filebot.AcoustID.fpcalc=/usr/bin/fpcalc
        -Dnet.filebot.license=/filebot/license.txt
        -Dnet.filebot.util.prefs.file=/filebot/prefs.properties
        -Duser.home=/filebot
      - OUT_DIR=/cephfs
      # expects /filebot/license.txt
    expose:
    - "9090"
    healthcheck:
      test: ['CMD', 'http', '--body', ':9090/api/v2/app/version']
    image: devster31/qbittorrent-filebot
    ports:
      - 6881:6881
      - 6881:6881/udp
      - 9090:9090
    restart: "no"
    volumes:
      - "qbittorrent_data:/config"
      - "filebot_data:/filebot"
      - "${MOUNT}/scripts:/scripts"
      - "${MOUNT}/torrent/downloads:${MOUNT}/torrent/downloads"
      - "${MOUNT}/torrent/watch:/watch"
      - type: tmpfs
        target: /tmp
```

Most of `FILEBOT_OPTS` is actually required but I isn't included it in the image yet.
