#!/bin/sh
if [ "$1" == "-h" ]; then
cat << USAGE
Description:
Mirror a git repo from remote.
Examples:
$0 https://github.com/t-k-cloud/wsproxy /root/wsproxy master
USAGE
exit
fi

[ $# -lt 2 ] && echo 'bad arg.' && exit
REPO=$1
MDIR=$2
BRANCH=$3
[ -z $3 ] && BRANCH=master

if [ ! -e "$MDIR" ]; then
	echo "$MDIR not exits, cloning..."
	git clone $REPO "$MDIR";
else
	echo "$MDIR already exits, fetching..."
	cd "$MDIR"
	git fetch origin $BRANCH
	git reset --hard HEAD
	git co origin/$BRANCH
fi;
