#!/bin/bash

# Define variables
SOURCE_DIR="/data"
DESTINATION_DIR="/backup"
TARGET_SERVER="remote_user@remote_server"
SSH_KEY="~/.ssh/id_rsa.pub"

# Find the latest backup directory on the target server
latest_backup=$(ssh -i $SSH_KEY $TARGET_SERVER "ls -td $DESTINATION_DIR/*/ | head -n 1")

# Rsync options
RSYNC_OPTIONS="-av --delete --link-dest=$latest_backup --exclude='.git'"

# Perform backup
echo RSYNC
echo rsync $RSYNC_OPTIONS -e "ssh -i $SSH_KEY" $SOURCE_DIR/ $TARGET_SERVER:$DESTINATION_DIR/$(date +%Y-%m-%d_%H-%M)/
rsync $RSYNC_OPTIONS -e "ssh -i $SSH_KEY" $SOURCE_DIR/ $TARGET_SERVER:$DESTINATION_DIR/$(date +%Y-%m-%d_%H-%M)/

# Clean up old backups
echo Städar
ssh -i $SSH_KEY $TARGET_SERVER "find $DESTINATION_DIR -maxdepth 1 -type d -mtime +7 -exec rm -rf {} \;"

