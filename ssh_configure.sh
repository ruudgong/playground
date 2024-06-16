#!/bin/bash
#####################################################################################
## This script requires the input of a machine name to copy the SSH key to ##########
#####################################################################################

## Note:
##    .bash_profile loads when you first log into a machine
##    .bashrc loads every time you open a terminal

echo ""
echo "####################################################################"
echo -e "###### Configuring profile on \e[01;31m$1\e[0;0m"
echo "####################################################################"
echo ""

## Generate and copy SSH key to the remote machine
cat ~/.ssh/id_rsa.pub | ssh $1 "
    mkdir -p ~/.ssh;
    cat >> ~/.ssh/authorized_keys;
    chmod 600 ~/.ssh/authorized_keys;
    sort -u ~/.ssh/authorized_keys -o ~/.ssh/authorized_keys
"

## Confirm SSH key addition
ssh $1 "
    echo '### Key successfully added to:';
    hostname
"

## Copy local profile and configuration files to the remote machine
scp ~/.bash_function $1:~/.bash_function
scp ~/.bash_alias $1:~/.bash_alias
scp ~/.bash_profile $1:~/.bash_profile
scp ~/.bashrc $1:~/.bashrc

## Confirm files have been copied
ssh $1 "
    echo '### .bashrc, .bash_function, .bash_alias, and .bash_profile successfully copied to:';
    hostname
"

## Prepare remote directories and copy additional configuration files
ssh $1 "
    mkdir -p ~/bash;
    touch ~/bash/bashrc_root;
    touch ~/bash/bashrc_apache;
    touch ~/.hushlogin
"
scp ~/bash/bashrc_root $1:~/bash/
scp ~/bash/bashrc_apache $1:~/bash/

## Optional: Uncomment the lines below if you need to configure root and Apache user's bashrc
# ssh $1 "sudo cp -v /home/ruudgong/bash/bashrc_root /root/.bashrc"
# ssh $1 "sudo su - apache -c 'cp -v /home/ruudgong/bash/bashrc_apache /home/apache/.bashrc'"

## Optional: Uncomment to copy a script for remote setup
# scp ~/bash/set_bashrc_apache_root.sh $1:~/bash/

echo ""
echo "###########################################################"
echo -e "###### Profile configured on \e[01;32m$1\e[0;0m"
echo "###########################################################"
echo ""
