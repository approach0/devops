#!/bin/sh
echo $SCP $CONFIG/rsyncd.conf $SSH_USER@$IP:rsyncd.conf
$SCP $CONFIG/rsyncd.conf $SSH_USER@$IP:rsyncd.conf

$SSH << EOF
sed -i 's/<ip>/${RSYNC_ALLOW_IP}/' rsyncd.conf
sed -i 's/<port>/${RSYNC_PORT}/' rsyncd.conf
if [ -e rsyncd.pid ]; then
	kill -INT \$(cat rsyncd.pid)
	rm -rf rsyncd.lock
fi
rsync --daemon --config=rsyncd.conf
EOF
