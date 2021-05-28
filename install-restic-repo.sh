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

read -p "Are you running multiple servers and will be using ansible to deploy the backup software? Press "y" for yes and "n" for no...${N1}${N1}" -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  read -p "${N1}Are you logging in as root? Press "y" if yes and "n" if logging in as a non-root user...${N1}" -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "${N1}Do you log in as root using a password? Press "y" for yes and "n" if you use a ssh key...${N1}" -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      ansible-playbook -k ansible/ansible-install-restic.yml
      exit 0
    else
      ansible-playbook ansible/ansible-install-restic.yml
      exit 0
    fi
  else
    read -p "${N1}Do you log in as non-root using a password? Press "y" for yes and "n" if you use a ssh key...${N1}" -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      ansible-playbook -u ADD_USERNAME -k -K -b ansible/ansible-install-restic.yml
      exit 0
    else
      ansible-playbook -u ADD_USERNAME -K -b ansible/ansible-install-restic.yml
      exit 0
    fi
  fi
else
  echo "Continuing with single-server installation... (peasant)"
fi

echo "Adding 6-hour schedule to cron"
(crontab -l 2>/dev/null; echo "0 */6 * * * /root/Smoothbrain-OT-Backup/restic") | crontab -

read -p "Press "y" to perform an initial backup now or "n" to exit the installer. The backup IS scheduled to be\
 performed at the next 6am/12pm/6pm/12am time (based on servertime)" -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  /root/Smoothbrain-OT-Backup/restic-backup.sh
else
  echo "Thank you for choosing Smoothbrain OT Backup! Now with more Smoothbrain!"
  exit 0
fi
