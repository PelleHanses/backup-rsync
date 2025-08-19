#!/bin/bash
# backup_script_local.sh
# Make backup from one folder/disk to another folder/disk locally
# Creates a new folder each time with date and time in the name
# Hard links to older backups to only save new files
# Old backups are deletetd (set with RETENTION_DAYS)
#
# This will give you complete backups every day
# 

# Define variables
SOURCE_DIR="/data"
DESTINATION_DIR="/backup"
LOG_FILE="./logfile.log"
RETENTION_DAYS=31

# Function to log messages
log_message() {
    local timestamp=$(date +"%Y-%m-%d %T")
    local hostname=$(hostname)
    local service="backup_script"
    local result="$1"
    echo "$timestamp $hostname $service: $result" >> "$LOG_FILE"
}

# Create destination directory if it doesn't exist
mkdir -p "$DESTINATION_DIR"

# Find the latest backup directory locally
latest_backup=$(ls -td "$DESTINATION_DIR"/*/ | head -n 1)

# Rsync options
RSYNC_OPTIONS="-a --delete --link-dest=$latest_backup --exclude='.git'"
BACKUP_DIR="$DESTINATION_DIR/$(date +%Y-%m-%d_%H-%M-%S)"

# Perform backup and log the output
log_message "Backup started: $BACKUP_DIR"
rsync $RSYNC_OPTIONS --itemize-changes "$SOURCE_DIR/" "$BACKUP_DIR" 2>&1 | tee >(awk '/^[cd><]/ {print $1, $2}' >> "$LOG_FILE")

# Check if rsync was successful
if [ $? -eq 0 ]; then
    log_message "Backup finished successfully: $BACKUP_DIR"
else
    log_message "Backup failed: $BACKUP_DIR"
    exit 1
fi

# Clean up old backups
log_message "Cleaning up old backups older than $RETENTION_DAYS days"
find "$DESTINATION_DIR" -maxdepth 1 -type d -mtime +$RETENTION_DAYS -exec rm -rf {} \; >> "$LOG_FILE" 2>&1

log_message "Old backups cleaned up"
