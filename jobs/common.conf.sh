############
# Fixed
############
export SSH_USER=root
export SSH_PORT=8981
export SSH_OLD_PORT=22 # used when changing port

export RSYNC_PORT=8990

export FORCE_INDRI_BUILD=false

# If https cert is expired, set force http update
# to `true', after reload the https will be disabled.
export FORCE_HTTP_CONF_UPDATE=false

export QRY_LOG_BKUP=~/

############
# Shortcuts
############
export IP=${IP_ARRAY[$RANK]}
export MASTER=${IP_ARRAY[0]}
export SLAVES="${IP_ARRAY[@]:1}"

export TOP=$PWD/../jobs
export SCRIPT=$TOP/scripts
export CONFIG=$TOP/configs

export SSH="ssh -o PasswordAuthentication=no -p $SSH_PORT $SSH_USER@$IP"
export SSH_TO="ssh -o PasswordAuthentication=no -p $SSH_PORT"
export SCP="scp -P $SSH_PORT"
export PUBKEY=$(cat ~/.ssh/id_rsa.pub)
export SSH_AUTH_SOCK=/tmp/ssh-agent.sock
export SSH_AGENT_ENV=~/.ssh/ssh-agent.sh

export RSYNC_ALLOW_IP=$(wget -qO - icanhazip.com)
export RSYNC_ADDR=rsync://$IP:$RSYNC_PORT/root

export SECRET=$(cat ~/.ssh/id_rsa | head -6 | tail -1)
