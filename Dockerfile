FROM cr.loongnix.cn/loongson/loongnix:20

ARG GOSU_VERSION=1.14

ENV GOSU_VERSION=${COMPOSE_VERSION}

RUN set -ex; \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime; \
    apt-get update; \
    apt-get install -y golang-1.18 git file make

RUN set -ex; \
    git clone -b ${GOSU_VERSION} https://github.com/tianon/gosu /opt/gosu

WORKDIR /opt/gosu

ENV GOPROXY=https://goproxy.io \
    CGO_ENABLED=0 \
    PATH=/usr/lib/go-1.18/bin:$PATH

RUN set -ex; \
    go mod download -x; \
    go mod tidy; \
    go mod vendor; \
    sed -i 's@s390x@s390x loong64@g' vendor/github.com/opencontainers/runc/libcontainer/system/syscall_linux_64.go; \
    cp -rf /usr/lib/go-1.18/src/cmd/vendor/golang.org/x/sys/unix vendor/golang.org/x/sys/

RUN set -ex; \
    mkdir /opt/gosu/dist; \
    GOARCH=loong64 go build -mod=vendor -v -ldflags '-d -s -w' -o /opt/gosu/dist/gosu-$(uname -m); \
    cd /opt/gosu/dist; \
    sha256sum gosu* | tee SHA256SUMS; \
    file gosu*; \
    ls -lFh gosu* SHA256SUMS*

VOLUME /dist

CMD cp -rf dist/* /dist/
