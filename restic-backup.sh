#!/bin/bash

source /root/OT-Settings/config.sh
STATUS=$?
N1=$'\n'

if [ -d "/root/backup" ]; then
  echo "Deleting existing backup folder"
  rm -rf /root/backup
fi

ln -s /ot-node/backup /root/backup

cd /ot-node/current

echo "Backing up OT Node data"
OUTPUT=$(node /ot-node/current/scripts/backup.js --config=/ot-node/current/.origintrail_noderc --configDir=/root/.origintrail_noderc/mainnet --backupDirectory=/root/backup 2>&1)
if [ $STATUS -eq 1 ]; then
  /root/OT-Settings/data/send.sh "OT backup command FAILED:${N1}$OUTPUT"
  exit 1
fi

echo "Moving data out of dated folder into backup"
OUTPUT=$(mv -v /root/backup/202*/* /root/backup/ 2>&1)
if [ $STATUS -eq 1 ]; then
  /root/OT-Settings/data/send.sh "Moving data command FAILED::${N1}$OUTPUT"
  exit 1
fi

echo "Moving hidden data out of dated folder into backup"
OUTPUT=$(mv -v /root/backup/*/.origintrail_noderc /root/backup/ 2>&1)
if [ $STATUS -eq 1 ]; then
/root/OT-Settings/data/send.sh "Moving hidden data command FAILED:${N1}$OUTPUT"
exit 1
fi
echo $STATUS

echo "Deleting dated folder"
OUTPUT=$(rm -rf /root/backup/202* 2>&1)
if [ $STATUS -eq 1 ]; then
  /root/OT-Settings/data/send.sh "Deleting data folder command FAILED:${N1}$OUTPUT"
  exit 1
fi
echo $STATUS

echo "Uploading data to Amazon S3"
OUTPUT=$(/root/OT-Smoothbrain-Backup/restic backup /root/backup/.origintrail_noderc /root/backup/* 2>&1)
if [ $STATUS -eq 0 ]; then
if [[ $SMOOTHBRAIN_NOTIFY_ON_SUCCESS == "true" ]]; then
  /root/OT-Settings/data/send.sh "Backup SUCCESSFUL:${N1}$OUTPUT"
  rm -rf /root/backup/* /root/backup/.origintrail_noderc
fi
else
  /root/OT-Settings/data/send.sh "Uploading backup to S3 FAILED:${N1}$OUTPUT"
  exit 1
fi
echo $OUTPUT

exit 0