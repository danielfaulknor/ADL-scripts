#!/bin/bash
IFS=$'\n'

function logdate() {
	echo -n `date +"%b %e %T "` >> ~/logs/torrents.log
}

logdate
echo " Starting move" >> ~/logs/torrents.log
for dir in `ls ~/downloads/torrents`
do
if [ -z `ls ~/downloads/torrents/$dir/ | grep lftp-pget-status` ]
	then
		logdate		
		echo " Move to Complete:" $dir >> ~/logs/torrents.log
		mv ~/downloads/torrents/$dir ~/downloads/torrents-complete
fi
done
ls ~/downloads/torrents-complete > ~/logs/torrents-complete
for dir in `ls ~/downloads/torrents-complete`
do
	logdate
	echo " Seedbox Delete:" $dir >> ~/logs/torrents.log
	ssh root@YOUR-SEEDBOX "mv -v '/home/dan/Downloads/$dir' /home/dan/Downloaded" >> ~/logs/torrents.log 2>&1
	logdate
	echo " Move to Fileserver:" $dir >> ~/logs/torrents.log
	[ -d /media/data/new/`date +%F` ] || mkdir /media/data/new/`date +%F`
	mkdir /media/data/new/`date +%F`/$dir
	touch /media/data/new/`date +%F`/$dir/copying
	rsync -avz --progress --remove-source-files ~/downloads/torrents-complete/$dir /media/data/new/`date +%F`/ 
	rm /media/data/new/`date +%F`/$dir/copying

done
rmdir ~/downloads/torrents-complete/*/*
rmdir ~/downloads/torrents-complete/*
cat ~/logs/torrents-complete | mutt -s "Torrents Complete" your-email@yourdomain.com
logdate
echo "Completing Move" >> ~/logs/torrents.log

