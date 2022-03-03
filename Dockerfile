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
    zlib zlib-dev \
    zstd zstd-dev

WORKDIR /build

RUN apk add git

# Pull latest master
RUN git clone https://gitlab.torproject.org/tpo/core/tor.git
WORKDIR /build/tor

# Switch to the latest stable tagged release
COPY checkout-latest-stable.sh .
RUN chmod +x checkout-latest-stable.sh
RUN ./checkout-latest-stable.sh

# Build it
RUN ./autogen.sh
RUN ./configure --disable-asciidoc
RUN make -j$(nproc)

### Executor
FROM alpine:latest

# Install runtime dependencies
RUN apk add libevent openssl zlib zstd-libs bash

# Copy binary over
WORKDIR /tor
COPY --from=build /build/tor/src/app .

# Get our entrypoint
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# The user can add *.sh scripts here to have them run before Tor starts
# Useful for bootstrapping the config file at /etc/torrc
VOLUME ["/scripts"]

ENTRYPOINT ["/tor/entrypoint.sh"]
