#!/bin/bash
source "/root/OT-Smoothbrain-Backup/config.sh"
STATUS=$?
N1=$'\n'

rm -rf /root/OT-Smoothbrain-Backup/backup/* /root/OT-Smoothbrain-Backup/backup/.origintrail_noderc
echo $STATUS
if [ $STATUS == 1 ]; then
  /root/OT-Smoothbrain-Backup/data/send.sh "Delete backup folder contents FAILED"
  exit 1
fi

echo "Stopping otnode"
docker stop otnode

echo "Copying arangodb3 data to /root/backup"
docker cp otnode:../var/lib/arangodb3 /root/backup
echo $?
if [ $? == 1 ]; then
  /root/OT-Smoothbrain-Backup/data/send.sh "OT docker arangodb3 copy FAILED"
  exit 1
  echo "Starting otnode"
  docker start otnode
fi

echo "Copying arangodb3-apps data to /root/backup"
docker cp otnode:../var/lib/arangodb3-apps /root/backup
echo $?
if [ $? == 1 ]; then
  /root/OT-Smoothbrain-Backup/data/send.sh "OT docker arangodb3-apps copy FAILED"
  exit 1
  echo "Starting otnode"
  docker start otnode
fi

echo "Copying /data to /root/backup"
docker cp otnode:../data /root/backup
echo $?
if [ $? == 1 ]; then
  /root/OT-Smoothbrain-Backup/data/send.sh "OT docker data copy FAILED"
  exit 1
  echo "Starting otnode"
  docker start otnode
fi

echo "Starting otnode"
docker start otnode

echo "Uploading data to Amazon S3"
OUTPUT=$(/root/OT-Smoothbrain-Backup/restic backup /root/backup/.origintrail_noderc /root/backup/data /root/backup/arangodb3 /root/backup/arangodb3-apps 2>&1)
echo $OUTPUT
if [ $? -eq 0 ]; then
  /root/OT-Smoothbrain-Backup/data/send.sh "Backup SUCCESSFUL:${N1}$OUTPUT"
  rm -rf /root/backup/* /root/backup/.origintrail_noderc
else
  /root/OT-Smoothbrain-Backup/data/send.sh "Uploading backup to S3 FAILED:${N1}$OUTPUT"
  exit 1
fi

exit 0
