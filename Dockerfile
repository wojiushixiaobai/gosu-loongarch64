FROM golang:1.18-buster

ARG GOSU_VERSION=1.17

ENV GOSU_VERSION=${GOSU_VERSION}

RUN set -ex; \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime; \
    apt-get update; \
    apt-get install -y git file make

RUN set -ex; \
    git clone -b ${GOSU_VERSION} https://github.com/tianon/gosu /opt/gosu

WORKDIR /opt/gosu

ENV GOPROXY=https://goproxy.io \
    CGO_ENABLED=0

RUN set -ex; \
    go mod download -x; \
    go mod vendor

RUN set -ex; \
    mkdir /opt/gosu/dist; \
    GOARCH=loong64 go build -mod=vendor -v -ldflags '-d -s -w' -o /opt/gosu/dist/gosu-$(uname -m); \
    cd /opt/gosu/dist; \
    sha256sum gosu* | tee SHA256SUMS; \
    file gosu*; \
    ls -lFh gosu* SHA256SUMS*

VOLUME /dist

CMD cp -rf dist/* /dist/
