#!/bin/bash

## Define your config 
## For example username, password, ip address for remote connection and database name, username, password for connect to your database

source ./config.cfg

## Starting backup
## Create backup file then zip it and send it to remote server with scp
echo "Starting Backup ..."

current_time="$(date +%Y_%m_%d_%H_%M_%S)"

mysqldump -u "$DATABASE_USERNAME" --password="$DATABASE_PASSWORD" --host="$DATABASE_SERVER" --default-character-set="utf8" $DATABASE_NAME > "$current_time".sql
zip "$current_time".zip "$current_time".sql
rm -rf "$current_time".sql

echo "Backup Completed ."
if [ "$REMOTE_ACTIVE" == "yes" ]
then
    echo "Connecting To Remote Server ..."
    sshpass -p "$REMOTE_PASSWORD" scp "$current_time".zip "$REMOTE_USERNAME"@"$REMOTE_IP_ADDRESS":"$REMOTE_DIRECTORY"
    echo "Transmission Completed ."
fi


## Restore backup file on remote server
if [ "$REMOTE_RESTORE" == "yes" ]
then
    echo "Restoring database ..."
    sshpass -p "$REMOTE_PASSWORD" ssh "$REMOTE_USERNAME"@"$REMOTE_IP_ADDRESS" "cd \"$REMOTE_DIRECTORY\"; unzip \"$current_time\".zip; mysql --user=\"$REMOTE_DATABASE_USERNAME\" --password=\"$REMOTE_DATABASE_PASSWORD\" --database=\"$REMOTE_DATABASE_NAME\" < \"$current_time\".sql; rm -rf \"$current_time\".sql"
    echo "Restored ."
fi

## Remove old backups from local
if [ "$AUTO_OLD_BACKUP_LOCAL_REMOVE" == "yes" ]
then
    echo "Removing old backups from local ..."
    DAY=$(date --date="7 days ago" +%Y_%m_%d)
    while [ -n "$(ls "$DAY"_*)" ]; do
        echo "$LOCAL_DAYS_AGO day(s) ago : $DAY"
        rm -rf "$DAY"_*.zip
        LOCAL_DAYS_AGO=$((LOCAL_DAYS_AGO+1))
        DAY=$(date --date="$LOCAL_DAYS_AGO days ago" +%Y_%m_%d)
    done
    echo "Old backups removed from local ."
fi


## Remove old backups from remote
if [ "$AUTO_OLD_BACKUP_REMOTE_REMOVE" == "yes" ]
then
    echo "Removing old backups from remote ..."
    DAY=$(date --date="7 days ago" +%Y_%m_%d)
    while [ -n "$(sshpass -p "$REMOTE_PASSWORD" ssh "$REMOTE_USERNAME"@"$REMOTE_IP_ADDRESS" "cd \"$REMOTE_DIRECTORY\"; ls \"$DAY\"_*")" ]; do
        echo "$REMOTE_DAYS_AGO day(s) ago : $DAY"
        sshpass -p "$REMOTE_PASSWORD" ssh "$REMOTE_USERNAME"@"$REMOTE_IP_ADDRESS" "cd \"$REMOTE_DIRECTORY\"; rm -rf "$DAY"_*.zip"
        REMOTE_DAYS_AGO=$((REMOTE_DAYS_AGO+1))
        DAY=$(date --date="$REMOTE_DAYS_AGO days ago" +%Y_%m_%d)
    done
    echo "Old backups removed from remote ."
fi

