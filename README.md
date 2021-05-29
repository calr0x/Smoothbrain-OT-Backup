# Smoothbrain-OT-Backup
Backup system for OriginTrail Nodes (Also supports Ansible)

Regular and Ansible users:

1. Login as root
2. cd
3. git clone https://github.com/calr0x/Smoothbrain-OT-Backup.git
4. cd Smoothbrain-OT-Backup
5. nano config.sh
6. chmod -R +x data/* install-restic-repo.sh restic restic-*
7. ./install-restic-repo.sh

ANSIBLE USERS:
Before it performs the intial backup it will ask if you are deploying this backup thru Ansible. It will then ask whether you login as root and whether you use a ssh key or a password. It will then execute the proper anisble command.

non-ansible users:
You are plebs. Just answer "n" to that question and it will continue the backup.
