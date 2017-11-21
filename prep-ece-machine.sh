#!/bin/bash

# following the tutorial from: https://www.elastic.co/guide/en/cloud-enterprise/current/ece-configure-hosts.html#ece-configure-hosts-xenial

mount=`df | grep ecedata`

# assuming the elastic user (the non admin running docker and ece) will be user 1000 (the first one azure will create)
username=`id -nu 1000`

if [ -z "$mount" ]
then
    echo "[*] creating the partitions"
    sudo parted /dev/sdc mklabel gpt 
    sudo parted /dev/sdc mkpart ecedata ext4 1 100%
    sleep 10
    sudo mkfs.ext4 /dev/sdc1
    sleep 10
    sudo install -o $username -g $username -d -m 700 /ecedata/
    echo "/dev/sdc1 /ecedata ext4 defaults,nofail 0 2" | sudo tee -a /etc/fstab

    sudo systemctl daemon-reload
    sudo systemctl restart local-fs.target

    echo "mounting the partition"
    sudo mount /dev/sdc1
fi

# checking if my mountpoint worked
mount=`df | grep ecedata`

if [  -n "$mount" ]
then
    sudo install -o $username -g $username -d -m 700 /ecedata/docker
    sudo install -o $username -g $username -d -m 700 /ecedata/elastic

    sed s/GRUB_CMDLINE_LINUX\=\"\"/GRUB_CMDLINE_LINUX\=\"cgroup_enable\=memory\ swapaccount\=1\"/ /etc/default/grub | sudo tee /etc/default/grub
    sudo update-grub

    echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf

    # in all the ubuntu 16 azure vms ipv4 forward was enabled

    sed s/\#\ End\ of\ file// /etc/security/limits.conf | sudo tee /etc/security/limits.conf
    cat << LSETTINGS | sudo tee -a /etc/security/limits.conf
*                soft    nofile         1024000
*                hard    nofile         1024000
*                soft    memlock        unlimited
*                hard    memlock        unlimited
elastic          soft    nofile         1024000
elastic          hard    nofile         1024000
elastic          soft    memlock        unlimited
elastic          hard    memlock        unlimited
root             soft    nofile         1024000
root             hard    nofile         1024000
root             soft    memlock        unlimited
# End of file
LSETTINGS

    cat << CLOUDSETTINGS | sudo tee /etc/sysctl.d/70-cloudenterprise.conf
net.ipv4.tcp_max_syn_backlog=65536
net.core.somaxconn=32768
net.core.netdev_max_backlog=32768
CLOUDSETTINGS
    sudo apt-get update
    sudo apt-get install -y linux-generic-lts-xenial xfsprogs

    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 58118E89F3A912897C070ADBF76221572C52609D
    echo deb https://apt.dockerproject.org/repo ubuntu-xenial main | sudo tee /etc/apt/sources.list.d/docker.list
    sudo apt-get update

    sudo apt-get install -y docker-engine=1.11*
    dockerversion=`dpkg -s docker-engine | grep Version | grep 1.11`
    if [ -n "$dockerversion" ]
    then
        echo "[+] docker successfully installed"
        sudo systemctl stop docker
        echo "docker-engine hold" | sudo dpkg --set-selections
        sudo mkdir /etc/systemd/system/docker.service.d/
        cat << DOCKERSETTINGS | sudo tee /etc/systemd/system/docker.service.d/docker.conf
[Unit]
Description=Docker Service
After=multi-user.target

[Service]
Environment="DOCKER_OPTS=-H unix:///run/docker.sock -g /ecedata/docker --storage-driver=aufs --bip=172.17.42.1/16 --raw-logs"
ExecStart=
ExecStart=/usr/bin/docker daemon \$DOCKER_OPTS
DOCKERSETTINGS
        sudo systemctl daemon-reload
        sudo systemctl restart docker
        sudo systemctl enable docker
        sudo usermod -aG docker $username
        sudo reboot
    else
    echo "[-] unable to install the right version of docker; exiting"
    exit
    fi
else
    echo "[-] unable to create partition; exiting"
    exit
fi


