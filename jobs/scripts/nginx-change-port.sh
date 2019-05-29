#!/bin/sh
sed -i "/listen 80/c listen 8080 default_server;" /etc/nginx/sites-available/default
systemctl restart nginx
