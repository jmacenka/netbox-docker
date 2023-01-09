#/bin/sh 
# Script to create a ziped dump of data-folders, Idea taken from https://www.laub-home.de/wiki/Docker_Backup_und_Restore_-_eine_kleine_Anleitung
# Created by Jan Macenka @ 25.08.2022
# Best before: Do not use this Script beyond 25.08.2025 as it will not revieve Support after that point.

echo "********************************"
echo "Executing the Backup-Script for NetBox"
echo "********************************"

echo "NOW: Starting Backup-Job for NetBox..."
timestamp=$(date +%Y%m%d_%H%M%S)
application_location="/path/to/application/directory" # Provide the path to your application directory

echo "NOW: Stopping all containers related to NetBox..."
docker stop $(docker ps -aq -f name=netbox)

echo "NOW: Backuping media files..."
docker run --rm \
        -v $application_location/data/media:/data:ro \
        -v $application_location/data/backup:/backup \
        debian:stretch-slim bash -c "mkdir -p /backup/$timestamp/ && cd /data && /bin/tar -czvf /backup/$timestamp/media_backup.tar.gz ."

echo "NOW: Backuping postgres state..."
docker run --rm \
        -v $application_location/data/postgres:/data:ro \
        -v $application_location/data/backup:/backup \
        debian:stretch-slim bash -c "mkdir -p /backup/$timestamp/ && cd /data && /bin/tar -czvf /backup/$timestamp/postgres_backup.tar.gz ."
        
echo "NOW: Backuping redis state..."
docker run --rm \
        -v $application_location/data/redis:/data:ro \
        -v $application_location/data/backup:/backup \
        debian:stretch-slim bash -c "mkdir -p /backup/$timestamp/ && cd /data && /bin/tar -czvf /backup/$timestamp/redis_backup.tar.gz ."

echo "NOW: Restarting all containers related to NetBox..."
docker restart $(docker ps -aq -f name=netbox)

echo "DONE: Backup-Job done..."
echo "NOTE: Please be aware that this backup resides on your server/machine, please manually take care to also store backups outside this machine!"