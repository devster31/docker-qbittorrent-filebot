FROM ubuntu:bionic

# version args
ARG SHORT_TAG_VER
ARG FULL_TAG_VER
ARG QBITTORRENT_VER
ARG FILEBOT_VER
# version args for s6 overlay
ARG S6_OVERLAY_VER
ARG S6_OVERLAY_ARCH="amd64"

LABEL org.opencontainers.image.version="${SHORT_TAG_VER}"
LABEL org.opencontainers.image.tag.version="${FULL_TAG_VER}"
LABEL org.opencontainers.image.qbittorrent.version="${QBITTORRENT_VER}"
LABEL org.opencontainers.image.filebot.version="${FILEBOT_VER}"
LABEL org.opencontainers.image.s6-overlay.version="${S6_OVERLAY_VER}"
LABEL maintainer="devster31"

# environment settings
ENV HOME="/config" \
    XDG_CONFIG_HOME="/config" \
    XDG_DATA_HOME="/config" \
    QBITTORRENT_VER="${QBITTORRENT_VER}" \
    FILEBOT_VER="${FILEBOT_VER}" \
    S6_OVERLAY_VER="${S6_OVERLAY_VER}"

# add repo and install qbitorrent
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update -q && \
    apt-get install -q -y --no-install-recommends \
        apt-transport-https \
        apt-utils \
        curl \
        file \
        gnupg \
        httpie \
        jq \
        libchromaprint-tools \
        libjna-jni \
        openjdk-11-jre-headless \
        p7zip-full \
        p7zip-rar \
        software-properties-common \
        unrar \
        unzip \
        xz-utils \
    && \
    echo "***** add mediainfo repositories ****" && \
    cd /tmp && \
    curl -sSL -OJ https://mediaarea.net/repo/deb/repo-mediaarea_1.0-12_all.deb && \
    dpkg -i repo-mediaarea_1.0-12_all.deb && \
    echo "***** install mediainfo ****" && \
    apt-get update -q && \
    apt-get install -q -y --no-install-recommends \
        libmediainfo0v5 \
    && \
    echo "***** add qbitorrent repositories ****" && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:11371 --recv-keys 7CA69FC4 && \
    apt-add-repository -y -u "http://ppa.launchpad.net/qbittorrent-team/qbittorrent-stable/ubuntu main" && \
    echo "**** install qBittorrent ****" && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -q -y --no-install-recommends \
        qbittorrent-nox="${QBITTORRENT_VER}" \
    && \
    echo "**** add FileBot repository ****" && \
    apt-key adv --fetch-keys https://raw.githubusercontent.com/filebot/plugins/master/gpg/maintainer.pub && \
    echo "deb [arch=amd64] https://get.filebot.net/deb/ stable main" > /etc/apt/sources.list.d/filebot.list && \
    apt-get update -q && \
    echo "**** install FileBot package ****" && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -q -y --no-install-recommends \
        filebot="${FILEBOT_VER}" \
    && \
    echo "**** cleanup ****" && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*

RUN \
    echo "**** add s6 overlay ****" && \
    curl -sSL -o \
        /tmp/s6-overlay.tar.gz \
            "https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VER}/s6-overlay-${S6_OVERLAY_ARCH}.tar.gz" && \
    tar -xzvf \
        /tmp/s6-overlay.tar.gz -C / && \
    echo "**** create abc user ****" && \
    # add group users
    groupmod -g 100 users && \
    # add abc user without shell
    useradd -u 911 -U -d /config -m -s /bin/false abc && \
    # assign users group to abc user
    usermod -G users abc && \
    rm -rf \
        /tmp/*

ENV LANG C.UTF-8
ENV FILEBOT_OPTS "-Dapplication.deployment=docker"

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 6881 6881/udp 8080
VOLUME /config

ENTRYPOINT ["/init"]