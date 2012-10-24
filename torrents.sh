#!/bin/bash

# Function for adding the date to the log with no new line
function logdate() {
        echo -n `date +"%b %e %T "` >> ~/logs/torrents.log
}


while [ 1 ]
do
	logdate
	echo " Starting Sync" >> ~/logs/torrents.log

	# Record start time for later
	START=$(date +%s.%N)

	# Start FTP
	~/bin/sync-torrents.sh

	# Record end time
	END=$(date +%s.%N)

	# How long did we take?
	DIFF=$(echo "$END - $START" | bc)

	# If time was > 1 minute we assume there were files downloaded
	if [ "${DIFF%.*}" -gt "60" ]
	then
		logdate
		echo " Sync Completed" >> ~/logs/torrents.log

		# Call the move script
		~/bin/move-torrents.sh
	else
		logdate
		echo " Sync Empty. Sleeping" >> ~/logs/torrents.log

		# Nothing was downloaded, sleep so we don't annoy the FTP server
		sleep 60
	fi
done
