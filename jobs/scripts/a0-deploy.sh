IMG="$1"
RANK=$2
RUN_CMD="$3"

set -e # abort on any error

echo "make symbol link vdisk-mount.sh"
ln -sf ~/a0/indexer/scripts/vdisk-mount.sh

echo "make symbol link searchd into folder run-$RANK"
mkdir -p ~/run-$RANK
ln -sf ~/a0/searchd/run/searchd.out ~/run-$RANK/searchd.out

if [ -e $IMG ]; then
	echo "move index image $IMG ..."
	mv $IMG ${IMG}.run
fi

if mount | grep -q ${IMG}; then
	echo "killing searchd cluster..."
	[ -z "$(pidof searchd.out)" ] && killall -USR1 searchd.out && sleep 8
	echo "umount..."
	umount mnt-${IMG}.run
fi

echo "mounting index image..."
./vdisk-mount.sh reiserfs ${IMG}.run

if [ $RANK -eq 0 ]; then
	echo "create searchd tmux session..."
	echo "$RUN_CMD"
	tmux new -d -s 'searchd' "$RUN_CMD"
	sleep 8
	tmux list-sessions
fi
