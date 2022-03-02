### Build
FROM alpine:latest as build

# Install build dependencies
RUN apk add \
    musl-dev \
    gcc make \
    automake autoconf \
    m4 \
    libevent libevent-dev \
    openssl openssl-dev \
    zlib zlib-dev

WORKDIR /build

RUN apk add git

# Pull latest master
RUN git clone https://gitlab.torproject.org/tpo/core/tor.git
WORKDIR /build/tor

RUN ./autogen.sh
RUN ./configure --disable-asciidoc
RUN make

### Executor
FROM alpine:latest

RUN apk add libevent openssl zlib

WORKDIR /tor
COPY --from=build /build/tor/src/app .

VOLUME ["/etc/torrc"]

ENTRYPOINT ["/tor/tor", "-f", "/etc/torrc"]
