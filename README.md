# Smoothbrain-OT-Backup
Backup system for OriginTrail Nodes (Also supports Ansible)

Regular users:

1. Login as root
2. cd
3. git clone https://github.com/calr0x/Smoothbrain-OT-Backup.git
4. cd Smoothbrain-OT-Backup
5. nano config.sh
6. chmod -R +x data/* install-restic-repo.sh restic-*
7. ./install-restic-repo.sh

Ansible users:

1. Login as root
2. cd
3. git clone https://github.com/calr0x/Smoothbrain-OT-Backup.git
4. cd Smoothbrain-OT-Backup
5. nano config.sh
6. chmod -R +x data/* install-restic-repo.sh restic-*
7. cd ansible
8. Run ansible:

As root with no ssh key (uses password login. You're a bad person.)
ansible-playbook -k ansible-install-restic.yml

As root with ssh key:
ansible-playbook ansible-install-restic.yml

As regular user with no ssh key (Uses a password to login. It will ask for your password twice, the second one you can just press "enter". You're a bad person also.)
ansible-playbook -u ADD_USERNAME -k -K -b ansible-install-restic.yml

As regular user with ssh key. (It will ask for your password so it can elevate to sudo.):
ansible-playbook -u ADD_USERNAME -K -b ansible-install-restic.yml
