FROM alpine:3.13

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
COPY --from=0 /srv/ /
USER 255:255
ENTRYPOINT ["/bin/socat"]
