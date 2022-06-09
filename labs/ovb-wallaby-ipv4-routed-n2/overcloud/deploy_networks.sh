#!/bin/bash

source /home/cloud-user/stackrc
cd /home/cloud-user


openstack overcloud network provision \
  --output /home/cloud-user/overcloud-networks-deployed.yaml \
  /home/cloud-user/overcloud/network_data_v2.yaml 

sed -i 's|/usr/share/openstack-tripleo-heat-templates|/home/cloud-user/tripleo-heat-templates|g' /home/cloud-user/overcloud-networks-deployed.yaml

