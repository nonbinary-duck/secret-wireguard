FROM lscr.io/linuxserver/wireguard:latest

ARG UDP2RAW_REPO=https://github.com/wangyu-/udp2raw-tunnel.git
ARG UDP2RAW_REF=unified
ARG UDPSPEEDER_REPO=https://github.com/wangyu-/UDPspeeder.git
ARG UDPSPEEDER_REF=branch_libev

RUN apk add --no-cache \
    git \
    build-base \
    linux-headers \
    bash \
    libcap-utils \
    iptables \
    iproute2 \
    procps \
    coreutils \
    grep \
    sed

WORKDIR /tmp

RUN git clone --depth 1 --branch "${UDP2RAW_REF}" "${UDP2RAW_REPO}" udp2raw-tunnel \
    && cd udp2raw-tunnel \
    && make \
    && install -m 0755 udp2raw /usr/local/bin/udp2raw \
    && rm -rf /tmp/udp2raw-tunnel

RUN git clone --depth 1 --branch "${UDPSPEEDER_REF}" "${UDPSPEEDER_REPO}" UDPspeeder \
    && cd UDPspeeder \
    && make \
    && install -m 0755 speederv2 /usr/local/bin/speederv2 \
    && rm -rf /tmp/UDPspeeder

COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY scripts/parse-udpspeeder-conf.sh /usr/local/bin/parse-udpspeeder-conf.sh
COPY scripts/run-server.sh /usr/local/bin/run-server.sh
COPY scripts/run-client.sh /usr/local/bin/run-client.sh

RUN chmod +x \
    /usr/local/bin/entrypoint.sh \
    /usr/local/bin/parse-udpspeeder-conf.sh \
    /usr/local/bin/run-server.sh \
    /usr/local/bin/run-client.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]