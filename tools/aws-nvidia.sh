#!/bin/bash

############################################################
#         Copyright (c) 2015 Jonathan Yantis               #
#          Released under the MIT license                  #
############################################################
#                                                          #
# If you want to try this out just use this script to launch
# and connect on an AWS EC2 instance.
#
# IMPORTANT: make sure to change the userdefined variables
#
# You must have aws cli installed.
# https://github.com/aws/aws-cli
#
# If using Arch Linux it is on the AUR as aws-cli
#
# This uses one of the AMIs from
# https://www.uplinklabs.net/projects/arch-linux-on-ec2/
# Usage:
# aws-nvidia.sh volumeid
#
# Example:
# aws-nvidia.sh vol-f49d8ca2
#                                                          #
############################################################

# WARNING: THESE INSTANCES ARE 65+ cents an hour.

############################################################

# USER DEFINABLE (NOT OPTIONAL)
KEYNAME=yantisec2 # Private key name
SUBNETID=subnet-d260adb7 # VPC Subnet ID
VOLUMEID=$2 # (this is your external volume to save your files to)

# USER DEFINABLE (OPTIONAL)
REGION=us-west-2
IMAGEID=ami-71be9041

# Exit the script if any statements returns a non true (0) value.
set -e

# Exit the script on any uninitialized variables.
set -u

# Exit the script if the user didn't specify at least one argument.
if [ "$#" -ne 1 ]; then
  echo "Error: You need to specifiy a volume id"
  exit 1
fi

# Create our new instance
ID=$(aws ec2 run-instances \
  --image-id ${IMAGEID} \
  --key-name ${KEYNAME} \
  --instance-type g2.2xlarge \
  --region ${REGION} \
  --subnet-id ${SUBNETID} | \
    grep InstanceId | awk -F\" '{print $4}')

# Sleep 10 seconds here. Just to give it time to be created.
sleep 10
echo "Instance ID: $ID"


# Query every second until we get our IP.
while [ 1 ]; do
  IP=$(aws ec2 describe-instances --instance-ids $ID | \
    grep PublicIpAddress | \
    awk -F\" '{print $4}')

  if [ -n "$IP" ]; then
    echo "IP Address: $IP"
    break
  fi

  sleep 1
done

# Sleep 30 seconds here. To give it even more time for the instance
# to get to a "running state" so we can attach the volume properly.
sleep 30

# Attach our EBS volume here so we can save some stuff.
aws ec2 attach-volume \
  --instance-id $ID \
  --volume-id $VOLUMEID \
  --device /dev/xvdh

# Connect to the server and update all the drivers and install docker
ssh -o ConnectionAttempts=255 \
    -o StrictHostKeyChecking=no \
    -i $HOME/.ssh/${KEYNAME}.pem\
    root@$IP -tt << EOF
    pacman -Syu --noconfirm
    pacman -S --noconfirm btrfs-progs arch-install-scripts
    mkfs.btrfs -L docker /dev/xvdb -f
    pacman -S docker --noconfirm
    mkdir /mnt/docker
    mount /dev/xvdb /mnt/docker
    sed -i "s/bin\/docker/bin\/docker -g \/mnt\/docker/" /usr/lib/systemd/system/docker.service
    systemctl enable docker.service
    systemctl start docker.service
    useradd --create-home user
    mkdir -p /home/user/.ssh
    cp /root/.ssh/authorized_keys /home/user/.ssh/
    chown -R user:user /home/user/.ssh/
    echo "user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
    sudo mkdir -p /home/user/external
    sudo mount /dev/xvdh /home/user/external
    sudo chown -R user:user /home/user/external
    genfstab -p / >> /etc/fstab
    docker pull yantis/ssh-hpn-x
    reboot
EOF

# Connect to the server launch the container 
ssh -o ConnectionAttempts=255 \
  -o StrictHostKeyChecking=no \
  -i $HOME/.ssh/${KEYNAME}.pem\
  user@$IP -tt << EOF
  sudo nvidia-smi
EOF

# Add this point it would launch a docker container or just launch it manually.
