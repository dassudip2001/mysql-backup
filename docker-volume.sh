#!/bin/bash

# Configuration
BACKUP_DIR="./backup/docker-backup"
LOG_FILE="./log/docker-backup.log"
DATE=$(date +%Y%m%d_%H%M%S)

# Create required directories
mkdir -p "$BACKUP_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Backup function using docker cp
backup_volume() {
    local volume_name=$1
    local temp_container="temp_${volume_name}_${DATE}"
    local backup_path="$BACKUP_DIR/${volume_name}_${DATE}"

    log "Backing up volume: $volume_name to $backup_path"

    # Create a temporary container with the volume mounted
    docker run --name "$temp_container" -v "$volume_name:/data" alpine sleep 1

    if [ $? -eq 0 ]; then
        mkdir -p "$backup_path"
        docker cp "$temp_container:/data/." "$backup_path"
        if [ $? -eq 0 ]; then
            log "Successfully backed up volume: $volume_name to $backup_path"
        else
            log "Failed to copy data from volume: $volume_name"
        fi
    else
        log "Failed to create temporary container for volume: $volume_name"
    fi

    # Clean up the temporary container
    docker rm -f "$temp_container" >/dev/null 2>&1
}

# Main function to back up all volumes
backup_all_volumes() {
    log "Starting backup process for all volumes..."

    local volume_list=$(docker volume ls -q)
    if [[ -z "$volume_list" ]]; then
        log "No Docker volumes found to back up."
        exit 0
    fi

    for volume in $volume_list; do
        backup_volume "$volume"
    done

    log "Backup process completed for all volumes."
}

# Execute the script
backup_all_volumes
