#!/bin/bash
if [ "$1" == "-h" ]; then
cat << USAGE
Description:
Initialize a brand-new VPS instance.
$0 <ip> <allow_ip>

Examples:
$0 66.175.219.156 121.32.199.201
USAGE
exit
fi

[ $# -ne 2 ] && echo 'bad arg.' && exit

IP="$1"
ALLOW_IP="$2"
USER=root
PUBKEY=$(cat ~/.ssh/id_rsa.pub)
SSHD_USE_PORT=8981
RSYNC_PORT=8990
SEARCHD_PORT=8921

# setup authorized_keys
ssh -v $USER@$IP 'bash -s' -- < ./sshd-trust.sh "'$PUBKEY'"

# Change sshd port 22
ssh $USER@$IP << EOF
sed -i '/Port 22/c Port ${SSHD_USE_PORT}' /etc/ssh/sshd_config
systemctl restart sshd
EOF

# script aborts immediately on any return error
set -e

# use new sshd port since then
o="-p $SSHD_USE_PORT"

## setup rsync early so that we can do index image sync early.
ssh $o $USER@$IP << EOF
apt update -y
apt install -y rsync
echo '$(cat rsyncd.conf)' > rsyncd.conf
sed -i 's/<ip>/${ALLOW_IP}/' rsyncd.conf
sed -i 's/<port>/${RSYNC_PORT}/' rsyncd.conf
if [ -e rsyncd.pid ]; then
	kill -INT \$(cat rsyncd.pid)
fi
rsync --daemon --config=rsyncd.conf
EOF
echo "[ rsync command ]"
echo "rsync rsync://${IP}:${RSYNC_PORT}/root"

# generate public key, prompt you to setup Github deploy key.
ssh $o $USER@$IP << EOF
## generate ssh public key
if [ ! -e ~/.ssh/id_rsa.pub ]; then
	ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ''
fi

## show ssh public key
cat ~/.ssh/id_rsa.pub
EOF

echo "See the node public key? Hit enter to continue."
read anykey

# do setup tasks
ssh $o $USER@$IP << EOF
set -e # abort on err
set -x # echo command
## setup system-level dependencies
apt install -y git g++ cmake bison flex tmux \
            nginx php-fpm php-curl \
            libz-dev libevent-dev libxml2-dev

## git clones
ssh-keyscan github.com > github.pub
cat github.pub > ~/.ssh/known_hosts

if [ ! -e a0 ]; then
	git clone git@github.com:t-k-/a0-private.git a0

	git clone https://github.com/t-k-cloud/tkarch
	(cd tkarch/dotfiles; ./overwrite.sh)

	git clone https://github.com/approach0/fork-indri.git indri
	git clone https://github.com/approach0/fork-cppjieba  cppjieba

	# build search engine
	(cd indri && ./configure && make)
fi

## create convenient script shortcuts
ln -sf a0/searchd/run/searchd.out
ln -sf a0/indexer/scripts/vdisk-mount.sh

## drop in-bound traffic directly to searchd
iptables -F
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p tcp --dport ${SEARCHD_PORT} -j DROP
iptables -L

## setup httpd and php
echo '$(cat nginx.conf)' > /etc/nginx/sites-available/default
echo '<?php phpinfo();?>' > /var/www/html/test.php
systemctl restart nginx
mkdir -p /var/www/html/search
rsync -ar --delete ~/a0/demo/web/ /var/www/html/search/
ln -sf /var/www/html/search/ ./demo
EOF

# echo useful commands
echo "[ ssh command ]"
echo ssh -p $SSHD_USE_PORT $USER@$IP
