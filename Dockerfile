FROM alpine:3.22

RUN \
    apk upgrade --no-cache && \
    apk add --no-cache \
        libcap \
        socat \
    && \
    mkdir -p /srv/bin /srv/usr/lib /srv/lib && \
    mv /usr/bin/socat1 /srv/bin/socat && \
    setcap 'cap_net_bind_service=+ep' /srv/bin/socat && \
    for SO in $(ldd /srv/bin/socat | awk '{print $3}') ; \
    do \
        cp $SO /srv$SO ; \
    done

FROM scratch
LABEL org.opencontainers.image.authors="Simon Rupf <simon@rupf.net>" \
      org.opencontainers.image.source=https://github.com/simonrupf/docker-socat \
      org.opencontainers.image.version="${VERSION}"
COPY --from=0 /srv/ /
USER 255:255
ENTRYPOINT ["/bin/socat"]
