#!/bin/sh
#功能：kill端口号$1对应的进程，感觉进程太多时效果不佳

if [ -n "$1" ]; then

	pid=`netstat -anp | grep $1 | awk '{printf $7}' | cut -d/ -f1`
	if [ -n "$pid" ]; then
		kill -9  $pid
	else
		#echo "not found!"
		exit
	fi

fi
