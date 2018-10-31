#!/bin/bash -x

today=$(date +%Y%m%d)
date_age=$(date +%Y%m%d -d "${1:-0} days ago")
./git/taifex_daily/mining_rpt.py -e $date_age $today TX 1  >  TX_$today
./git/taifex_daily/mining_rpt.py -e $date_age $today  MTX 1 > MTX_$today
sleep 1m
find ~/git/taifex_daily/fut_rpt/ -mtime +15 -type f -name '*' -exec rm -rf {} \;
find ~/git/taifex_daily/opt_rpt/ -mtime +15 -type f -name '*' -exec rm -rf {} \;
find ~/ -mtime +0 -type f -name "*TX_*" -exec rm -rf {} \;
