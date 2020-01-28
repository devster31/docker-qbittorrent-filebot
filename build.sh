#!/bin/bash -x

echo "${QBITTORRENT_VERSION}" "${FILEBOT_VERSION}" "${S6_OVERLAY_VERSION}"

declare -a BUILD_ARGS

[ -n "${QBITTORRENT_VERSION}" ] && \
    BUILD_ARGS+=("--build-arg" "QBITTORRENT_VERSION=${QBITTORRENT_VERSION}")

[ -n "${FILEBOT_VERSION}" ] && \
    BUILD_ARGS+=("--build-arg" "FILEBOT_VERSION=${FILEBOT_VERSION}")

[ -n "${S6_OVERLAY_VERSION}" ] && \
    BUILD_ARGS+=("--build-arg" "S6_OVERLAY_VERSION=${S6_OVERLAY_VERSION}")

docker build "${BUILD_ARGS[@]}" --tag devster31/qbittorrent-filebot .