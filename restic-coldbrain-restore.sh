#!/bin/bash

#write install variable type to file

if [ INSTALL_TYPE = 1 ]; then
    /root/OT-DockSucker/data/install-otnode.sh
    /root/OT-Smoothbrain-Backup/data/download-restore-backup.sh
else
    sudo docker run -i --log-driver json-file --log-opt max-size=1g --name=otnode -p 8900:8900 -p 5278:5278 -p 3000:3000 -v ~/.origintrail_noderc:/ot-node/.origintrail_noderc origintrail/ot-node:release_mainnet
    /root/OT-Smoothbrain-Backup/data/download-restore-backup.sh
fi