#!/bin/bash
function logdate() {
        echo -n `date +"%b %e %T "` >> ~/logs/torrents.log
}


while [ 1 ]
do
logdate
echo " Starting Sync" >> ~/logs/torrents.log
START=$(date +%s.%N)
~/bin/sync-torrents.sh
END=$(date +%s.%N)
DIFF=$(echo "$END - $START" | bc)
if [ "${DIFF%.*}" -gt "60" ]
then
	logdate
	echo " Sync Completed" >> ~/logs/torrents.log
	~/bin/move-torrents.sh
else
	logdate
	echo " Sync Empty. Sleeping" >> ~/logs/torrents.log
	sleep 60
fi
done
