#!/bin/bash
#CAS - AWX installer on Ubuntu 20.04

# GUI
#apt install tasksel -y
#tasksel install ubuntu-mate-core
#systemctl enable lightdm && systemctl start lightdm

echo "export PROMPT_COMMAND='echo -n \[\$(date +%F-%T)\]\ '" >> /root/.bashrc
echo "export HISTTIMEFORMAT='%F-%T '" >> /root/.bashrc
source /root/.bashrc

# Set up docker enviroment
apt update && apt upgrade -y
apt -y install ansible apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update && apt install docker-ce docker-ce-cli containerd.io -y && apt remove docker docker.io containerd runc

# Sleep for 5
sleep 5;

# Curl docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Sleep for 5
sleep 5;

# Install npm and configure
apt install -y nodejs npm
npm install npm --global
sleep 5;
apt install python3-pip git pwgen vim -y
pip3 install requests==2.20.0
pip3 install docker-compose==1.25.5
git clone --depth 50 https://github.com/ansible/awx.git
mkdir -p /var/lib/awx/projects

# Add and install pyvmomi
git clone https://github.com/vmware/pyvmomi.git
cd pyvmomi && python3 setup.py install && cd /root

# Update AWX inventory file
cp /root/awx/installer/inventory /root/awx/inventory/inventory.ORIG
echo '
localhost ansible_connection=local ansible_python_interpreter="/usr/bin/env python3"
[all:vars]
dockerhub_base=ansible
awx_task_hostname=awx
awx_web_hostname=awxweb
postgres_data_dir="/root/.awx/pgdocker"
host_port=8080
host_port_ssl=8443
docker_compose_dir="/root/.awx/awxcompose"
pg_username=awx
pg_password=awxpass
pg_database=awx
pg_port=5432
admin_user=admin
admin_password=31nst31n
create_preload_data=True
secret_key=uSaBIwT6CyIYuMY1FMEdvIsFDmvTyl
project_data_dir=/var/lib/awx/projects' > /root/awx/installer/inventory
cd /root/awx/installer && ansible-playbook -i inventory install.yml

# Update docker users
usermod -aG docker $USER
newgrp docker

# Note this pulled AWX 16.0 and built the containers with no issues however the playbook does show a failuer (even though the containers come up and function). The error is at TASK [local_docker : Create Preload data] see github issue https://github.com/ansible/awx/issues/8863 again it works even with this error. Just ggive awxweb about 5 minutes.
