#!/bin/bash
source "/root/restic/config.sh"

echo "Linking container backup folder to /root/restic/backup"
LINK_OUTPUT=ln -s "$(docker inspect --format='{{.GraphDriver.Data.MergedDir}}' otnode)/ot-node/backup" restic/
LINK_STATUS=$?
if [ $LINK_STATUS == 1 ]; then
  /root/restic/send.sh "Link container to backup folder command FAILED${n1}$LINK_OUTPUT"
  exit 1
fi


echo "Backing up OriginTrail Node and uploading to S3"
STATUS=$?
N1=$'\n'

echo "Backing up OT Node data"
docker exec otnode node scripts/backup.js --config=/ot-node/.origintrail_noderc --configDir=/ot-node/data --backupDirectory=/ot-node/backup  2>&1
if [ $STATUS == 1 ]; then
  /root/restic/send.sh "Backup command FAILED${n1}$OUTPUT"
  exit 1
fi

echo "Moving data out of dated folder into backup"
MOVE_OUTPUT="mv -v /root/restic/backup/202*/* /root/restic/backup/ 2>&1"
MOVE_STATUS=$?
if [ $MOVE_STATUS == 1 ]; then
  /root/restic/send.sh "Moving data command FAILED${n1}$MOVE_OUTPUT"
  exit 1
fi

echo "Deleting dated folder"
DELETE_OUTPUT="rm -rf /root/restic/backup/202* 2>&1"
DELETE_STATUS=$?
if [ $DELETE_STATUS == 1 ]; then
  /root/restic/send.sh "Deleting data folder command FAILED${n1}$DELETE_OUTPUT"
  exit 1
fi

echo "Uploading data to Amazon S3"
BACKUP_OUTPUT="/root/restic/restic backup /root/restic/backup/*"
BACKUP_STATUS=$?
echo "Notifying backup result with telegram: STATUS=$BACKUP_STATUS"

if [ $BACKUP_STATUS == 0 ]; then
  /root/restic/send.sh "Backup SUCCESSFUL${n1}$BACKUP_OUTPUT"
  rm -rf /root/restic/backup/*
else
  /root/restic/send.sh "Backup FAILED${n1}$BACKUP_OUTPUT"
fi

exit $STATUS
