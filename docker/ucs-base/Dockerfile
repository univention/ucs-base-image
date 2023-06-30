ARG DEBIAN_BASE_IMAGE_TAG=buster-slim
ARG DOCKER_PROXY

FROM ${DOCKER_PROXY}debian:${DEBIAN_BASE_IMAGE_TAG} AS ucs-base

ARG APT_KEY_URL=https://updates.software-univention.de/univention-archive-key-ucs-5x.gpg
ARG UCS_VERSION=504

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

WORKDIR /

RUN apt-get --quiet update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get --assume-yes --verbose-versions --no-install-recommends install \
      # Required so that the certificates of https://updates.software-univention.de are
      # trusted.
      ca-certificates=20* \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# hadolint ignore=DL3020
ADD ${APT_KEY_URL} /etc/apt/trusted.gpg.d/univention-archive-key-ucs-5x.gpg
RUN chmod a+r /etc/apt/trusted.gpg.d/univention-archive-key-ucs-5x.gpg

COPY sources-${UCS_VERSION}.list /etc/apt/sources.list.d/15_ucs-online-version.list
