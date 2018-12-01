#!/bin/bash

## Define your config 
## For example username, password, ip address for remote connection and database name, username, password for connect to your database

DATABASE_NAME=""
DATABASE_USERNAME=""
DATABASE_PASSWORD=""
DATABASE_SERVER=""

REMOTE_IP_ADDRESS=""
REMOTE_USERNAME=""
REMOTE_PASSWORD=""
REMOTE_DIRECTORY=""

REMOTE_DATABASE_NAME=""
REMOTE_DATABASE_USERNAME=""
REMOTE_DATABASE_PASSWORD=""

## Starting backup
## Create backup file then zip it and send it to remote server with scp
echo "Starting Backup ..."

current_time="$(date +%Y_%m_%d_%H_%M_%S)"

mysqldump -u "$DATABASE_USERNAME" --password="$DATABASE_PASSWORD" --host="$DATABASE_SERVER" --default-character-set="utf8" $DATABASE_NAME > "$current_time".sql
zip "$current_time".zip "$current_time".sql
rm -rf "$current_time".sql

echo "Backup Completed ."
echo "Connecting To Remote Server ..."

sshpass -p "$REMOTE_PASSWORD" scp "$current_time".zip "$REMOTE_USERNAME"@"$REMOTE_IP_ADDRESS":"$REMOTE_DIRECTORY"

echo "Transmission Completed ."

## Restore backup file on remote server
## If bash run with --remote-restore option
if [ $1 == "--remote-restore" ]
then
    echo "Restoring database ..."
    sshpass -p "$REMOTE_PASSWORD" ssh "$REMOTE_USERNAME"@"$REMOTE_IP_ADDRESS" "cd \"$REMOTE_DIRECTORY\"; unzip \"$current_time\".zip; mysql --user=\"$REMOTE_DATABASE_USERNAME\" --password=\"$REMOTE_DATABASE_PASSWORD\" --database=\"$REMOTE_DATABASE_NAME\" < \"$current_time\".sql"
    echo "Restored ."
fi
