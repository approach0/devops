#!/bin/bash
IP="$1"
while pidof 'rsync'; do sleep 10; done; ./deploy.sh ${IP} demo.img 1800
