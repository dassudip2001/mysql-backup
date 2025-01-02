#!/bin/bash

# Constants
CONTAINER_NAME="mysql"             # Name of the MySQL container
MYSQL_USER="root"                  # MySQL username
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-"root"}  # MySQL root password (use env variable)
BACKUP_DIR="./backup"              # Directory for storing backups
TIMESTAMP=$(date +"%Y%m%d_%H%M%S") # Timestamp for backup file
DATABASES=("diya" "drowing_site" ) # List of databases to back up

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# Backup each database
for MYSQL_DATABASE in "${DATABASES[@]}"; do
    BACKUP_FILE="$BACKUP_DIR/mysql-backup-$MYSQL_DATABASE-$TIMESTAMP.sql.gz"
    echo "Starting backup for database: $MYSQL_DATABASE"
    log "Starting backup for database: $MYSQL_DATABASE"
    
    docker exec -i "$CONTAINER_NAME" mysqldump -u"$MYSQL_USER" -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE" | gzip > "$BACKUP_FILE"
    
    if [ $? -eq 0 ]; then
        echo "Backup successful: $BACKUP_FILE"
        log "Backup successful: $BACKUP_FILE"
    else
        echo "Backup failed for database: $MYSQL_DATABASE"
        log "Backup failed for database: $MYSQL_DATABASE"
        continue
    fi
done

# Optional: Remove old backups (keep the last 7 backups)
echo "Cleaning up old backups..."
log "Cleaning up old backups..."
find "$BACKUP_DIR" -type f -name "*.sql.gz" -mtime +7 -exec rm {} \;

echo "All backups completed successfully."
log "All backups completed successfully."
