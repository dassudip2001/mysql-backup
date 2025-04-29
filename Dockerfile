FROM alpine

# Install MySQL client and utilities
RUN apt-get update && apt-get install -y \
    mysql-client \
    gzip \
    cron && \
    apt-get clean

# Add the backup script to the container
COPY mysql-docker-backup.sh /usr/local/bin/mysql-docker-backup.sh
RUN chmod +x /usr/local/bin/mysql-docker-backup.sh

# Schedule the backup script in cron
RUN echo "0 2 * * * /usr/local/bin/mysql-backup.sh >> /var/log/cron.log 2>&1" > /etc/cron.d/mysql-docker-backup \
    && chmod 0644 /etc/cron.d/mysql-docker-backup \
    && crontab /etc/cron.d/mysql-docker-backup

# Start cron in the foreground
CMD ["cron", "-f"]
