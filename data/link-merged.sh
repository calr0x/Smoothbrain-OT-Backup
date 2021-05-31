#!/bin/bash

ln -sf "$(docker inspect --format='{{.GraphDriver.Data.MergedDir}}' otnode)/ot-node/backup" /root/Smoothbrain-OT-Backup/
