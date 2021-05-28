#!/bin/bash
source "/root/Smoothbrain-OT-Backup/config.sh"
N1=$'\n'

echo "Removing outdated snapshots and data"

FORGET_OUTPUT=`restic forget --group-by host --keep-last 1 2>&1`
FORGET_STATUS=$?
echo "$FORGET_OUTPUT"

echo "Notifying result of forget command with telegram STATUS=$FORGET_STATUS"

if [ $FORGET_STATUS == 0 ]; then
  /root/Smoothbrain-OT-Backup/data/send.sh "Forget command SUCCEEDED"
else
  /root/Smoothbrain-OT-Backup/data/send.sh "Forget command FAILED${N1}$FORGET_OUTPUT"
  exit 1
fi

PRUNE_OUTPUT=`restic prune 2>&1`
PRUNE_STATUS=$?
echo "$PRUNE_OUTPUT"

echo "Notifying result of prune command with telegram STATUS=$PRUNE_STATUS"

if [ $PRUNE_STATUS == 0 ]; then
  /root/Smoothbrain-OT-Backup/data/send.sh "Prune command SUCCEEDED"
else
  /root/Smoothbrain-OT-Backup/data/send.sh "Prune command FAILED${N1}$PRUNE_OUTPUT"
  exit 1
fi

CHECK_OUTPUT=`restic check 2>&1`
CHECK_STATUS=$?
echo "$CHECK_OUTPUT"

echo "Notifying result of check command with telegram STATUS=$CHECK_STATUS"

if [ $CHECK_STATUS == 0 ]; then
  /root/Smoothbrain-OT-Backup/data/send.sh "Check command SUCCEEDED"
else
  /root/Smoothbrain-OT-Backup/data/send.sh "Check command FAILED${N1}$CHECK_OUTPUT"
  exit 1
fi
