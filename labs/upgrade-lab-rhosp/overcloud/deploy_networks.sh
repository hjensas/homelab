#!/bin/bash

source /home/cloud-user/stackrc
cd /home/cloud-user

openstack overcloud network provision \
  --output /home/cloud-user/overcloud-networks-deployed.yaml \
  /home/cloud-user/overcloud/network_data_v2.yaml 

