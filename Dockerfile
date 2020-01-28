FROM ubuntu:bionic

# version args
ARG QBITTORRENT_VERSION="4.2.*"
ARG FILEBOT_VERSION="4.8.*"
# version args for s6 overlay
ARG S6_OVERLAY_VERSION="v1.22.1.0"
ARG S6_OVERLAY_ARCH="amd64"

# environment settings
ENV HOME="/config" \
	XDG_CONFIG_HOME="/config" \
	XDG_DATA_HOME="/config" \
    QBITTORRENT_VERSION="${QBITTORRENT_VERSION}" \
    FILEBOT_VERSION="${FILEBOT_VERSION}" \
    S6_OVERLAY_VERSION="${S6_OVERLAY_VERSION}"

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
	apt-add-repository -y -u ppa:qbittorrent-team/qbittorrent-stable && \
	echo "**** install qBittorrent ****" && \
	# if [ -z ${QBITTORRENT_VERSION+x} ]; then \
	# 	QBITTORRENT_VERSION=$(curl -sX GET http://ppa.launchpad.net/qbittorrent-team/qbittorrent-stable/ubuntu/dists/bionic/main/binary-amd64/Packages.gz | gunzip -c \
	# 	| grep -A 7 -m 1 "Package: qbittorrent-nox" | awk -F ": " '/Version/{print $2;exit}');\
	# fi && \
	DEBIAN_FRONTEND=noninteractive \
    apt-get install -q -y --no-install-recommends \
		qbittorrent-nox="${QBITTORRENT_VERSION}" \
		unrar \
    && \
	echo "**** add FileBot repository ****" && \
    apt-key adv --fetch-keys https://raw.githubusercontent.com/filebot/plugins/master/gpg/maintainer.pub && \
    echo "deb [arch=amd64] https://get.filebot.net/deb/ stable main" > /etc/apt/sources.list.d/filebot.list && \
    apt-get update -q && \
    echo "**** install FileBot package ****" && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        filebot="${FILEBOT_VERSION}" \
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
            "https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-${S6_OVERLAY_ARCH}.tar.gz" && \
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