#!/bin/bash -xe

today=$(date +%Y%m%d)
#date_age=$(date +%Y%m%d -d "${1:-4} days ago")

#if [ ! -n "$1" ]; then
#if [ "$1" = "" ]; then
if [ ! $1 ]; then
    echo "you have not input a word!"
    date_age=$(date +%Y%m%d -d "${1:-4} days ago")
else
    echo "the word you input is $1"
    date_age=$1
fi

echo "get $date_age~$today fex"
./git/taifex_daily/mining_rpt.py -e $date_age $today TX 1  >  TX_$today
./git/taifex_daily/mining_rpt.py -e $date_age $today  MTX 1 > MTX_$today
sleep 1m
find ~/git/taifex_daily/fut_rpt/ -mtime +15 -type f -name '*' -exec rm -rf {} \;
find ~/git/taifex_daily/opt_rpt/ -mtime +15 -type f -name '*' -exec rm -rf {} \;
find ~/ -mtime +0 -type f -name "*TX_*" -exec rm -rf {} \;
