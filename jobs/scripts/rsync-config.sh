#!/bin/sh
$SSH << EOF
echo "$1" > rsyncd.conf
sed -i 's/<ip>/${RSYNC_ALLOW_IP}/' rsyncd.conf
sed -i 's/<port>/${RSYNC_PORT}/' rsyncd.conf
if [ -e rsyncd.pid ]; then
	kill -INT \$(cat rsyncd.pid)
fi
rsync --daemon --config=rsyncd.conf
EOF