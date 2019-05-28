#!/bin/sh
if [ ! -e $SSH_AGENT_ENV ]; then
	touch $SSH_AGENT_ENV
	chmod +x $SSH_AGENT_ENV
fi;

echo "KILL OLD AGENT ...."
source $SSH_AGENT_ENV
ssh-agent -k

echo "CREATE NEW AGENT ...."
ssh-agent -a $SSH_AUTH_SOCK > $SSH_AGENT_ENV
cat $SSH_AGENT_ENV

ssh-add ~/.ssh/id_rsa
