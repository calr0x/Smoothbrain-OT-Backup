# OT-Smoothbrain-Backup
Backup system for OriginTrail Nodes (Also supports Ansible)

This backup system has several advantages over the default OriginTrail backup system. Their system copies 100% of everything it is backing up and sends it to Amazon. Every time. This means if your backup size is 10gig and you run it once a day you will have 70gig in a week. It also doesn't address verification nor does it ever delete old backups off of Amazon on a regular schedule. You can achieve these objectives yourself but most backup systems do this within the program.

What makes this system better is a few things:  

1. It only updates what is _new_ or _changed_. Files that haven't changed do not need to be resent. This is called "de-duplication" in the backup world. This means it takes up significantly less space _and_ there is no penalty for frequent backups and frequent backups need to be occurring.

If you backup once a week on Mondays and on Friday the VPS dies in such a way you're data isn't recoverable you lose _all_ the jobs you won since that last backup. Today that might not amount to much but tomorrow it _will_. A job is a job. There is no reason to lose a job over data loss. This system, by default, backs up four times a day (12pm/6pm/12am/6am localtime) and is user-changable to whatever you want.

2. It will, weekly, remove all but the latest "snapshot". A snapshot is a backup of the new or changed files since the _previous_ snapshot/backup. In this process it merges the data from those previous backups so this remaining snapshot contains a full image of the current state of the files.

3. It then checks the files in the snapshots for consistency and accuracy.

All of this is messaged to you in Telegram (if the token/chat_id is provided).

So it's significantly improved over the standard backup method.. :)

** BEGIN INSTRUCTIONS **

THIS SYSTEM SUPPORTS MULTIPLE SERVERS ON BOTH ONE AND MULTIPLE BUCKETS. I HIGHLY RECOMMEND USING ONE BUCKET FOR ALL THE SERVERS. THE SYSTEM NATIVELY EXPECTS THAT AND IS DESIGNED TO HANDLE IT WELL AS IT LABELS EACH SNAPSHOT WITH THE HOSTNAME THAT MADE IT. IF YOU CHOOSE TO USE MULTIPLE BUCKETS THEN EACH SERVERS CONFIG HAS TO BE EDITED FOR THE CORRECT S3/B2 BUCKET AND STEP 11 MUST BE RUN ON EACH SERVER.

FOR THOSE INSTALLING ON MULTIPLE SERVERS AND USING ONE BUCKET STEP 11 ONLY NEEDS TO BE INSTALLED ON **ONE** COMPUTER AND IT DOES NOT HAVE TO BE INSTALLED (BUT CAN BE) ON A SERVER RUNNING A NODE. WHEN THE CLEANUP SCRIPT RUNS IT LOCKS THE SPECIFIC BUCKET. IF TWO SERVERS USING THE SAME BUCKET RUN THE CLEANUP SCRIPT IT WILL CAUSE AN ISSUE AND ALL BUT ONE CLEANUP SCRIPT WILL BE DENYED, GENERATING AN ERROR.

I RENT A LOW-TIER VPS WHICH I USE FOR CONTROL OPERATIONS ON MY NODES. IT DOES HAVE A ORIGINTRAIL NODE AND IS USED TO SERVICE AND MAINTAIN MY NODES. IT IS ON THIS SERVER THE WEEKLY CLEANUP SCRIPT RUNS.

1. Login as root
2. cd
3. git clone https://github.com/calr0x/OT-Smoothbrain-Backup.git
4. cd OT-Smoothbrain-Backup
5. nano config.sh

Edit the following items:

Edit the RESTIC_REPOSITORY and RESTIC_PASSWORD lines. Remember, if you are using a different bucket for each node then this file MUST be different on each computer it's being installed on!

  __S3__ format should be: __s3:ht<span>tps://s3.amazonaws.com/bucket_name_here__  
  __B2__ format should be: __bucketname:path/to/repo__

Edit both S3 lines OR both B2 lines.

  AWS_ACCESS_KEY_ID="REPLACE_WITH_AWS_ACCESS_KEY"  
  AWS_SECRET_ACCESS_KEY="REPLACE_WITH_AWS_SECRET_ACCESS_KEY"

  B2_ACCOUNT_ID="REPLACE_WITH_B2_ACCOUNT_ID"  
  B2_ACCOUNT_KEY="REPLACE_WITH_B2_ACCOUNT_KEY"

6. ctrl+s (to save)  
7. ctrl+x (to exit nano)
8. source config.sh
9. ./restic init

__ANSIBLE USERS STOP HERE__  
__nano ansible/install-restic.yml__  
__READ THE TOP COMMENT FOR FURTHER INSTRUCTIONS__

10. (crontab -l 2>/dev/null; echo "0 */6 * * * /root/OT-Smoothbrain-Backup/restic-backup.sh") | crontab -

11. To run an initial backup immediately:

source config.sh && ./restic-backup.sh

THE LAST COMMAND SCHEDULES A WEEKLY CLEANUP OF THE REPOSITORY TO CLEAR OLD BACKUPS. IT IS **NOT** RUN ON EVERY COMPUTER. IT MUST BE INSTALLED ON ONLY ONE SERVER AND CAN BE A NODE OR A LINUX SERVER THAT'S NOT RUNNING A NODE.

IF YOU ONLY HAVE 1 NODE THEN RUN THIS COMMAND AND YOU ARE DONE. IF YOU ARE RUNNING MULTIPLE NODES AND EACH NODE HAS ITS OWN BUCKET THEN RUN THIS COMMMAND ON EACH NODE. IF YOU HAVE MULTIPLE NODES **AND** THE NODES SHARE A BUCKET THEN THIS COMMAND CAN ONLY BE RUN ON **ONE** NODE. IF YOU RUN THIS COMMAND ON MORE THAN ONE NODE IT WILL CREATE A SITUATION WHERE THE WEEKLY CLEANUP WON'T WORK.

12. (crontab -l 2>/dev/null; echo "0 12 * * 5 /root/OT-Smoothbrain-Backup/restic-cleanup.sh") | crontab -

Done!
