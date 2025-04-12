# SPDX-License-Identifier: AGPL-3.0-only
# SPDX-FileCopyrightText: 2025 Univention GmbH

FROM golang:1.24 AS build

WORKDIR /app

COPY go.mod go.sum /app/
COPY cmd /app/cmd

RUN \
  go vet -v ./... && \
  go test ./cmd/... -v && \
  CGO_ENABLED=0 GOOS=linux go build ./...

FROM scratch AS final

COPY --from=build /app/loader /bin/
COPY --from=build /app/go.mod /app/go.sum /

USER 1000
WORKDIR /
CMD ["/bin/loader"]
