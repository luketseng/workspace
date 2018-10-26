#!/bin/bash

./git/taifex_daily/mining_rpt.py -s $(date +%Y%m%d) $(date +%Y%m%d) 1 TX>TX_$(date +%Y%m%d)
./git/taifex_daily/mining_rpt.py -s $(date +%Y%m%d) $(date +%Y%m%d) 1 MTX>MTX_$(date +%Y%m%d)
find ~/git/taifex_daily/fut_rpt/ -mtime +15 -type f -name '*' -exec rm -rf {} \;
find ~/git/taifex_daily/opt_rpt/ -mtime +15 -type f -name '*' -exec rm -rf {} \;
find ~/ -mtime +0 -type f -name "*TX_*" -exec rm -rf {} \;
