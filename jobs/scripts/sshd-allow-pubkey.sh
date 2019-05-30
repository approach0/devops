PUBKEY=$1
FILE=~/.ssh/authorized_keys

if grep "$PUBKEY" $FILE; then
	echo "Pubkey is already there, abort."
	exit 0;
fi

mkdir -p ~/.ssh
chmod 700 ~/.ssh
touch $FILE
chmod 600 $FILE

echo $PUBKEY >> $FILE
