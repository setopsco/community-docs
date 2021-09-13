FROM graylog/graylog:4.1

USER 0

# Adjust entrypoint script to use SetOps internal hostname for node to node communication
RUN head -n-1 /docker-entrypoint.sh > /tmp/docker-entrypoint.sh && \
    echo "export GRAYLOG_HTTP_PUBLISH_URI=http://\$HOSTNAME:9000" >> /tmp/docker-entrypoint.sh && \
    tail -n1 /docker-entrypoint.sh >> /tmp/docker-entrypoint.sh && \
    mv /tmp/docker-entrypoint.sh /docker-entrypoint.sh && \
    chmod 0755 /docker-entrypoint.sh

USER $GRAYLOG_USER
