#!/bin/bash

login=
pass=
host=
remote_dir=/home/dan/Downloads
local_dir=~/downloads/torrents


trap "rm -f /tmp/synctorrents.lock" SIGINT SIGTERM

if [ -e /tmp/synctorrents.lock ]
then
  echo "synctorrents is running already."
  exit 1
else

  touch /tmp/synctorrents.lock

  lftp -u $login,$pass $host << EOF
  set ftp:ssl-allow no
  set mirror:use-pget-n 25
  mirror -c -P1 --log=/home/dl/logs/synctorrents.log $remote_dir $local_dir
  quit
EOF

  rm -f /tmp/synctorrents.lock
  exit 0

fi

