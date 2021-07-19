#!/bin/bash

source "/root/OT-Settings/config.sh"
STATUS=$?
N1=$'\n'

rm -rf /root/backup/* /root/backup/.origintrail_noderc
echo $STATUS
if [ $STATUS == 1 ]; then
  /root/OT-Settings/data/send.sh "Delete backup folder contents FAILED"
  exit 1
fi

echo "Linking container backup folder to /root/backup"
ln -sf "$(docker inspect --format='{{.GraphDriver.Data.MergedDir}}' otnode3)/ot-node/backup" /root/backup
echo $STATUS
if [ $STATUS == 1 ]; then
  /root/OT-Settings/data/send.sh "Linking container backup folder command FAILED"
  exit 1
fi


echo "Backing up OT Node data"
docker exec otnode node scripts/backup.js --config=/ot-node/.origintrail_noderc --configDir=/ot-node/data --backupDirectory=/ot-node/backup  2>&1
echo $?
if [ $? == 1 ]; then
  /root/OT-Settings/data/send.sh "OT docker backup command FAILED"
  exit 1
fi

echo "Moving data out of dated folder into backup"
mv -v /root/backup/backup/202*/* /root/backup/ 2>&1
echo $?
if [ $? == 1 ]; then
  /root/OT-Settings/data/send.sh "Moving data command FAILED"
  exit 1
fi

echo "Moving hidden data out of dated folder into backup"
mv -v /root/backup/backup/*/.origintrail_noderc /root/backup/ 2>&1
echo $?
if [ $? == 1 ]; then
  /root/OT-Settings/data/send.sh "Moving hidden data command FAILED"
  exit 1
fi


echo "Deleting dated folder"
rm -rf /root/backup/backup 2>&1
echo $?
if [ $? == 1 ]; then
  /root/OT-Settings/data/send.sh "Deleting data folder command FAILED"
  exit 1
fi

echo "Uploading data to Amazon S3"
OUTPUT=$(/root/OT-Smoothbrain-Backup/restic backup --tag otnode31 /root/backup/.origintrail_noderc /root/backup/* 2>&1)
echo $OUTPUT
if [ $? -eq 0 ]; then
  /root/OT-Settings/data/send.sh "Backup SUCCESSFUL:${N1}$OUTPUT"
  rm -rf /root/backup/* /root/backup/.origintrail_noderc
else
  /root/OT-Settings/data/send.sh "Uploading backup to S3 FAILED:${N1}$OUTPUT"
  exit 1
fi

exit 0