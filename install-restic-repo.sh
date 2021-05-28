#!/bin/bash
source "config.sh"

N1=$'\n'

clear

KEY_ORIGINAL="export RESTIC_PASSWORD=\"REPLACE_WITH_RESTIC_REPOSITORY_PASSWORD\""
KEY_CHECK=$(cat config.sh | grep REPLACE_WITH_RESTIC_REPOSITORY_PASSWORD)

if [ "$KEY_CHECK" != "$KEY_ORIGINAL" ]; then
  read -p "There is already a key generated or the S3 key field is invalid. \
  This installer will only run when the config.sh is set to default values. \
  Press "r" to restore to the default config and "c" to skip key generation and continue:${N1}" -n 1 -r
  if [[ $REPLY =~ ^[Cc]$ ]]; then
    echo "Proceeding...${N1}"
  else
    cp config-original.sh config.sh
  fi
fi

echo "Generating random passkey for repository"
REPO_PASSKEY=$(apg -a 1 -m 32 -n 1 -M NCL)
echo $REPO_PASSKEY

echo "Copy this key to your password manager. You ARE using a password manager. Right? RIGHT?"
read -p "Press enter to continue...${N1}"

sed -i s,REPLACE_WITH_RESTIC_REPOSITORY_PASSWORD,$REPO_PASSKEY,g config.sh

echo "Initializing the S3 repository"
INIT_OUTPUT='/root/Smoothbrain-OT-Backup/restic --init'
INIT_STATUS=$?
echo "$INIT_OUTPUT"

if [ $INIT_STATUS == 0 ]; then
  echo "Init SUCCEEDED"
else
  echo "Init FAILED:${N1}$INIT_OUTPUT"
  exit 1
fi
