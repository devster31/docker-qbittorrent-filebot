# docker-qbittorrent-filebot

[![MicroBadger](https://images.microbadger.com/badges/image/devster31/qbittorrent-filebot.svg)](https://microbadger.com/images/devster31/qbittorrent-filebot "Get your own image badge on microbadger.com")
[![Docker Pulls](https://img.shields.io/docker/pulls/devster31/qbittorrent-filebot.svg?style=flat-square&color=E68523&label=pulls&logo=docker&logoColor=FFFFFF)](https://hub.docker.com/r/devster31/qbittorrent-filebot)
[![Docker Stars](https://img.shields.io/docker/stars/devster31/qbittorrent-filebot.svg?style=flat-square&color=E68523&label=stars&logo=docker&logoColor=FFFFFF)](https://hub.docker.com/r/devster31/qbittorrent-filebot)

## Usage

Example snippet to run this container.

### docker-compose

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

## Parameters

Container images are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `-p 6881` | tcp connection port |
| `-p 6881/udp` | udp connection port |
| `-p 8080` | http gui |
| `-e PUID=1000` | for UserID - see below for explanation |
| `-e PGID=1000` | for GroupID - see below for explanation |
| `-e TZ=Europe/London` | Specify a timezone to use EG Europe/London |
| `-e UMASK_SET=022` | for umask setting of qbittorrent, optional , default if left unset is 022 |
| `-e WEBUI_PORT=8080` | for changing the port of the webui, see below for explanation |
| `-v /config` | Contains all relevant configuration files. |
| `-v /filebot` | Contains all FileBot files. |

Most of `FILEBOT_OPTS` is actually required but I isn't included it in the image yet.

## Environment variables from files (Docker secrets)

You can set any environment variable from a file by using a special prepend `FILE__`.

As an example:

```
-e FILE__PASSWORD=/run/secrets/mysecretpassword
```

Will set the environment variable `PASSWORD` based on the contents of the `/run/secrets/mysecretpassword` file.


## Application Setup

The webui is at `<your-ip>:8080` and the default username/password is `admin/adminadmin`.

Change username/password via the webui in the webui section of settings.

### WEBUI_PORT variable

Due to issues with CSRF and port mapping, should you require to alter the port for the webui you need to
change both sides of the `-p 8080` switch AND set the `WEBUI_PORT` variable to the new port.

For example, to set the port to 8090 you need to set `-p <external_port>:8090` and `-e WEBUI_PORT=8090`

If you have no webui , check the file /config/qBittorrent/qBittorrent.conf and edit or add the following lines:

```
WebUI\Address=*
WebUI\ServerDomains=*
```
