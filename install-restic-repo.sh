#!/bin/bash
source "config.sh"

N1=$'\n'

clear

echo "Checking the configs to make sure they've been changed from defaults. We are ONLY checking to make sure they have \
been CHANGED and not that they are VALID changes. It is important the URL of the storage (S3/B2) is correct.${N1}${N1}"

if [ $RESTIC_REPOSITORY == "REPLACE_WITH_S3_OR_B2_BUCKET_URL" ]; then
  echo "${N1}${N1}The RESTIC_REPOSITORY value in config.sh has not been edited.${N1}\
Please edit it to include the URL of either your Amazon S3 or Backblaze B2${N1}\
bucket.${N1}${N1}Amazon: s3:https://s3.amazonaws.com/bucketname${N1}${N1}\
Backblaze: b2:bucketname:path/to/repo${N1}"
  exit 1
fi

if [ $RESTIC_PASSWORD == "REPLACE_WITH_RESTIC_REPOSITORY_PASSWORD" ]; then
  echo "${N1}${N1}The RESTIC_PASSWORD value in config.sh has not been edited. \
Please edit it to include the password to use for the respository. As the data on \
the repository WILL be encrypted, you will use this password to access the \
repository.${N1}${N1}You MUST save this password somewhere. Losing this password will \
prevent ALL ACCESS to the repository!${N1}"
  exit 1
fi

read -s -p "Are you using S3 for your repository? Press \"y\" for S3 or \"n\" for B2:" -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  if [ $AWS_ACCESS_KEY_ID == "REPLACE_WITH_AWS_ACCESS_KEY" ]; then
    echo "${N1}${N1}The AWS_ACCESS_KEY_ID value in config.sh has not been edited. \
Please edit it to include the AWS access key ID to use to login to your S3 bucket.${N1}"
    exit 1
  fi
  if [ $AWS_SECRET_ACCESS_KEY == "REPLACE_WITH_AWS_SECRET_ACCESS_KEY" ]; then
    echo "${N1}${N1}The AWS_SECRET_ACCESS_KEY_ID value in config.sh has not been edited. \
Please edit it to include the AWS secret access key ID to use to login to your S3 bucket.${N1}"
    exit 1
  fi
else
  if [ $B2_ACCOUNT_ID == "REPLACE_WITH_B2_ACCOUNT_ID" ]; then
    echo "${N1}${N1}The B2_ACCOUNT_ID value in config.sh has not been edited. \
Please edit it to include the Backblaze access key ID to use to login to your B2 bucket.${N1}"
    exit 1
  fi
  if [ $B2_ACCOUNT_KEY == "REPLACE_WITH_B2_ACCOUNT_KEY" ]; then
    echo "${N1}${N1}The B2_ACCOUNT_KEY value in config.sh has not been edited. \
Please edit it to include the Backblaze  secret access key ID to use to login to your B2 bucket.${N1}"
    exit 1
  fi
fi

echo "${N1}${N1}Creating the S3 repository on S3/B2${N1}"
/root/Smoothbrain-OT-Backup/restic -r $RESTIC_REPOSITORY init
INIT_STATUS=$?

if [ $INIT_STATUS == 0 ]; then
  echo "Initializing the S3 repository: SUCCEEDED${N1}${N1}"
else
  echo "Initializing the S3 repository: FAILED${N1}${N1}"
  exit 1
fi

echo "${N1}Installing cron schedule to run the backup every 6 hours.${N1}"
crontab -l | grep -v '/root/Smoothbrain-OT-Backup/restic-backup.sh' | crontab -
(crontab -l 2>/dev/null; echo "0 */6 * * * /root/Smoothbrain-OT-Backup/restic-backup.sh") | crontab -

read -s -s -p "Will you be using ansible to deploy the backup software? Press "y" for yes and "n" for no...${N1}${N1}" -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  read -s -p "${N1}Are you logging in as root? Press "y" if yes and "n" if logging in as a non-root user...${N1}" -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -s -p "${N1}Do you log in as root using a password? Press "y" for yes and "n" if you use a ssh key...${N1}" -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo "${N1}Run ansible-playbook -k ansible/ansible-install-restic.yml${N1}"
      exit 0
    else
      echo "${N1}Run ansible-playbook ansible/ansible-install-restic.yml${N1}"
      exit 0
    fi
  else
    read -s -p "${N1}Do you log in as non-root using a password? Press "y" for yes and "n" if you use a ssh key...${N1}" -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo "${N1}Run ansible-playbook -u ADD_USERNAME -k -K -b ansible/ansible-install-restic.yml${N1}"
      exit 0
    else
      echo "${N1}Run ansible-playbook -u ADD_USERNAME -K -b ansible/ansible-install-restic.yml${N1}"
      exit 0
    fi
  fi
fi
