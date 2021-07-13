#!/bin/bash

# Initial version of ColdBrain Backup!
# This will stop the node and then the arangodb server, backup any changed data directly from the arango folder, and then restart arango, and then the node.
# The initial backup will take some time!

source "/root/OT-Settings/config.sh"
STATUS=$?
N1=$'\n'

echo "Stopping otnode"
systemctl stop otnode

echo "Stopping arangodb3"
systemctl stop arangodb3

echo "Uploading data to Amazon S3"

OUTPUT=$(/root/OT-Smoothbrain-Backup/restic backup --tag coldbackup /ot-node/current/.origintrail_noderc /root/.origintrail_noderc /var/lib/arangodb3 /var/lib/arangodb3-apps 2>&1)

if [ $? -eq 0 ]; then
  /root/OT-Settings/data/send.sh "Backup SUCCESSFUL:${N1}$OUTPUT"
  rm -rf /root/backup/* /root/backup/.origintrail_noderc
else
  /root/OT-Settings/data/send.sh "Uploading backup to S3 FAILED:${N1}$OUTPUT"
  systemctl start arangodb3
  systemctl start otnode
  exit 1
fi

echo "Starting otnode and arangodb3"
systemctl start arangodb3
systemctl start otnode

exit 0