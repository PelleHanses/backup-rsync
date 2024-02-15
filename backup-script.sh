#!/bin/bash

# Define variables
SOURCE_DIR="/data"
DESTINATION_DIR="/backup"
TARGET_SERVER="remote_userpelle@target_server"
SSH_KEY="~/.ssh/id_rsa.pub"

# Rsync options
RSYNC_OPTIONS="-av --delete --link-dest=../$(date -d '1 day ago' +%Y-%m-%d) --exclude='.git'"

# Perform backup
rsync $RSYNC_OPTIONS -e "ssh -i $SSH_KEY" $SOURCE_DIR/ $TARGET_SERVER:$DESTINATION_DIR/$(date +%Y-%m-%d)/

# Clean up old backups
ssh -i $SSH_KEY $TARGET_SERVER "find $DESTINATION_DIR -maxdepth 1 -type d -mtime +7 -exec rm -rf {} \;"

