# Smoothbrain-OT-Backup
Backup system for OriginTrail Nodes (Also supports Ansible)

SINGLE-SERVER USERS:

YOU WILL NEED A DIFFERENT BUCKET FOR EACH SERVER. IF YOU TRY TO USE THE SAME BUCKET YOU WILL **NOT** RUN THE WEEKLY CLEAN
Single-server users and Ansible users:

1. Login as root
2. cd
3. git clone https://github.com/calr0x/Smoothbrain-OT-Backup.git
4. cd Smoothbrain-OT-Backup
5. nano config.sh

Edit the following items:

Edit the RESTIC_REPOSITORY and RESTIC_PASSWORD lines.

  S3 format should be: s3:https://s3.amazonaws.com/bucket_name_here
  B2 format should be: bucketname:path/to/repo
  
Edit both S3 lines OR both B2 lines.

AWS_ACCESS_KEY_ID="REPLACE_WITH_AWS_ACCESS_KEY"
AWS_SECRET_ACCESS_KEY="REPLACE_WITH_AWS_SECRET_ACCESS_KEY"

B2_ACCOUNT_ID="REPLACE_WITH_B2_ACCOUNT_ID"
B2_ACCOUNT_KEY="REPLACE_WITH_B2_ACCOUNT_KEY"

ctrl+s (to save)
ctrl+x (to exit nano)

7. chmod -R +x data/* install-restic-repo.sh restic restic-*
8. ./install-restic-repo.sh

ANSIBLE USERS:
Before it performs the intial backup it will ask if you are deploying this backup thru Ansible. It will then ask whether you login as root and whether you use a ssh key or a password. It will then execute the proper anisble command.

non-ansible users:
You are plebs. Just answer "n" to that question and it will continue the backup.
