#/bin/sh 
# Script to create a ziped dump of data-folders, Idea taken from https://www.laub-home.de/wiki/Docker_Backup_und_Restore_-_eine_kleine_Anleitung
# Created by Jan Macenka @ 25.08.2022
# Best before: Do not use this Script beyond 25.08.2025 as it will not revieve Support after that point.

# General variables
timestamp=$(date +%Y%m%d%H%M%S)
application_location="/path/to/installation/location" # NEEDS MANUAL EDITING
backup_location="/path/to/backup/location" # NEEDS MANUAL EDITING

# For NextCloud-Upload
# Prerequisite is CURL available on your system
backup_nextcloud_user=""  # NEEDS MANUAL EDITING
backup_nextcloud_password=""  # NEEDS MANUAL EDITING
backup_nextcloud_url="https://<your-nextcloud-url>/remote.php/webdav/<folder-location-in-nextcloud>" # NEEDS MANUAL EDITING

echo "********************************"
echo "Executing the Backup-Script for NetBox"
echo "********************************"

echo "NOW: Ensuring the backup location exists..."
mkdir -p $backup_location

echo "NOW: Stopping all containers related to NetBox..."
docker stop $(docker ps -aq -f name=netbox)

echo "NOW: Backuping media files..."
docker run --rm \
        -v netbox-docker_netbox-media-files:/data:ro \
        -v $backup_location:/backup \
        debian:stretch-slim bash -c "mkdir -p /backup/$ && cd /data && /bin/tar -czvf /backup/media_backup.tar.gz .";

echo "NOW: Backuping postgres state..."
docker run --rm \
        -v netbox-docker_netbox-postgres-data:/data:ro \
        -v $backup_location:/backup \
        debian:stretch-slim bash -c "mkdir -p /backup/$ && cd /data && /bin/tar -czvf /backup/postgres_backup.tar.gz .";
        
echo "NOW: Backuping redis state..."
docker run --rm \
        -v netbox-docker_netbox-redis-data:/data:ro \
        -v $backup_location:/backup \
        debian:stretch-slim bash -c "mkdir -p /backup/$ && cd /data && /bin/tar -czvf /backup/redis_backup.tar.gz .";

echo "NOTE: Please be aware that this backup resides on your server/machine, please manually take care to also store backups outside this machine!"

# Activate the next section if you want to upload your backups to a nextcloud-location. Make sure you have a user dedicated for only this job with access to the required folders.

#echo "NOW: Pushing backups to the cloud..."
#for file in "media_backup.tar.gz" "postgres_backup.tar.gz" "redis_backup.tar.gz"
#do
#        echo "NOW: Uploading $file to $backup_nextcloud_url"
#        curl -k -u "$backup_nextcloud_user:$backup_nextcloud_password" -T "$backup_location/$file" "$backup_nextcloud_url/"$timestamp"_$file"
#done

echo "NOW: Restarting all containers related to NetBox..."
docker restart $(docker ps -aq -f name=netbox)

echo "DONE: Backup-Job done..."