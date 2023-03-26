#!/bin/bash

source ./.config

echo "Starting backup at $(date +"%Y-%m-%d %H:%M:%S")" >> ./backup.log

# check if host is reachable
ping -c 1 -q $HOST || exit 1

CURRENT_MONTH_NAME=$(date +"%B")

for DOMAIN in ${DOMAINS[@]}; do
    echo "Creating dump file for database ${DATABASES[$DOMAIN]}"
    ssh $USER@$HOST "mysqldump -u $USER -p'$PASSWORD' ${DATABASES[$DOMAIN]} > ~/domains/$DOMAIN/dump.sql"
    echo "Done creating dump file for database ${DATABASES[$DOMAIN]}"

    echo "Copying all files from remote dir to local dir for $DOMAIN"
    BACKUP_DIR=/home/private/Projects/FLINC/backups/$DOMAIN/$CURRENT_MONTH_NAME
    mkdir -p $BACKUP_DIR

    # rsync -azP --delete $USER@$HOST:/home/$USER/domains/$DOMAIN $BACKUP_DIR && echo "Backup completed for $DOMAIN"
    scp -rp $USER@$HOST:/home/$USER/domains/$DOMAIN/ $BACKUP_DIR && echo "Backup completed for $DOMAIN"
done

echo "Backup completed at $(date +"%Y-%m-%d %H:%M:%S")" >> ./backup.log