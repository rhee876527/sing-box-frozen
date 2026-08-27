FROM golang:1.26-alpine AS builder
COPY . /go/src/github.com/sagernet/sing-box
WORKDIR /go/src/github.com/sagernet/sing-box
ENV CGO_ENABLED=0
RUN set -ex \
    && apk add git build-base \
    && export COMMIT=$(git rev-parse --short HEAD) \
    && export VERSION=$(go run ./cmd/internal/read_tag) \
    && go build -v -trimpath -tags \
        "with_gvisor,with_dhcp,with_wireguard" \
        -o /go/bin/sing-box \
        -ldflags "-X \"github.com/sagernet/sing-box/constant.Version=$VERSION\" -s -w -buildid=" \
        ./cmd/sing-box
FROM alpine AS dist
RUN set -ex \
    && apk upgrade \
    && apk add bash tzdata ca-certificates nftables \
    && rm -rf /var/cache/apk/*
COPY --from=builder /go/bin/sing-box /usr/local/bin/sing-box
ENTRYPOINT ["sing-box"]
