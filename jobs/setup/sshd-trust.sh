PUBKEY=$1
FILE=~/.ssh/authorized_keys

mkdir -p ~/.ssh
chmod 700 ~/.ssh
touch $FILE
chmod 600 $FILE

echo $PUBKEY > $FILE
