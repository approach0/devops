IMG="$1"
RANK=$2

set -e # abort on any error

echo "make symbol link vdisk-mount.sh"
ln -sf ~/a0/indexer/scripts/vdisk-mount.sh

echo "make symbol link searchd into folder run-$RANK"
mkdir -p ~/run-$RANK
ln -sf ~/a0/searchd/run/searchd.out ~/run-$RANK/searchd.out

# ensure nothing is using image device
if mount | grep -q ${IMG}; then
	if [ ! -z "$(pidof searchd.out)" ]; then
		echo "killing searchd cluster..."
		killall -USR1 searchd.out
		sleep 8
	fi
	echo "umount..."
	umount mnt-${IMG}.run
fi

# then safely update image
if [ -e $IMG ]; then
	echo "update index image $IMG ..."
	mv $IMG ${IMG}.run
fi

# image ready to be used after mounting
echo "mounting index image..."
./vdisk-mount.sh reiserfs ${IMG}.run
