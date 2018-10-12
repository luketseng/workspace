#!/bin/bash

cd git/gerrit-config/
pwd
echo cbn | sudo -S ~/git/gerrit-config/cbn-deploy-gerrit-wrapper.sh "$(date +%Y%m%d)-gerrit-backup.tar.gz"
scp "$(date +%Y%m%d)-gerrit-backup.tar.gz" cbn@172.16.1.219:~/cbn/gerrit_backup
#rm "$(date +%Y%m%d)-gerrit-backup.tar.gz"
