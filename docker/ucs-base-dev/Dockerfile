ARG UCS_VERSION=504
ARG UCS_BASE_IMAGE=gitregistry.knut.univention.de/univention/customers/dataport/upx/container-ucs-base/ucs-base-${UCS_VERSION}
ARG UCS_BASE_IMAGE_TAG=latest

FROM ${UCS_BASE_IMAGE}:${UCS_BASE_IMAGE_TAG} AS ucs-base-dev

ARG APT_KEY_URL_DEV=http://omar.knut.univention.de/build2/git/key.pub

# hadolint ignore=DL3020
ADD ${APT_KEY_URL_DEV} /etc/apt/trusted.gpg.d/development-key-omar.gpg
RUN chmod a+r /etc/apt/trusted.gpg.d/development-key-omar.gpg

COPY ucs-dev-add-branch.sh /usr/local/bin/
