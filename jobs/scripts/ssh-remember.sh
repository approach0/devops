allow_port=$1
allow_ip=$2

echo "To allow: $allow_ip:$allow_port"

if grep $allow_ip /etc/ssh/ssh_config; then
	echo "Config is already there, abort."
	exit 0;
fi

cat << EOF >> /etc/ssh/ssh_config

Host $allow_ip
	Port $allow_port
	# avoid "Are you sure to connect..." prompt
	StrictHostKeyChecking no
EOF
