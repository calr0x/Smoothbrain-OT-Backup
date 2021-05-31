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

6. ctrl+s (to save)  
7. ctrl+x (to exit nano)
8. chmod -R +x data/* install-restic-repo.sh restic restic-*  
9. RUN THE FOLLOWING COMMAND BELOW DEPENDING ON WHETHER IT'S S3 OR B2:

S3:
./restic -r s3.amazonaws.com/bucket_name_here init

B2:
./restic -r b2:bucketname:path/to/repo init

** ANSIBLE USERS STOP HERE  
** nano ansible/ansible-install-restic.yml  
** READ THE TOP COMMENTS FOR FURTHER INSTRUCTIONS

10. (crontab -l 2>/dev/null; echo "0 */6 * * * /root/Smoothbrain-OT-Backup/restic-backup.sh") | crontab -

THE LAST COMMAND SCHEDULES A WEEKLY CLEANUP OF THE REPOSITORY TO CLEAR OLD BACKUPS. IT IS **NOT** RUN ON EVERY COMPUTER. IT MUST BE INSTALLED ON ONLY ONE NODE OR A LINUX SERVER THAT'S NOT RUNNING A NODE.

IF YOU ONLY HAVE 1 NODE THEN RUN THIS COMMAND AND YOU ARE DONE. IF YOU ARE RUNNING MULTIPLE NODES AND EACH NODE HAS ITS OWN BUCKET THEN RUN THIS COMMMAND ON EACH NODE. IF YOU HAVE MULTIPLE NODES **AND** THE NODES SHARE A BUCKET THEN THIS COMMAND CAN ONLY BE RUN ON **ONE** NODE. IF YOU RUN THIS COMMAND ON MORE THAN ONE NODE IT WILL CREATE A SITUATION WHERE THE WEEKLY CLEANUP WON'T WORK.

11. (crontab -l 2>/dev/null; echo "0 12 * * 5 /root/Smoothbrain-OT-Backup/restic-cleanup.sh") | crontab -

Done!



