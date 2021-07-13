# OT-Smoothbrain-Backup
Backup system for OriginTrail Nodes (Also supports Ansible)

This backup system has several advantages over the default OriginTrail backup system. Their system copies 100% of everything it is backing up and sends it to Amazon. Every time. This means if your backup size is 10gig and you run it once a day you will have 70gig in a week. It also doesn't address verification nor does it ever delete old backups off of Amazon on a regular schedule. You can achieve these objectives yourself but most backup systems do this within the program.

---

What makes this system better is a few things:  

1. It only updates what is _new_ or _changed_. Files that haven't changed do not need to be resent. This is called "de-duplication" in the backup world. This means it takes up significantly less space _and_ there is no penalty for frequent backups and frequent backups need to be occurring.

If you backup once a week on Mondays and on Friday the VPS dies in such a way you're data isn't recoverable you lose _all_ the jobs you won since that last backup. Today that might not amount to much but tomorrow it _will_. A job is a job. There is no reason to lose a job over data loss. This system, by default, backs up four times a day (12pm/6pm/12am/6am localtime) and is user-changable to whatever you want.

2. It will, weekly, remove all but the latest "snapshot". A snapshot is a backup of the new or changed files since the _previous_ snapshot/backup. In this process it merges the data from those previous backups so this remaining snapshot contains a full image of the current state of the files.

3. It then checks the files in the snapshots for consistency and accuracy.

All of this is messaged to you in Telegram (if the token/chat_id is provided).

So it's significantly improved over the standard backup method.. :)

---

THIS SYSTEM SUPPORTS MULTIPLE SERVERS ON BOTH ONE AND MULTIPLE BUCKETS. I HIGHLY RECOMMEND USING ONE BUCKET FOR ALL THE SERVERS. THE SYSTEM NATIVELY EXPECTS THAT AND IS DESIGNED TO HANDLE IT WELL AS IT LABELS EACH SNAPSHOT WITH THE HOSTNAME THAT MADE IT. IF YOU CHOOSE TO USE MULTIPLE BUCKETS THEN EACH SERVERS CONFIG HAS TO BE EDITED FOR THE CORRECT S3/B2 BUCKET AND STEP 11 MUST BE RUN ON EACH SERVER.

FOR THOSE INSTALLING ON MULTIPLE SERVERS AND USING ONE BUCKET STEP 11 ONLY NEEDS TO BE INSTALLED ON **ONE** COMPUTER AND IT DOES NOT HAVE TO BE INSTALLED (BUT CAN BE) ON A SERVER RUNNING A NODE. WHEN THE CLEANUP SCRIPT RUNS IT LOCKS THE SPECIFIC BUCKET. IF TWO SERVERS USING THE SAME BUCKET RUN THE CLEANUP SCRIPT IT WILL CAUSE AN ISSUE AND ALL BUT ONE CLEANUP SCRIPT WILL BE DENYED, GENERATING AN ERROR.

I RENT A LOW-TIER VPS WHICH I USE FOR CONTROL OPERATIONS ON MY NODES. IT DOES HAVE A ORIGINTRAIL NODE AND IS USED TO SERVICE AND MAINTAIN MY NODES. IT IS ON THIS SERVER THE WEEKLY CLEANUP SCRIPT RUNS.

---
IF YOU USE A __RASPBERRY PI__ YOU NEED TO DOWNLOAD A DIFFERENT RESTIC BINARY FROM THE RESTIC WEBSITE:

```
wget https://github.com/restic/restic/releases/download/v0.12.0/restic_0.12.0_linux_arm.bz2
```
```
bunzip2 restic_0.12.0_linux_arm.bz2
```
```
cp restic_0.12.0_linux_arm restic
```
```
chmod +x restic
```

---
&nbsp; 

## **BACKUP INSTRUCTIONS:**

&nbsp;

__Login as root__
```
cd
```
```
git clone https://github.com/calr0x/OT-Smoothbrain-Backup.git
```
```
git clone https://github.com/calr0x/OT-Settings.git
```
```
cd OT-Settings
```
```
nano config.sh
```

Edit the following items:

Edit the RESTIC_REPOSITORY and RESTIC_PASSWORD lines. Remember, if you are using a different
bucket for each node then this file MUST be different on each computer it's being installed on!

>  __S3__ format should be: __s3:ht<span>tps://s3.amazonaws.com/bucket_name_here__  
  __B2__ format should be: __bucketname:path/to/repo__

Edit both S3 lines ___OR___ both B2 lines ___NOT___ both.

>  AWS_ACCESS_KEY_ID="__REPLACE_WITH_AWS_ACCESS_KEY__"  
>  AWS_SECRET_ACCESS_KEY="__REPLACE_WITH_AWS_SECRET_ACCESS_KEY__"

>  B2_ACCOUNT_ID="__REPLACE_WITH_B2_ACCOUNT_ID__"  
>  B2_ACCOUNT_KEY="__REPLACE_WITH_B2_ACCOUNT_KEY__"

```
ctrl+s (to save)
ctrl+x (to exit nano)
```
```
source config.sh
```
&nbsp;

__IF YOU ARE RESTORING A BACKUP ON A NEW SERVER STOP HERE AND RESTURN TO THE RESTORE DIRECTIONS FOR THE NEXT STEP!__  
&nbsp;

```
./restic init
```

---

## __ANSIBLE USERS STOP HERE__:
Read the top of the following document for further instructions.
```
nano ansible/install-restic.yml
```

---

```
(crontab -l 2>/dev/null; echo "0 */6 * * * /root/OT-Smoothbrain-Backup/restic-backup.sh") | crontab -
```
To run an initial backup immediately:
```
source config.sh && ./restic-backup.sh
```

THE LAST COMMAND SCHEDULES A WEEKLY CLEANUP OF THE REPOSITORY TO CLEAR OLD BACKUPS. IT IS **NOT** RUN ON EVERY COMPUTER. IT MUST BE INSTALLED ON ONLY ONE SERVER AND CAN BE A NODE OR A LINUX SERVER THAT'S NOT RUNNING A NODE.

IF YOU ONLY HAVE 1 NODE THEN RUN THIS COMMAND AND YOU ARE DONE. IF YOU ARE RUNNING MULTIPLE NODES AND EACH NODE HAS ITS OWN BUCKET THEN RUN THIS COMMMAND ON EACH NODE. IF YOU HAVE MULTIPLE NODES **AND** THE NODES SHARE A BUCKET THEN THIS COMMAND CAN ONLY BE RUN ON **ONE** NODE. IF YOU RUN THIS COMMAND ON MORE THAN ONE NODE IT WILL CREATE A SITUATION WHERE THE WEEKLY CLEANUP WON'T WORK.

```
(crontab -l 2>/dev/null; echo "0 12 * * 5 /root/OT-Smoothbrain-Backup/restic-cleanup.sh") | crontab -
```

Backup done!


&nbsp; 
## **RESTORE INSTRUCTIONS:**
&nbsp;

__Create a fresh server and follow https://otnode.com/ (1-4 of new node guide)__

__Login as root__  

```
apt install git
```
```
git clone https://github.com/calr0x/OT-Smoothbrain-Backup.git
```
```
git clone https://github.com/calr0x/OT-Settings.git
```
Install Smoothbrain-Backup and OT-Settings by following the [install directions](#backup-instructions) until directed to return here.

```
./restic snapshots
```
If this doesn't work there is a problem in the Smoothbrain config. Correct the issue by running the commands below and retry ./restic snapshots:
```
nano config.sh
```
```
source config.sh
```

Review the snapshots and find the most recent backup to restore. Pay attention to the 3rd column where the hostname of the server that made the backup is. If you know the EXACT (case-sensitive) hostname you can use the following command to filter out all other hosts:
```
./restic snapshots -H TYPE_HOSTNAME_HERE
```

For example:
```
./restic snapshots -H Otnode1
```
Review list of snapshots for that node.  
```
./restic restore SNAPSHOT_ID --target /root (replace "SNAPSHOT_ID" with 8 digit snapshot id which you want to restore, newest is the bottom one)
Do the following command
cp /root/OT-Smoothbrain-Backup/backup/.origintrail_noderc /root/.origintrail_noderc
Edit the IP if it has changed with:
nano /root/.origintrail_noderc
Move the backup folder from /root/backup/root/OT-Smoothbrain-Backup/backup/ to /backup with the following command:
mv /root/backup/root/OT-Smoothbrain-Backup/backup/ /root/
Do restore steps 7-8 of (https://otnode.com/node-backup/)
Edit restore.sh using this command:
nano /root/restore.sh
#change backup directory BACKUPDIR="none" to BACKUPDIR="OT-Smoothbrain-Backup/backup"
Step 9 of otnode restore guide, being ./restore.sh
