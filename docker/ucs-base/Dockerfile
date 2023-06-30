ARG DEBIAN_BASE_IMAGE_TAG=buster-slim
ARG DOCKER_PROXY

FROM ${DOCKER_PROXY}debian:${DEBIAN_BASE_IMAGE_TAG} AS ucs-base

ARG APT_KEY_URL=https://updates.software-univention.de/univention-archive-key-ucs-5x.gpg
ARG UCS_VERSION=504

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

WORKDIR /

RUN \
    apt-get --quiet update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get --assume-yes --verbose-versions --no-install-recommends install \
    ca-certificates=20* \
    curl=7.64.* \
    gpg=2.2.* \
    gpg-agent=2.2.* \
    patch=2.7.* && \
    curl -fsSL "${APT_KEY_URL}" | apt-key add - && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

COPY sources-${UCS_VERSION}.list /etc/apt/sources.list.d/15_ucs-online-version.list
