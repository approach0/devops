PEERS="$1"
shift

for peer in $(echo $PEERS); do
	# I've tried "$@", it does not work. Why?
	# So here is the ugly way:
	$SSH 'bash -s' -- < $1 $2 $3 $4 $5 $peer
done
