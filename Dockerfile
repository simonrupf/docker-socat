FROM alpine:3.19

RUN \
    apk upgrade --no-cache && \
    apk add --no-cache \
        libcap \
        socat \
    && \
    setcap 'cap_net_bind_service=+ep' /usr/bin/socat && \
    mkdir -p /srv/bin /srv/usr/lib /srv/lib && \
    for SO in $(ldd /usr/bin/socat | awk '{print $3}') ; \
    do \
        cp $SO /srv$SO ; \
    done && \
    mv /usr/bin/socat /srv/bin/socat

FROM scratch
LABEL org.opencontainers.image.authors="Simon Rupf <simon@rupf.net>" \
      org.opencontainers.image.source=https://github.com/simonrupf/docker-socat \
      org.opencontainers.image.version="${VERSION}"
COPY --from=0 /srv/ /
USER 255:255
ENTRYPOINT ["/bin/socat"]
