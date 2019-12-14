#!/bin/sh
echo $SCP $CONFIG/rsyncd.conf $SSH_USER@$IP:rsyncd.conf
$SCP $CONFIG/rsyncd.conf $SSH_USER@$IP:rsyncd.conf

$SSH << EOF
sed -i 's/<ip>/${RSYNC_ALLOW_IP}/' rsyncd.conf
sed -i 's/<port>/${RSYNC_PORT}/' rsyncd.conf

killall -INT rsync
rm -rf rsyncd.lock

cat rsyncd.conf
sleep 3

rsync --daemon --config=rsyncd.conf
EOF
