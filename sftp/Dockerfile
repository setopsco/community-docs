FROM alpine:3.14
RUN apk add --update openssh bash shadow && \
    rm -rf /var/cache/apk/* && \
    adduser -u 1000 -g 1000 -D -s /sbin/nologin data && \
    usermod -p '*' data && \
    mkdir /app
WORKDIR /app
COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
