#!/bin/bash
source "/root/Smoothbrain-OT-Backup/config.sh"
STATUS=$?
N1=$'\n'

rm -rf /root/Smoothbrain-OT-Backup/backup/* /root/Smoothbrain-OT-Backup/backup/.*
echo $STATUS
if [ $STATUS == 1 ]; then
  /root/Smoothbrain-OT-Backup/data/send.sh "Delete backup folder contents FAILED"
  exit 1
fi

echo "Linking container backup folder to /root/Smoothbrain-OT-Backup/backup"
ln -sf "$(docker inspect --format='{{.GraphDriver.Data.MergedDir}}' otnode)/ot-node/backup" /root/Smoothbrain-OT-Backup/
echo $STATUS
if [ $STATUS == 1 ]; then
  /root/Smoothbrain-OT-Backup/data/send.sh "Linking container backup folder command FAILED"
  exit 1
fi


echo "Backing up OT Node data"
docker exec otnode node scripts/backup.js --config=/ot-node/.origintrail_noderc --configDir=/ot-node/data --backupDirectory=/ot-node/backup  2>&1
echo $STATUS
if [ $STATUS == 1 ]; then
  /root/Smoothbrain-OT-Backup/data/send.sh "OT docker backup command FAILED"
  exit 1
fi

echo "Moving data out of dated folder into backup"
mv -v /root/Smoothbrain-OT-Backup/backup/202*/* /root/Smoothbrain-OT-Backup/backup/ 2>&1
echo $STATUS
if [ $STATUS == 1 ]; then
  /root/Smoothbrain-OT-Backup/data/send.sh "Moving data command FAILED"
  exit 1
fi

echo "Moving hidden data out of dated folder into backup"
mv -v /root/Smoothbrain-OT-Backup/backup/.origintrail_noderc /root/Smoothbrain-OT-Backup/backup/ 2>&1
echo $STATUS
if [ $STATUS == 1 ]; then
  /root/Smoothbrain-OT-Backup/data/send.sh "Moving data command FAILED"
  exit 1
fi


echo "Deleting dated folder"
rm -rf /root/Smoothbrain-OT-Backup/backup/202* 2>&1
echo $STATUS
if [ $STATUS == 1 ]; then
  /root/Smoothbrain-OT-Backup/data/send.sh "Deleting data folder command FAILED"
  exit 1
fi

echo "Uploading data to Amazon S3"
/root/Smoothbrain-OT-Backup/restic backup /root/Smoothbrain-OT-Backup/backup/.origintrail_noderc /root/Smoothbrain-OT-Backup/backup/* 2>&1
echo $STATUS
if [ $STATUS == 0 ]; then
  /root/Smoothbrain-OT-Backup/data/send.sh "Backup SUCCESSFUL"
  rm -rf /root/Smoothbrain-OT-Backup/backup/* /root/Smoothbrain-OT-Backup/backup/.*
else
  /root/Smoothbrain-OT-Backup/data/send.sh "Uploading backup to S3 FAILED"
fi

exit $STATUS
