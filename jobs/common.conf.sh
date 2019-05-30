############
# Common
############
export DOMAIN=xitizu.com

#export A0_SLAVE=192.168.210.5
#export A0_MASTER_RUN=mpirun --host localhost,localhost,${A0_SLAVE}, ${A0_SLAVE} \
export A0_MASTER_RUN="mpirun --allow-run-as-root --host localhost,localhost \
    -n 1 --wdir ./run-0 searchd.out -i ../mnt-index-0.img.run/ -c 800 : \
    -n 1 --wdir ./run-1 searchd.out -i ../mnt-index-1.img.run/ -c 800 "

############
# Fixed
############
export SSH_USER=root
export SSH_PORT=8981
export SSH_OLD_PORT=22 # used when changing port

export RSYNC_PORT=8990

############
# Shortcuts
############
export TOP=$PWD/../jobs
export SCRIPT=$TOP/scripts
export CONFIG=$TOP/configs

export SSH="ssh -o PasswordAuthentication=no -p $SSH_PORT $SSH_USER@$IP"
export SCP="scp -P $SSH_PORT"
export PUBKEY=$(cat ~/.ssh/id_rsa.pub)
export SSH_AUTH_SOCK=/tmp/ssh-agent.sock
export SSH_AGENT_ENV=~/.ssh/ssh-agent.sh

export RSYNC_ALLOW_IP=$(wget -qO - icanhazip.com)
export RSYNC_ADDR=rsync://$IP:$RSYNC_PORT/root
