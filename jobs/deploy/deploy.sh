#!/bin/bash
if [ "$1" == "-h" ]; then
cat << USAGE
Description:
Deploy searchd deploy branch on specified index.
$0 <ip> <index_image> <cache_limit (MB)>

Examples:
$0 45.33.61.219 demo.img 1800
USAGE
exit
fi

[ $# -ne 3 ] && echo 'bad arg.' && exit

IP="$1"
INDEX_IMAGE="$2"
CACHE_SZ="$3"
USER=root
SSHD_USE_PORT=8981
RSYNC_PORT=8990

# script aborts immediately on any return error
set -e

# use new sshd port since then
o="-p $SSHD_USE_PORT"

# generate public key, prompt you to setup Github deploy key.
ssh $o $USER@$IP << EOF
set -x
export TERM=xterm-256color

pushd a0
git fetch origin deploy
git checkout origin/deploy
./configure --clean
./configure --indri-path=~/indri --jieba-path=~/cppjieba
make clean
make
popd

if mount | grep -q ${INDEX_IMAGE}; then
	kill -INT \$(pidof searchd.out)
	sleep 8
	umount mnt-${INDEX_IMAGE}
fi

./vdisk-mount.sh reiserfs ${INDEX_IMAGE}
tmux new -d -s 'searchd' './searchd.out -i mnt-${INDEX_IMAGE} -c ${CACHE_SZ}'
EOF
