FROM ubuntu/bind9

ARG BUILD_DATE="UNKNOWN"
ARG SOURCE_COMMIT="UNKNOWN"
ARG TIMEZONE="UTC"

ENV LANG=en_US.UTF-8

EXPOSE 53/udp 53/tcp 67/udp 68/udp 547/udp 953/tcp 10000/tcp

RUN if [ -z "$BUILD_DATE" ]; then export BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ'); fi

LABEL org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.description="BIND9, KEA, and STORK Agent by Internet Systems Consortium" \
      org.opencontainers.image.ref.name="dudleycodes/bindlease" \
      org.opencontainers.image.source="https://github.com/dudleycodes/bindlease" \
      org.opencontainers.image.version=$SOURCE_COMMIT

RUN apt-get update &&\
        apt-get install -y --no-install-recommends --no-install-suggests \
            apt-transport-https ca-certificates curl expect gnupg tini &&\
    # Kea
        apt-get install -y --no-install-recommends --no-install-suggests kea &&\
    # Stork
    curl -1sLf  'https://dl.cloudsmith.io/public/isc/stork/setup.deb.sh' | bash &&\
        apt-get update &&\
        apt-get install -y isc-stork-agent &&\
    # Timezone
    if [ ! -f "/usr/share/zoneinfo/${TIMEZONE}" ]; then echo "ERROR: Invalid timezone: ${TIMEZONE}" && exit 87; fi &&\
    ln -fs /usr/share/zoneinfo/$TIMEZONE /etc/localtime &&\
    dpkg-reconfigure --frontend noninteractive tzdata &&\
    # Clean up
    apt-get remove -y curl &&\
    apt-get autoremove -y &&\
    apt-get clean &&\
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

COPY start_services.sh /start_services.sh

# Environment
RUN echo 'statistics-channels { inet * port * allow { 127.0.0.1; }; };' | tee -a /etc/bind/named.conf &&\
    chmod +x /start_services.sh &&\
    usermod -l bindlease bind;

USER bindlease

ENTRYPOINT ["/usr/bin/tini", "--", "/start_services.sh"]

ONBUILD USER root
