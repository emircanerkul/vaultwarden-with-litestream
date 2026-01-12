
# Start from the official Vaultwarden image
FROM vaultwarden/server:latest

# 1. Download Litestream (using the correct x86_64 file we found)
ADD https://github.com/benbjohnson/litestream/releases/download/v0.5.6/litestream-0.5.6-linux-x86_64.tar.gz /tmp/litestream.tar.gz
RUN tar -C /usr/local/bin -xzf /tmp/litestream.tar.gz

# 2. Configure Litestream
RUN echo 'dbs:' > /etc/litestream.yml && \
    echo '  - path: /data/db.sqlite3' >> /etc/litestream.yml && \
    echo '    replicas:' >> /etc/litestream.yml && \
    echo '      - url: s3://${LITESTREAM_BUCKET}/vaultwarden_db?region=auto&endpoint=${LITESTREAM_ENDPOINT}&force_path_style=true' >> /etc/litestream.yml

# 3. Start Command
CMD ["litestream", "replicate", "-exec", "/vaultwarden"]
