#!/bin/bash
IFS=$'\n'

function logdate() {
	echo -n `date +"%b %e %T "` >> ~/logs/torrents.log
}

logdate
echo " Starting move" >> ~/logs/torrents.log

# List all the files in the download directory #
for dir in `ls ~/downloads/torrents`
do
	if [ -z `ls ~/downloads/torrents/$dir/ | grep lftp-pget-status` ]
	# We assume these ones are done because lftp is finished
		then
			logdate
			echo " Move to Complete:" $dir >> ~/logs/torrents.log

			# And move them out of the way for further processing
			mv ~/downloads/torrents/$dir ~/downloads/torrents-complete
	fi
done

# List for emailing
ls ~/downloads/torrents-complete > ~/logs/torrents-complete

# Here goes the processing of the ones we verified as complete
for dir in `ls ~/downloads/torrents-complete`
do
	logdate
	echo " Seedbox Delete:" $dir >> ~/logs/torrents.log

	# Soft delete from seedbox so they don't get downloaded again
	ssh root@YOUR-SEEDBOX "mv -v '/home/dan/Downloads/$dir' /home/dan/Downloaded" >> ~/logs/torrents.log 2>&1
	logdate
	echo " Move to Fileserver:" $dir >> ~/logs/torrents.log

	# Create a folder for the current date to keep things tidy if it doesn't already exist
	[ -d /media/data/new/`date +%F` ] || mkdir /media/data/new/`date +%F`
	
	#Check this is a directory, otherwise don't create it, will break single file downloads.
	if [ -d ~/downloads/torrents-complete/$dir ]
        then
			# Touch an empty file to indicate the directory is still being copied
			[ -d /media/data/new/`date +%F`/$dir ] || mkdir /media/data/new/`date +%F`/$dir
			touch /media/data/new/`date +%F`/$dir/copying
		fi

	# Move the files
	rsync -avz --progress --remove-source-files ~/downloads/torrents-complete/$dir /media/data/new/`date +%F`/

	# Clear the copying flag if it exists.
	if [ -f /media/data/new/`date +%F`/$dir/copying ] || rm /media/data/new/`date +%F`/$dir/copying

done

# Remove the empty directories rsync leaves behind (there must be a cleaner way to do this..)
rmdir ~/downloads/torrents-complete/*/*
rmdir ~/downloads/torrents-complete/*

# Fire off an email with the completed items
cat ~/logs/torrents-complete | mutt -s "Torrents Complete" your-email@yourdomain.com
logdate

echo "Completing Move" >> ~/logs/torrents.log

