#!/bin/bash

############################################################
# Copyright (c) 2015 Jonathan Yantis
# Released under the MIT license
############################################################

# This script will create a new EBS volume and format it.
# Usage: aws-ebs-create-volume-and-format 100
# (That would create and new volume of 100 GB and format it)

# You must have aws cli installed.
# https://github.com/aws/aws-cli
# If using Arch Linux it is on the AUR as aws-cli

# This uses just basic Amazon Linux for simplicity.
# Amazon Linux AMI 2015.03.0 x86_64 HVM 
############################################################

# USER DEFINABLE (NOT OPTIONAL)
KEYNAME=yantisec2 # Private key name
SUBNETID=subnet-d260adb7 # VPC Subnet ID

# USER DEFINABLE (OPTIONAL)
REGION=us-west-2
AVAILABILITY_ZONE=us-west-2a
IMAGEID=ami-e7527ed7

# Create our new instance
ID=$(aws ec2 run-instances \
            --image-id ${IMAGEID} \
            --key-name ${KEYNAME} \
            --instance-type t2.micro \
            --region ${REGION} \
            --subnet-id ${SUBNETID} | \
     grep InstanceId | awk -F\" '{print $4}')

# Sleep 10 seconds here. Just to give it time to be created.
sleep 10
echo "Instance ID: $ID"

# Create our new volume
VOLUMEID=$(aws ec2 create-volume \
  --size $1 \
  --region $REGION \
  --availability-zone $AVAILABILITY_ZONE \
  --volume-type gp2 | \
  grep VolumeId | awk -F\" '{print $4}')

# Sleep 5 seconds here. Just to give it time to be created.
sleep 5
echo "Volume ID: $VOLUMEID"

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

# Attach our new EBS volume here
aws ec2 attach-volume \
        --instance-id $ID \
        --volume-id $VOLUMEID \
        --device /dev/xvdh

# Connect to the server and format the volume 
# then quickly mount and umount it to make sure it works.
ssh -o ConnectionAttempts=255 \
  -o StrictHostKeyChecking=no \
  -i $HOME/.ssh/${KEYNAME}.pem\
  ec2-user@$IP -tt << EOF
sudo mkfs -t ext4 /dev/xvdh
mkdir /home/ec2-user/external
sudo mount /dev/xvdh /home/ec2-user/external
sudo lsblk
sudo ls -l /home/ec2-user/external
sudo umount /dev/xvdh
sudo nohup shutdown 1 &
exit
EOF

# Detach our volume since we are done with it.
aws ec2 detach-volume \
  --instance-id $ID \
  --volume-id $VOLUMEID \
  --device /dev/xvdh

# Now that we are done. Delete the instance.
aws ec2 terminate-instances --instance-ids $ID

echo $VOLUMEID should be formated as ext4 and ready to use 
