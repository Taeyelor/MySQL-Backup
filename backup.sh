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
