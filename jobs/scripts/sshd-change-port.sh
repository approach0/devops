#!/bin/sh
OLD_PORT=$1

ssh -o PasswordAuthentication=no $SSH_USER@$IP -p $OLD_PORT << EOF
cat /etc/ssh/sshd_config
echo "changing port from $OLD_PORT to $SSH_PORT ..."

sed -i '/Port ${OLD_PORT}/c Port ${SSH_PORT}' /etc/ssh/sshd_config
systemctl restart sshd
EOF
