# Like what you see? Join us!
# https://www.univention.com/about-us/careers/vacancies/
#
# Copyright 2020-2023 Univention GmbH
#
# https://www.univention.de/
#
# All rights reserved.
#
# The source code of this program is made available
# under the terms of the GNU Affero General Public License version 3
# (GNU AGPL V3) as published by the Free Software Foundation.
#
# Binary versions of this program provided by Univention to you as
# well as other copyrighted, protected or trademarked materials like
# Logos, graphics, fonts, specific documentations and configurations,
# cryptographic keys etc. are subject to a license agreement between
# you and Univention and not subject to the GNU AGPL V3.
#
# In the case you use this program under the terms of the GNU AGPL V3,
# the program is provided in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public
# License with the Debian GNU/Linux or Univention distribution in file
# /usr/share/common-licenses/AGPL-3; if not, see
# <https://www.gnu.org/licenses/>.
#

ARG DOCKER_PROXY
FROM ${DOCKER_PROXY}debian:bookworm-slim AS builder

# major.minor.patch with no separators
ARG UCS_VERSION="506"
ARG APT_REPOSITORY="https://updates.software-univention.de/"

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

RUN apt-get -qq update && apt-get -q install --assume-yes --no-install-recommends debootstrap findutils
RUN sed -e '/required=/s/ usr-is-merged//' -i /usr/share/debootstrap/scripts/debian-common

#  hadliont ignore=DL3059
RUN debootstrap \
    --no-check-gpg \
    --no-check-certificate \
    --no-merged-usr \
    --variant='minbase' \
    --include='univention-archive-key' \
    "ucs${UCS_VERSION}" \
    /work \
    "${APT_REPOSITORY}" \
    "/usr/share/debootstrap/scripts/bookworm"

# NOTE: No layers are optimized below due to starting from scratch the final image
# causing all layers to be lost before that.

# Package installs happen during `docker build`, which gets restarted clean
# after power loss and every build. This speeds up apt, specially on spinning
# disks.
RUN echo 'force-unsafe-io' > "/work/etc/dpkg/dpkg.cfg.d/docker-apt-speedup"

# We don't need translations in docker images, since it wastes time and space.
# If needed, remove the file and run `apt-get update` to get them.
RUN echo 'Acquire::Languages "none";' > "/work/etc/apt/apt.conf.d/docker-no-languages"

# Request the `gz` index files for smaller images.
RUN echo 'Acquire::GzipIndexes "true";' > "/work/etc/apt/apt.conf.d/docker-gzip-indexes" && \
    echo 'Acquire::CompressionTypes::Order:: "gz";' >> "/work/etc/apt/apt.conf.d/docker-gzip-indexes"

# Remove the apt cache to make the image smaller by making the apt-get install
# layers smaller.
RUN \
    echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > "/work/etc/apt/apt.conf.d/docker-clean" && \
    echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' >> "/work/etc/apt/apt.conf.d/docker-clean" && \
    echo 'APT::Install-Recommends "0";' >> "/work/etc/apt/apt.conf.d/docker-clean" && \
    echo 'APT::Install-Suggests "0";' >> "/work/etc/apt/apt.conf.d/docker-clean" && \
    echo 'Dir::Cache::pkgcache "";' >> "/work/etc/apt/apt.conf.d/docker-clean" && \
    echo 'Dir::Cache::srcpkgcache "";' >> "/work/etc/apt/apt.conf.d/docker-clean"


# apt aggressive about removing packages added when the package that sugested
# another package is removed.
RUN echo 'Apt::AutoRemove::SuggestsImportant "false";' > "/work/etc/apt/apt.conf.d/docker-autoremove-suggests"

RUN \
    echo "deb-src ${APT_REPOSITORY} ucs${UCS_VERSION} main" >> /work/etc/apt/sources.list && \
    echo "deb ${APT_REPOSITORY} errata${UCS_VERSION} main" >> /work/etc/apt/sources.list.d/errata.list && \
    echo "deb-src ${APT_REPOSITORY} errata${UCS_VERSION} main" >> /work/etc/apt/sources.list.d/errata.list

RUN chroot /work apt-get -qq update
RUN chroot /work apt-get -q --assume-yes dist-upgrade
RUN rm -rf /work/var/lib/apt/lists/* /work/var/cache/apt/archives
RUN find /work/var '(' -name '*.deb' -o -name '*.log' -o -name '*.log.?z' -o -name '*-old' ')' -delete

RUN rm -rf /work/dev; \
    rm -rf /work/sys; \
    rm -rf /work/proc;

FROM scratch as final
COPY --from=builder /work /

ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

RUN mkdir /entrypoint.d
COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]


FROM final as final-with-packages
RUN apt-get update


FROM final as dev

ARG APT_KEY_URL_DEV=http://omar.knut.univention.de/build2/git/key.pub

# hadolint ignore=DL3020
ADD ${APT_KEY_URL_DEV} /etc/apt/trusted.gpg.d/development-key-omar.gpg
RUN chmod a+r /etc/apt/trusted.gpg.d/development-key-omar.gpg

COPY ucs-dev-add-branch.sh /usr/local/bin/
