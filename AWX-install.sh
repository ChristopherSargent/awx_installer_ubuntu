#!/bin/bash
#CAS - AWX installer on Ubuntu 20.04
mkdir /home/cas/awx && cd /home/cas/awx
apt update && apt upgrade -y 
apt install ansible
apt -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
apt remove docker docker-engine docker.io containerd runc
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update
apt install docker-ce docker-ce-cli containerd.io
usermod -aG docker $USER
newgrp docker
curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
apt install -y nodejs npm
npm install npm --global
pip3 install docker-compose==1.25.5
apt install python3-pip git pwgen vim
pip3 install requests==2.14.2
pip3 install docker-compose==1.25.5
git clone --depth 50 https://github.com/ansible/awx.git
mkdir /var/lib/awx/projects
