#!/bin/bash

# Define variables
SOURCE_DIR="/data"
DESTINATION_DIR="/backup"
TARGET_SERVER="remote_user@remote_server"
SSH_KEY="~/.ssh/id_rsa.pub"
LOG_FILE="./logfile.log"

# Function to log messages
log_message() {
    local timestamp=$(date +"%Y-%m-%d %T")
    local hostname=$(hostname)
    local service="backup_script"
    local result="$1"
    echo "$timestamp $hostname $service: $result" >> "$LOG_FILE"
}

# Find the latest backup directory on the target server
latest_backup=$(ssh -i $SSH_KEY $TARGET_SERVER "ls -td $DESTINATION_DIR/*/ | head -n 1")

# Rsync options
RSYNC_OPTIONS="-av --delete --link-dest=$latest_backup --exclude='.git'"

# Perform backup and log the output
log_message "Backup started"
rsync $RSYNC_OPTIONS -e "ssh -i $SSH_KEY" $SOURCE_DIR/ $TARGET_SERVER:$DESTINATION_DIR/$(date +%Y-%m-%d_%H-%M)/ >> "$LOG_FILE" 2>&1
log_message "Backup finished"

# Clean up old backups
ssh -i $SSH_KEY $TARGET_SERVER "find $DESTINATION_DIR -maxdepth 1 -type d -mtime +7 -exec rm -rf {} \;"

log_message "Old backups cleaned up"

