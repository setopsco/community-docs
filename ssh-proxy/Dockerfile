FROM alpine:3.14
RUN apk add --update openssh bash && \
    rm -rf /var/cache/apk/* && \
    adduser -u 1000 -g 1000 -D -s /sbin/nologin proxy && \
    mkdir /app
WORKDIR /app
COPY sshd_config /
COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
