# SPDX-License-Identifier: AGPL-3.0-only
# SPDX-FileCopyrightText: 2020-2025 Univention GmbH

ARG DOCKER_PROXY
FROM ${DOCKER_PROXY}debian:bookworm-slim AS base

# major.minor.patch with no separators
ARG UCS_VERSION="523"
ARG APT_REPOSITORY="https://updates-test.software-univention.de/"

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

ENV LANG=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -qq update && \
    apt-get -q install --assume-yes --no-install-recommends \
        ca-certificates \
        gnupg

ADD https://updates.software-univention.de/univention-archive-key-ucs-52x.gpg /etc/apt/trusted.gpg.d/ucs-52x.gpg
ADD https://updates.software-univention.de/univention-security.gpg /etc/apt/trusted.gpg.d/univention-security.gpg
ADD https://updates.software-univention.de/univention-support.gpg /etc/apt/trusted.gpg.d/univention-support.gpg

RUN chmod a+r \
    /etc/apt/trusted.gpg.d/ucs-52x.gpg \
    /etc/apt/trusted.gpg.d/univention-security.gpg \
    /etc/apt/trusted.gpg.d/univention-support.gpg

RUN echo 'APT::Sources::Use-Deb822 "1";' >> "/etc/apt/apt.conf.d/docker-clean" && \
    echo "deb ${APT_REPOSITORY} ucs${UCS_VERSION} main" >> /etc/apt/sources.list && \
    echo "deb-src ${APT_REPOSITORY} ucs${UCS_VERSION} main" >> /etc/apt/sources.list && \
    echo "deb ${APT_REPOSITORY} errata${UCS_VERSION} main" >> /etc/apt/sources.list.d/errata.list && \
    echo "deb-src ${APT_REPOSITORY} errata${UCS_VERSION} main" >> /etc/apt/sources.list.d/errata.list && \
    rm -f /etc/apt/sources.list.d/debian.sources && \
    apt-get -q --assume-yes dist-upgrade && \
    apt-get -qq update && \
    apt-get upgrade -y && \
    apt-get -qq install --no-install-recommends \
        tini \
        && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives && \
    apt-get remove -y     ca-certificates     gnupg   && \
    apt-get autoremove -y && \
    find /var '(' -name '*.deb' -o -name '*.log' -o -name '*.log.?z' -o -name '*-old' ')' -delete && \
    mkdir /entrypoint.d

COPY entrypoint.sh /

ENTRYPOINT ["tini", "--", "/entrypoint.sh"]
CMD ["bash"]


FROM base AS final-with-packages
RUN apt-get update


FROM base AS dev

ARG APT_KEY_URL_DEV=http://omar.knut.univention.de/build2/git/key.pub

# hadolint ignore=DL3020
ADD ${APT_KEY_URL_DEV} /etc/apt/trusted.gpg.d/development-key-omar.gpg
RUN chmod a+r /etc/apt/trusted.gpg.d/development-key-omar.gpg

COPY ucs-dev-add-branch.sh /usr/local/bin/

FROM final-with-packages AS final-with-packages-and-python

# We need to keep the package lists to allow reproducible builds downstream
RUN apt-get --assume-yes --verbose-versions --no-install-recommends install python3
