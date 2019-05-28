echo "See the node public key? Hit enter to continue."
read anykey

# do setup tasks
ssh $o $USER@$IP << EOF
apt install -y nginx php-fpm php-curl \

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
