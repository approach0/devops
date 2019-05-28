#!/bin/sh
# Because of the # charater, I cannot issue this simple line in *.jog.cfg
sed -i 's/# ssl_certificate/ssl_certificate/g' /etc/nginx/sites-available/default
